"""Zbiera dane do raportu i prezentacji -> raport/skrypty/dane.json
Wejście: wypełniony arkusz ocen (skonwertowany do xlsx), output/wyniki/auto_wszystkie.csv, sondy.csv
Użycie: python dane.py <ocena_TTS_wypelniona.xlsx>
"""
import csv, json, statistics, sys
from pathlib import Path
from openpyxl import load_workbook

ROOT = Path(__file__).resolve().parents[2]
xlsx = sys.argv[1]
wb = load_workbook(xlsx, data_only=True)
key = {r[0]: r[1] for r in wb["Klucz"].iter_rows(min_row=3, values_only=True) if r[0]}
auto = {r["file"]: r for r in csv.DictReader(open(ROOT / "output/wyniki/auto_wszystkie.csv", encoding="utf-8"))}
EN = {"Piper": "piper", "XTTS-v2": "xtts"}

# kolumny arkusza Oceny (1-indeksowane): kryteria 2,3,4,5,8 -> średnia w kolumnach 10,13,16,19,22
CRIT = {"2": 8, "3": 11, "4": 14, "5": 17, "8": 20}  # kolumna "Osoba 1"
ERR = ["L", "D", "S", "N", "O", "W", "A"]
rows = []
for r in wb["Oceny"].iter_rows(min_row=3, max_row=62, values_only=True):
    rid, sample = r[0], r[1]
    system = key[rid]
    d = {"id": rid, "sample": sample, "system": system, "category": r[3]}
    for c, col in CRIT.items():
        o1, o2 = r[col - 1], r[col]
        d[f"k{c}_o1"], d[f"k{c}_o2"] = o1, o2
        d[f"k{c}"] = (o1 + o2) / 2
    for i, e in enumerate(ERR):
        d[f"err_{e}"] = r[23 + i] or 0
    d["err_sum"] = sum(d[f"err_{e}"] for e in ERR)
    rows.append(d)
fmap = {r[0]: r[2] for r in wb["Klucz"].iter_rows(min_row=3, values_only=True) if r[0]}
for d in rows:
    f = fmap[d["id"]]
    a = auto[f]
    e = EN[d["system"]]
    d.update(file=f, text=a["text"], hyp=a[f"{e}_hyp"], wer=float(a[f"{e}_wer"]),
             time=float(a[f"{e}_time"]), audio=float(a[f"{e}_audio"]), rtf=float(a[f"{e}_rtf"]),
             wav=f"output/{e}/{a[f'{e}_wav']}")

# uwagi z odsłuchu (arkusz Sondy)
notes = []
for r in wb["Sondy"].iter_rows(min_row=3, values_only=True):
    if r[0] and any(r[i] not in (None, "") for i in (7, 8, 9)):
        notes.append({"sample": r[0], "file": r[1], "cat": r[2], "fragment": r[3], "expected": r[4],
                      "piper": r[7], "xtts": r[8], "comment": r[9]})

stab = {r[0]: {"o1": r[1], "o2": r[2], "avg": r[3]} for r in wb["Stabilnosc"].iter_rows(min_row=5, max_row=6, values_only=True)}

# statystyki dla wszystkich 160 nagrań
allstat = {}
for e, lab in (("piper", "Piper"), ("xtts", "XTTS-v2")):
    t = [float(a[f"{e}_time"]) for a in auto.values()]
    rtf = [float(a[f"{e}_rtf"]) for a in auto.values()]
    err = sum(int(a[f"{e}_errors"]) for a in auto.values())
    words = sum(int(a["ref_words"]) for a in auto.values())
    bycat = {}
    for a in auto.values():
        bycat.setdefault(a["category"], []).append(float(a[f"{e}_time"]))
    allstat[lab] = {"time_mean": statistics.mean(t), "time_median": statistics.median(t), "time_min": min(t),
                    "time_max": max(t), "rtf_mean": statistics.mean(rtf), "wer_all": err / words,
                    "time_by_cat": {k: statistics.mean(v) for k, v in sorted(bycat.items())}}
json.dump({"rows": rows, "notes": notes, "stab": stab, "all": allstat, "n_texts": len(auto)},
          open(Path(__file__).with_name("dane.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)

# krótkie podsumowanie na ekran
for lab in ("Piper", "XTTS-v2"):
    rr = [d for d in rows if d["system"] == lab]
    print(lab, {c: round(statistics.mean(d[f"k{c}"] for d in rr), 2) for c in CRIT},
          "błędy", {e: sum(d[f"err_{e}"] for d in rr) for e in ERR}, "suma", sum(d["err_sum"] for d in rr),
          "WER30", round(statistics.mean(d["wer"] for d in rr), 3))
print(allstat)
