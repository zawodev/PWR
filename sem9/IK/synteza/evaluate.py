#!/usr/bin/env python3
"""Analiza wyników: kryteria 1 (poprawność wymowy - automatycznie przez Whisper) i 7 (czas),
przygotowanie zanonimizowanych nagrań do odsłuchu i arkusza ocen do ręcznego uzupełnienia.

Wejście:  data/**/*.txt, output/timings_{piper,xtts}.csv, output/transcripts.csv, selection.py
Wyjście:  output/wyniki/ocena_TTS.xlsx         - główny arkusz (instrukcja, oceny, podsumowanie...)
          output/wyniki/auto_wszystkie.csv      - WER/CER dla wszystkich nagrań
          output/wyniki/sondy.csv               - wyniki sond dla 30 próbek
          output/wyniki/ciekawe_przypadki.md    - automatycznie wyłowione ciekawe przypadki
          output/odsluch/S01_A.wav ...          - 60 zanonimizowanych nagrań (30 próbek x 2 systemy)
          output/odsluch/klucz_NIE_OTWIERAC.csv - który system kryje się pod A/B

Użycie:  python evaluate.py            (python evaluate.py --no-audio  - bez ponownej konwersji audio)
"""
import argparse
import csv
import random
import re
import shutil
import statistics
import subprocess
from collections import Counter
from pathlib import Path

from main import read_text, target_name, TEXT_SUFFIXES, category_of
from pl_norm import normalize
from selection import SELECTED, CATS, FRONTEND_CASES

ROOT = Path(__file__).resolve().parent
DATA = ROOT / "data"
OUT = ROOT / "output"
RES = OUT / "wyniki"
BLIND = OUT / "odsluch"
ENGINES = ["piper", "xtts"]
ENGINE_LABEL = {"piper": "Piper", "xtts": "XTTS-v2"}
CAT_NAMES = {"1": "1-info", "2": "2-qna", "3": "3-numbers", "4": "4-long", "5": "5-unique-foreign"}


# ------------------------------------------------------------------ metryki
def align(ref, hyp):
    """Levenshtein z odtworzeniem ścieżki -> (S, D, I, lista operacji)."""
    n, m = len(ref), len(hyp)
    d = [[0] * (m + 1) for _ in range(n + 1)]
    for i in range(n + 1):
        d[i][0] = i
    for j in range(m + 1):
        d[0][j] = j
    for i in range(1, n + 1):
        for j in range(1, m + 1):
            d[i][j] = min(d[i - 1][j] + 1, d[i][j - 1] + 1, d[i - 1][j - 1] + (ref[i - 1] != hyp[j - 1]))
    ops, i, j = [], n, m
    while i or j:
        if i and j and d[i][j] == d[i - 1][j - 1] + (ref[i - 1] != hyp[j - 1]):
            if ref[i - 1] != hyp[j - 1]:
                ops.append(("S", ref[i - 1], hyp[j - 1]))
            i, j = i - 1, j - 1
        elif i and d[i][j] == d[i - 1][j] + 1:
            ops.append(("D", ref[i - 1], ""))
            i -= 1
        else:
            ops.append(("I", "", hyp[j - 1]))
            j -= 1
    ops.reverse()
    return ops


def wer_cer(ref_n: str, hyp_n: str):
    r, h = ref_n.split(), hyp_n.split()
    ops = align(r, h)
    rs, hs = [w[:4] for w in r], [w[:4] for w in h]
    stem_err = len(align(rs, hs))
    cr, ch = list(ref_n.replace(" ", "")), list(hyp_n.replace(" ", ""))
    cer_err = len(align(cr, ch)) if len(cr) * len(ch) < 2_500_000 else None
    return {
        "ref_words": len(r), "errors": len(ops),
        "S": sum(o[0] == "S" for o in ops), "D": sum(o[0] == "D" for o in ops), "I": sum(o[0] == "I" for o in ops),
        "wer": len(ops) / max(1, len(r)), "wer_stem": stem_err / max(1, len(r)),
        "cer": (cer_err / max(1, len(cr))) if cer_err is not None else "",
        "ops": ops,
    }


def error_phrases(ref_n, hyp_n):
    """Frazy różnic: ciągi operacji niebędących dopasowaniami."""
    r, h = ref_n.split(), hyp_n.split()
    n, m = len(r), len(h)
    d = [[0] * (m + 1) for _ in range(n + 1)]
    for i in range(n + 1):
        d[i][0] = i
    for j in range(m + 1):
        d[0][j] = j
    for i in range(1, n + 1):
        for j in range(1, m + 1):
            d[i][j] = min(d[i - 1][j] + 1, d[i][j - 1] + 1, d[i - 1][j - 1] + (r[i - 1] != h[j - 1]))
    seq, i, j = [], n, m
    while i or j:
        if i and j and d[i][j] == d[i - 1][j - 1] + (r[i - 1] != h[j - 1]):
            seq.append(("M" if r[i - 1] == h[j - 1] else "S", r[i - 1], h[j - 1]))
            i, j = i - 1, j - 1
        elif i and d[i][j] == d[i - 1][j] + 1:
            seq.append(("D", r[i - 1], ""))
            i -= 1
        else:
            seq.append(("I", "", h[j - 1]))
            j -= 1
    seq.reverse()
    out, cur_r, cur_h = [], [], []
    for op, a, b in seq + [("M", "", "")]:
        if op == "M":
            if cur_r or cur_h:
                out.append((" ".join(cur_r), " ".join(cur_h)))
            cur_r, cur_h = [], []
        else:
            if a:
                cur_r.append(a)
            if b:
                cur_h.append(b)
    return out


# ------------------------------------------------------------------ dane
def load_csv(path):
    with path.open(encoding="utf-8") as f:
        return list(csv.DictReader(f))


def xtts_frontend():
    try:
        from TTS.tts.layers.xtts.tokenizer import multilingual_cleaners
        return lambda t: multilingual_cleaners(t, "pl")
    except Exception as e:  # noqa
        print("Brak TTS - pomijam podgląd normalizacji XTTS:", e)
        return lambda t: ""


def piper_frontend():
    try:
        from piper import PiperVoice
        v = PiperVoice.load(str(ROOT / "voices" / "pl_PL-darkman-medium.onnx"))
        return lambda t: " | ".join("".join(s) for s in v.phonemize(t))
    except Exception as e:  # noqa
        print("Brak Pipera - pomijam fonemy:", e)
        return lambda t: ""


XTTS_BUG_PATTERNS = [  # wykrywanie znanych problemów normalizacji tekstu w XTTS (tekst po cleanerze)
    (r"\bpan\b|\bpani\b|panin", "skrót 'm.'/'p.' zamieniony na 'pan'/'pani'"),
    (r"przecinek \w+\.\w", "data dd.mm.rrrr czytana jako ułamek ('przecinek')"),
    (r"\w:\w", "godzina hh:mm - dwukropek pozostawiony w tekście"),
    (r"\b(ul|pl|godz|ok|nr|tj|np|itp|tel|sob|pn|pt|gł|odj|wag|tyg|kat|wys|str|pd|inż|temp|max|tzw|szt|wew|centr|r|w|s)\.",
     "skrót z kropką nierozwinięty (model musi zgadywać)"),
    (r"[a-ząćęłńóśźż](zero|jeden|dwa|trzy|cztery|pięć|sześć|siedem|osiem|dziewięć|dziesięć|tysiąc\w*)",
     "liczba sklejona z wyrazem (np. 'ddrpięć', 'czteryk')"),
    (r"(milion\w*|miliard\w*)", "duża liczba rozwinięta przez num2words"),
]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--no-audio", action="store_true", help="nie twórz ponownie nagrań do odsłuchu")
    args = ap.parse_args()
    RES.mkdir(parents=True, exist_ok=True)

    files = sorted(p for p in DATA.rglob("*") if p.is_file() and p.suffix in TEXT_SUFFIXES)
    timings = {e: {r["file"]: r for r in load_csv(OUT / f"timings_{e}.csv")} for e in ENGINES}
    trans = {(r["engine"], r["wav"]): r["text"] for r in load_csv(OUT / "transcripts.csv")}
    xtts_in, piper_ph = xtts_frontend(), piper_frontend()

    # ---------------- front-end tekstowy (deterministycznie)
    frontend = [{"fragment": c[0], "expected": c[1], "piper_verdict": c[2], "piper_says": c[3],
                 "piper_ipa": piper_ph(c[0]), "xtts_verdict": c[4], "xtts_note": c[5], "xtts_input": xtts_in(c[0])}
                for c in FRONTEND_CASES]

    # ---------------- wszystkie nagrania
    rows, phrase_cnt = [], {e: Counter() for e in ENGINES}
    for f in files:
        rel = f.relative_to(DATA).as_posix()
        text = read_text(f)
        ref_n = normalize(text)
        row = {"file": rel, "author": rel.split("/")[0], "category": category_of(f), "selected": rel in SELECTED,
               "text": text, "ref_norm": ref_n, "xtts_input": xtts_in(text), "piper_phonemes": piper_ph(text)}
        for e in ENGINES:
            wav = target_name(f, DATA, e)
            hyp = trans.get((e, wav), "")
            hyp_n = normalize(hyp)
            m = wer_cer(ref_n, hyp_n)
            t = timings[e].get(rel, {})
            row.update({
                f"{e}_wav": wav, f"{e}_hyp": hyp, f"{e}_hyp_norm": hyp_n,
                f"{e}_wer": m["wer"], f"{e}_wer_stem": m["wer_stem"], f"{e}_cer": m["cer"],
                f"{e}_errors": m["errors"], f"{e}_S": m["S"], f"{e}_D": m["D"], f"{e}_I": m["I"],
                f"{e}_time": float(t.get("synth_time_s", "nan")), f"{e}_audio": float(t.get("audio_s", "nan")),
                f"{e}_rtf": float(t.get("rtf", "nan") or "nan"), f"{e}_all_times": t.get("all_times_s", ""),
            })
            row[f"{e}_phrases"] = error_phrases(ref_n, hyp_n)
            for a, b in row[f"{e}_phrases"]:
                phrase_cnt[e][(a, b)] += 1
        row["ref_words"] = len(ref_n.split())
        row["xtts_bugs"] = "; ".join(sorted({d for p, d in XTTS_BUG_PATTERNS if re.search(p, row["xtts_input"])}))
        rows.append(row)
    by_file = {r["file"]: r for r in rows}

    # anomalia długości (s audio / znak) - halucynacje, czytanie cyfra po cyfrze
    for e in ENGINES:
        ratios = [r[f"{e}_audio"] / len(r["text"]) for r in rows]
        med = statistics.median(ratios)
        for r, q in zip(rows, ratios):
            r[f"{e}_len_ratio"] = q / med

    with (RES / "auto_wszystkie.csv").open("w", newline="", encoding="utf-8") as fh:
        keys = [k for k in rows[0] if not k.endswith("_phrases")]
        w = csv.DictWriter(fh, fieldnames=keys, extrasaction="ignore")
        w.writeheader()
        w.writerows(rows)

    # ---------------- sondy dla 30 wybranych
    probes = []
    sample_ids = {}
    for idx, (rel, (reason, plist)) in enumerate(SELECTED.items(), 1):
        sid = f"S{idx:02d}"
        sample_ids[rel] = sid
        r = by_file[rel]
        for cat, frag, exp, rx in plist:
            pr = {"sample": sid, "file": rel, "cat": cat, "fragment": frag, "expected": exp, "regex": rx}
            for e in ENGINES:
                pr[e] = "OK" if re.search(rx, r[f"{e}_hyp_norm"]) else "BŁĄD?"
            probes.append(pr)
    with (RES / "sondy.csv").open("w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=list(probes[0].keys()))
        w.writeheader()
        w.writerows(probes)

    # ---------------- anonimizacja: S01_A.wav / S01_B.wav
    rng = random.Random(2026)
    key = []
    for rel, sid in sample_ids.items():
        order = ENGINES[:]
        rng.shuffle(order)
        for lab, e in zip("AB", order):
            key.append({"id": f"{sid}_{lab}", "sample": sid, "label": lab, "engine": e, "file": rel,
                        "src": OUT / e / by_file[rel][f"{e}_wav"]})
    if not args.no_audio:
        if BLIND.exists():
            shutil.rmtree(BLIND)
        BLIND.mkdir(parents=True)
        for k in key:
            # wspólny format: WAV 24 kHz mono 16 bit, wyrównana głośność (EBU R128, -20 LUFS)
            subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-i", str(k["src"]), "-af",
                            "loudnorm=I=-20:TP=-2:LRA=11", "-ar", "24000", "-ac", "1", "-sample_fmt", "s16",
                            "-map_metadata", "-1", "-fflags", "+bitexact", str(BLIND / f"{k['id']}.wav")], check=True)
        with (BLIND / "klucz_NIE_OTWIERAC.csv").open("w", newline="", encoding="utf-8") as fh:
            w = csv.writer(fh)
            w.writerow(["id", "system", "plik_tekstu"])
            for k in key:
                w.writerow([k["id"], ENGINE_LABEL[k["engine"]], k["file"]])
        (BLIND / "teksty.txt").write_text(
            "\n\n".join(f"{sid}: {by_file[rel]['text']}" for rel, sid in sample_ids.items()) + "\n", encoding="utf-8")

    # ---------------- zestawienie wybranych próbek
    md = ["# Wybór 30 próbek do odsłuchu\n",
          "| ID | plik | kat. | powód wyboru | sondy | tekst |", "|---|---|---|---|---|---|"]
    for rel, (reason, plist) in SELECTED.items():
        md.append(f"| {sample_ids[rel]} | {rel} | {CAT_NAMES[by_file[rel]['category']]} | {reason} | {len(plist)} | "
                  f"{by_file[rel]['text'].replace('|', '/')} |")
    cnt = Counter(CAT_NAMES[by_file[rel]["category"]] for rel in SELECTED)
    md.append("\nRozkład kategorii: " + ", ".join(f"{k}: {v}" for k, v in sorted(cnt.items())))
    pc = Counter(p["cat"] for p in probes)
    md.append("\nSondy wg kategorii błędu: " + ", ".join(f"{CATS[k]}: {v}" for k, v in sorted(pc.items())) + "\n")
    (RES / "wybor_30_probek.md").write_text("\n".join(md), encoding="utf-8")

    # ---------------- ciekawe przypadki (automatyczne)
    findings = collect_findings(rows, probes, sample_ids, phrase_cnt)
    (RES / "ciekawe_przypadki.md").write_text(findings_md(findings, rows, probes, phrase_cnt, frontend), encoding="utf-8")

    from build_xlsx import build
    build(RES / "ocena_TTS.xlsx", rows, probes, key, sample_ids, findings, phrase_cnt, frontend)
    print("Gotowe:", RES / "ocena_TTS.xlsx")


def collect_findings(rows, probes, sample_ids, phrase_cnt):
    f = []
    sel = {r["file"]: r for r in rows if r["selected"]}
    # 1. sondy różnicujące systemy
    for p in probes:
        if p["piper"] != p["xtts"]:
            bad = "Piper" if p["piper"] != "OK" else "XTTS-v2"
            r = sel[p["file"]]
            hyp = r["piper_hyp" if bad == "Piper" else "xtts_hyp"]
            f.append({"typ": f"sonda {CATS[p['cat']]}", "probka": p["sample"], "plik": p["file"],
                      "opis": f"„{p['fragment']}” (oczekiwane: {p['expected']}) - prawdopodobny błąd: {bad}",
                      "dowod": hyp})
    for p in probes:
        if p["piper"] != "OK" and p["xtts"] != "OK":
            f.append({"typ": f"sonda {CATS[p['cat']]} (oba)", "probka": p["sample"], "plik": p["file"],
                      "opis": f"„{p['fragment']}” (oczekiwane: {p['expected']}) - oba systemy prawdopodobnie błędnie",
                      "dowod": "Piper: " + sel[p["file"]]["piper_hyp"] + " || XTTS: " + sel[p["file"]]["xtts_hyp"]})
    # 2. błędy normalizacji XTTS (deterministyczne)
    for r in rows:
        if r["xtts_bugs"] and r["selected"]:
            f.append({"typ": "normalizacja XTTS", "probka": sample_ids.get(r["file"], ""), "plik": r["file"],
                      "opis": r["xtts_bugs"], "dowod": "tekst po normalizacji XTTS: " + r["xtts_input"]})
    # 3. anomalie długości / wysoki WER
    for e in ENGINES:
        for r in rows:
            if r[f"{e}_len_ratio"] > 1.6 or r[f"{e}_wer"] > 0.35:
                f.append({"typ": f"anomalia {ENGINE_LABEL[e]}", "probka": sample_ids.get(r["file"], "(auto)"),
                          "plik": r["file"],
                          "opis": f"WER {r[f'{e}_wer']:.0%}, długość audio {r[f'{e}_len_ratio']:.1f}× mediany "
                                  f"(możliwe czytanie cyfra po cyfrze, halucynacja, pominięcie fragmentu)",
                          "dowod": r[f"{e}_hyp"]})
    return f


def findings_md(findings, rows, probes, phrase_cnt, frontend):
    lines = ["# Ciekawe przypadki (wykryte automatycznie)\n",
             "Wygenerowane przez `evaluate.py` na podstawie transkrypcji Whisper large-v3. "
             "„BŁĄD?” oznacza, że w transkrypcji nie znaleziono oczekiwanej formy - **wymaga potwierdzenia odsłuchem**.\n"]
    for e in ENGINES:
        tot_e = sum(r[f"{e}_errors"] for r in rows)
        tot_w = sum(r["ref_words"] for r in rows)
        sel = [r for r in rows if r["selected"]]
        ok = sum(p[e] == "OK" for p in probes)
        lines.append(f"- **{ENGINE_LABEL[e]}**: WER (wszystkie {len(rows)} nagrań) = {tot_e / tot_w:.1%}, "
                     f"WER (30 wybranych) = {sum(r[f'{e}_errors'] for r in sel) / sum(r['ref_words'] for r in sel):.1%}, "
                     f"sondy zaliczone automatycznie: {ok}/{len(probes)}, "
                     f"mediana czasu generowania = {statistics.median(r[f'{e}_time'] for r in rows):.3f} s, "
                     f"mediana RTF = {statistics.median(r[f'{e}_rtf'] for r in rows):.3f}")
    lines.append("\n## Front-end tekstowy: jak każdy system czyta trudne zapisy (deterministycznie)\n")
    lines.append("Piper: fonemy eSpeak-NG (dokładnie to zostanie wypowiedziane). XTTS: tekst po wbudowanej normalizacji "
                 "(to dostaje model; MODEL = skrót nierozwinięty, model zgaduje - sprawdzić odsłuchem).\n")
    for e in ("piper", "xtts"):
        c = Counter(f[f"{e}_verdict"] for f in frontend)
        lines.append(f"- {ENGINE_LABEL[e]}: " + ", ".join(f"{k} {v}" for k, v in c.most_common()) + f" (z {len(frontend)})")
    lines.append("\n| zapis | oczekiwane | Piper | Piper mówi | XTTS | XTTS dostaje |\n|---|---|---|---|---|---|")
    for f in frontend:
        lines.append(f"| `{f['fragment']}` | {f['expected']} | **{f['piper_verdict']}** | {f['piper_says']} | "
                     f"**{f['xtts_verdict']}** | `{f['xtts_input']}` |")
    lines.append("\n## Sondy i anomalie\n")
    lines.append("| typ | próbka | plik | opis | transkrypcja / dowód |\n|---|---|---|---|---|")
    for x in findings:
        d = x["dowod"].replace("|", "/")
        lines.append(f"| {x['typ']} | {x['probka']} | {x['plik']} | {x['opis']} | {d[:400]} |")
    lines.append("\n## Najczęstsze różnice tekst wzorcowy → transkrypcja\n")
    for e in ENGINES:
        lines.append(f"\n### {ENGINE_LABEL[e]}\n\n| wzorzec | transkrypcja | ile razy |\n|---|---|---|")
        for (a, b), c in phrase_cnt[e].most_common(40):
            lines.append(f"| {a or '∅'} | {b or '∅'} | {c} |")
    return "\n".join(lines) + "\n"


if __name__ == "__main__":
    main()
