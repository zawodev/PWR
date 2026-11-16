#!/usr/bin/env python3
"""Ponowna transkrypcja wygenerowanych nagrań lokalnym Whisperem (openai/whisper-large-v3,
transformers, GPU) -> output/transcripts.csv. Służy do automatycznej oceny kryterium 1
(porównanie transkrypcji z tekstem wejściowym: WER/CER, sondy trudnych fragmentów).

Użycie:  python transcribe.py            (pomija pliki już przetranskrybowane)
         python transcribe.py --force    (od nowa)

Uwaga metodologiczna: Whisper ma silny model językowy - potrafi "poprawić" lekko błędną
wymowę i zapisać liczby cyframi. Wynik automatyczny to więc DOLNE oszacowanie liczby
błędów; ostateczna weryfikacja 30 próbek odbywa się odsłuchowo.
"""
import argparse
import csv
import time
from pathlib import Path

import librosa
import numpy as np
import torch
from transformers import pipeline

ROOT = Path(__file__).resolve().parent
MODEL = "openai/whisper-large-v3"


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--output", default=str(ROOT / "output"))
    ap.add_argument("--model", default=MODEL)
    ap.add_argument("--force", action="store_true")
    ap.add_argument("--beams", type=int, default=5, help="szerokość beam search")
    args = ap.parse_args()

    out_dir = Path(args.output)
    csv_path = out_dir / "transcripts.csv"
    done = {}
    if csv_path.exists() and not args.force:
        with csv_path.open(encoding="utf-8") as f:
            done = {(r["engine"], r["wav"]): r for r in csv.DictReader(f)}

    wavs = [(e, p) for e in ("piper", "xtts") for p in sorted((out_dir / e).glob("*.wav"))]
    todo = [(e, p) for e, p in wavs if (e, p.name) not in done]
    print(f"{len(wavs)} nagrań, do transkrypcji: {len(todo)}")

    device = "cuda" if torch.cuda.is_available() else "cpu"
    asr = pipeline(
        "automatic-speech-recognition",
        model=args.model,
        dtype=torch.float16 if device == "cuda" else torch.float32,
        device=device,
    )
    gen = {"language": "polish", "task": "transcribe", "num_beams": args.beams}

    rows = list(done.values())
    t_all = time.perf_counter()
    for i, (engine, wav) in enumerate(todo, 1):
        audio, sr = librosa.load(str(wav), sr=16000, mono=True)
        t0 = time.perf_counter()
        res = asr({"raw": audio.astype(np.float32), "sampling_rate": 16000},
                  generate_kwargs=gen, return_timestamps=True)
        text = res["text"].strip()
        rows.append({"engine": engine, "wav": wav.name, "text": text})
        print(f"[{i}/{len(todo)}] {engine} {wav.name} ({time.perf_counter() - t0:.1f} s): {text[:90]}")
        if i % 20 == 0:  # zapis przyrostowy
            write(csv_path, rows)
    write(csv_path, rows)
    print(f"Gotowe w {time.perf_counter() - t_all:.0f} s -> {csv_path}")


def write(path: Path, rows) -> None:
    rows = sorted(rows, key=lambda r: (r["engine"], r["wav"]))
    with path.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=["engine", "wav", "text"])
        w.writeheader()
        w.writerows(rows)


if __name__ == "__main__":
    main()
