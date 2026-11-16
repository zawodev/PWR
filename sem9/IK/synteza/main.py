#!/usr/bin/env python3
"""Generuje nagrania WAV z plików .txt (folder data/) dwoma syntezatorami
(najpierw Piper, potem XTTS-v2), mierzy czas każdego żądania i zapisuje
wyniki pomiarów do output/timings_<silnik>.csv (kryterium 7).

Użycie:  python main.py -y              (wszystkie opcje: python main.py --help)
         python main.py -y --repeat 3   (3 pomiary na plik, w CSV mediana + wszystkie próby)
"""
import argparse
import csv
import gc
import os
import platform
import random
import statistics
import sys
import tempfile
import time
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parent

# Akceptacja licencji CPML modelu XTTS-v2 (tylko użytek niekomercyjny).
os.environ.setdefault("COQUI_TOS_AGREED", "1")

# Rozszerzenia traktowane jako teksty testowe (".txt_" - literówka w jednym z plików bazy).
TEXT_SUFFIXES = {".txt", ".txt_"}
SEED = 1234


def wav_duration(path: Path) -> float:
    with wave.open(str(path), "rb") as w:
        return w.getnframes() / w.getframerate()


def target_name(txt: Path, data_dir: Path, suffix: str) -> str:
    """data/a/b/c.txt -> a-b-c-<suffix>.wav"""
    rel = txt.relative_to(data_dir)
    rel = rel.with_name(rel.name.split(".")[0])
    return "-".join(rel.parts) + f"-{suffix}.wav"


def read_text(path: Path) -> str:
    """Wczytuje plik; linie łączy spacją, puste pomija (jedno żądanie = jeden plik)."""
    lines = [l.strip() for l in path.read_text(encoding="utf-8").splitlines()]
    return " ".join(l for l in lines if l)


def category_of(txt: Path) -> str:
    """272644-3-numbers.txt -> '3' (numer kategorii tekstu)."""
    parts = txt.name.split("-")
    return parts[1] if len(parts) > 1 and parts[1].isdigit() else "?"


def seed_all() -> None:
    random.seed(SEED)
    try:
        import numpy as np

        np.random.seed(SEED)
    except ImportError:
        pass
    try:
        import torch

        torch.manual_seed(SEED)
        if torch.cuda.is_available():
            torch.cuda.manual_seed_all(SEED)
    except ImportError:
        pass


def warmup(synth, text: str) -> None:
    """Żądania rozgrzewkowe (np. inicjalizacja CUDA); nie są zapisywane ani mierzone."""
    with tempfile.TemporaryDirectory() as tmp:
        t0 = time.perf_counter()
        for i in range(2):
            synth(text, Path(tmp) / f"warmup{i}.wav")
        print(f"rozgrzewka (poza pomiarami): {time.perf_counter() - t0:.3f} s")


def run_batch(engine: str, items, synth, data_dir: Path, out_dir: Path, repeat: int, meta: dict) -> None:
    print(f"\n=== {engine}: {len(items)} plików, {repeat} pomiar(y) na plik ===")
    rows = []
    for txt, text, target in items:
        # Pomiar: od przekazania tekstu do zapisania gotowego pliku WAV.
        # Przy repeat > 1 plik jest nadpisywany, zostaje ostatnia wersja nagrania.
        times = []
        for _ in range(repeat):
            t0 = time.perf_counter()
            synth(text, target)
            times.append(time.perf_counter() - t0)
        dt = statistics.median(times)
        dur = wav_duration(target)
        rel = txt.relative_to(data_dir).as_posix()
        rows.append(
            {
                "engine": engine,
                "file": rel,
                "author": txt.relative_to(data_dir).parts[0],
                "category": category_of(txt),
                "wav": target.name,
                "chars": len(text),
                "words": len(text.split()),
                "synth_time_s": round(dt, 4),
                "synth_time_min_s": round(min(times), 4),
                "synth_time_max_s": round(max(times), 4),
                "all_times_s": ";".join(f"{t:.4f}" for t in times),
                "audio_s": round(dur, 3),
                "rtf": round(dt / dur, 4) if dur else "",
                "chars_per_s": round(len(text) / dt, 1),
                **meta,
            }
        )
        print(
            f"[{engine}] {rel} -> {target.name} | {len(text)} znaków | czas {dt:.3f} s "
            f"(min {min(times):.3f}, max {max(times):.3f}) | audio {dur:.2f} s | RTF {dt / dur:.3f}"
        )
    if rows:
        tot = sum(r["synth_time_s"] for r in rows)
        print(f"[{engine}] razem {tot:.3f} s, średnio {tot / len(rows):.3f} s/plik")
        csv_path = out_dir / f"timings_{engine}.csv"
        with csv_path.open("w", newline="", encoding="utf-8") as f:
            w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
            w.writeheader()
            w.writerows(rows)
        print(f"[{engine}] pomiary zapisane: {csv_path}")


def run_piper(items, voice_path: Path, data_dir: Path, out_dir: Path, repeat: int) -> None:
    from piper import PiperVoice

    t0 = time.perf_counter()
    voice = PiperVoice.load(str(voice_path))
    load = time.perf_counter() - t0
    print(f"\n[piper] załadowanie modelu: {load:.3f} s (CPU)")

    def synth(text: str, target: Path) -> None:
        with wave.open(str(target), "wb") as wf:
            voice.synthesize_wav(text, wf)

    warmup(synth, "Test rozgrzewkowy.")
    meta = {"device": f"CPU ({platform.processor() or platform.machine()})", "model_load_s": round(load, 3),
            "model": voice_path.stem}
    run_batch("piper", items, synth, data_dir, out_dir, repeat, meta)


def run_xtts(items, speaker: str, data_dir: Path, out_dir: Path, repeat: int) -> None:
    import torch
    from TTS.api import TTS

    device = "cuda" if torch.cuda.is_available() else "cpu"
    t0 = time.perf_counter()
    tts = TTS("tts_models/multilingual/multi-dataset/xtts_v2").to(device)
    load = time.perf_counter() - t0
    print(f"\n[xtts] załadowanie modelu: {load:.3f} s ({device})")

    def synth(text: str, target: Path) -> None:
        tts.tts_to_file(text=text, speaker=speaker, language="pl", file_path=str(target))
        if device == "cuda":
            torch.cuda.synchronize()

    warmup(synth, "Test rozgrzewkowy.")
    dev_name = torch.cuda.get_device_name(0) if device == "cuda" else "CPU"
    meta = {"device": f"{device} ({dev_name})", "model_load_s": round(load, 3), "model": f"xtts_v2/{speaker}"}
    run_batch("xtts", items, synth, data_dir, out_dir, repeat, meta)

    del tts
    gc.collect()
    if device == "cuda":
        torch.cuda.empty_cache()


def main() -> None:
    ap = argparse.ArgumentParser(description="Synteza mowy: Piper, a potem XTTS-v2, dla plików z data/")
    ap.add_argument("--data", default=str(ROOT / "data"), help="folder z plikami .txt (rekurencyjnie)")
    ap.add_argument("--output", default=str(ROOT / "output"), help="folder wyjściowy")
    ap.add_argument(
        "--voice",
        default=str(ROOT / "voices" / "pl_PL-darkman-medium.onnx"),
        help="plik .onnx głosu Pipera",
    )
    ap.add_argument("--speaker", default="Claribel Dervla", help="wbudowany głos XTTS")
    ap.add_argument("--only", choices=["piper", "xtts"], help="uruchom tylko jeden syntezator")
    ap.add_argument("--list", help="plik z listą ścieżek (względem --data), które mają być przetworzone")
    ap.add_argument("--repeat", type=int, default=1, help="liczba pomiarów czasu na plik (w CSV mediana)")
    ap.add_argument("-y", "--yes", action="store_true", help="nie pytaj o nadpisanie istniejących plików")
    args = ap.parse_args()

    data_dir = Path(args.data)
    out_dir = Path(args.output)
    voice_path = Path(args.voice)

    txt_files = sorted(p for p in data_dir.rglob("*") if p.is_file() and p.suffix in TEXT_SUFFIXES)
    if args.list:
        wanted = {l.strip() for l in Path(args.list).read_text(encoding="utf-8").splitlines()
                  if l.strip() and not l.startswith("#")}
        txt_files = [p for p in txt_files if p.relative_to(data_dir).as_posix() in wanted]
    if not txt_files:
        sys.exit(f"Brak plików .txt w {data_dir}")

    engines = [args.only] if args.only else ["piper", "xtts"]
    if "piper" in engines and not voice_path.exists():
        sys.exit(
            f"Brak modelu Pipera: {voice_path}\n"
            f"Pobierz: python -m piper.download_voices --data-dir voices pl_PL-darkman-medium"
        )

    # Zadania: (plik txt, tekst, ścieżka wyniku) dla każdego syntezatora.
    jobs = {}
    for engine in engines:
        items, seen = [], {}
        for f in txt_files:
            text = read_text(f)
            if not text:
                print(f"Pomijam pusty plik: {f}")
                continue
            target = out_dir / engine / target_name(f, data_dir, engine)
            if target in seen:
                sys.exit(f"Kolizja nazw wyjściowych:\n  {seen[target]}\n  {f}\n  -> {target.name}")
            seen[target] = f
            items.append((f, text, target))
        jobs[engine] = items

    existing = [t for items in jobs.values() for _, _, t in items if t.exists()]
    if existing:
        print(f"UWAGA: {len(existing)} plików wynikowych już istnieje i zostanie nadpisanych:")
        for p in existing[:10]:
            print(f"  {p}")
        if len(existing) > 10:
            print(f"  ... i {len(existing) - 10} kolejnych")
        if not args.yes and input("Kontynuować? (y/n): ").strip().lower() not in ("y", "yes"):
            sys.exit("Przerwano.")

    for engine in engines:
        (out_dir / engine).mkdir(parents=True, exist_ok=True)

    seed_all()
    # Syntezatory uruchamiane kolejno, nigdy równocześnie, żeby pomiary się nie zakłócały.
    if "piper" in engines:
        run_piper(jobs["piper"], voice_path, data_dir, out_dir, args.repeat)
    if "xtts" in engines:
        run_xtts(jobs["xtts"], args.speaker, data_dir, out_dir, args.repeat)


if __name__ == "__main__":
    main()
