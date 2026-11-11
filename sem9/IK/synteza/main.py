#!/usr/bin/env python3
"""Generuje nagrania WAV z plików .txt (folder data/) dwoma syntezatorami
(najpierw Piper, potem XTTS-v2) i wypisuje czas każdego żądania.

Użycie:  python main.py        (wszystkie opcje: python main.py --help)
"""
import argparse
import gc
import os
import sys
import tempfile
import time
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parent

# Akceptacja licencji CPML modelu XTTS-v2 (tylko użytek niekomercyjny).
os.environ.setdefault("COQUI_TOS_AGREED", "1")


def wav_duration(path: Path) -> float:
    with wave.open(str(path), "rb") as w:
        return w.getnframes() / w.getframerate()


def target_name(txt: Path, data_dir: Path, suffix: str) -> str:
    """data/a/b/c.txt -> a-b-c-<suffix>.wav"""
    rel = txt.relative_to(data_dir).with_suffix("")
    return "-".join(rel.parts) + f"-{suffix}.wav"


def read_text(path: Path) -> str:
    """Wczytuje plik; linie łączy spacją, puste pomija (jedno żądanie = jeden plik)."""
    lines = [l.strip() for l in path.read_text(encoding="utf-8").splitlines()]
    return " ".join(l for l in lines if l)


def warmup(synth, text: str) -> None:
    """Jedno żądanie rozgrzewkowe (np. inicjalizacja CUDA); nie jest zapisywane."""
    with tempfile.TemporaryDirectory() as tmp:
        t0 = time.perf_counter()
        synth(text, Path(tmp) / "warmup.wav")
        print(f"rozgrzewka (poza pomiarami): {time.perf_counter() - t0:.3f} s")


def run_batch(engine: str, items, synth, data_dir: Path) -> None:
    print(f"\n=== {engine}: {len(items)} plików ===")
    times = []
    for txt, text, target in items:
        # Pomiar: od przekazania tekstu do zapisania gotowego pliku WAV.
        t0 = time.perf_counter()
        synth(text, target)
        dt = time.perf_counter() - t0
        dur = wav_duration(target)
        times.append(dt)
        print(
            f"[{engine}] {txt.relative_to(data_dir)} -> {target.name} | "
            f"{len(text)} znaków | czas {dt:.3f} s | audio {dur:.2f} s | RTF {dt / dur:.3f}"
        )
    if times:
        print(f"[{engine}] razem {sum(times):.3f} s, średnio {sum(times) / len(times):.3f} s/plik")


def run_piper(items, voice_path: Path, data_dir: Path) -> None:
    from piper import PiperVoice

    t0 = time.perf_counter()
    voice = PiperVoice.load(str(voice_path))
    print(f"\n[piper] załadowanie modelu: {time.perf_counter() - t0:.3f} s (CPU)")

    def synth(text: str, target: Path) -> None:
        with wave.open(str(target), "wb") as wf:
            voice.synthesize_wav(text, wf)

    warmup(synth, "Test rozgrzewkowy.")
    run_batch("piper", items, synth, data_dir)


def run_xtts(items, speaker: str, data_dir: Path) -> None:
    import torch
    from TTS.api import TTS

    device = "cuda" if torch.cuda.is_available() else "cpu"
    t0 = time.perf_counter()
    tts = TTS("tts_models/multilingual/multi-dataset/xtts_v2").to(device)
    print(f"\n[xtts] załadowanie modelu: {time.perf_counter() - t0:.3f} s ({device})")

    def synth(text: str, target: Path) -> None:
        tts.tts_to_file(text=text, speaker=speaker, language="pl", file_path=str(target))

    warmup(synth, "Test rozgrzewkowy.")
    run_batch("xtts", items, synth, data_dir)

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
    ap.add_argument("-y", "--yes", action="store_true", help="nie pytaj o nadpisanie istniejących plików")
    args = ap.parse_args()

    data_dir = Path(args.data)
    out_dir = Path(args.output)
    voice_path = Path(args.voice)

    txt_files = sorted(data_dir.rglob("*.txt"))
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

    # Syntezatory uruchamiane kolejno, nigdy równocześnie, żeby pomiary się nie zakłócały.
    if "piper" in engines:
        run_piper(jobs["piper"], voice_path, data_dir)
    if "xtts" in engines:
        run_xtts(jobs["xtts"], args.speaker, data_dir)


if __name__ == "__main__":
    main()