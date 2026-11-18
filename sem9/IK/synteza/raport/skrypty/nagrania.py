"""Kopiuje wybrane (ciekawe) nagrania do raport/nagrania/ pod nazwami używanymi w raporcie i prezentacji."""
import json, shutil
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
D = json.load(open(HERE / "dane.json", encoding="utf-8"))
by = {(r["sample"], r["system"]): r for r in D["rows"]}

# (nr, próbka, system, krótki opis do nazwy pliku, opis do raportu)
NAGRANIA = [
    (1, "S14", "Piper", "skroty_pn-pt", "skróty „ul.”, „pn.–pt.”, „sob.” – czytane jako litery/„kropka”"),
    (2, "S14", "XTTS-v2", "skroty_pn-pt", "skróty „pn.–pt.” – zamiast słów losowe dźwięki"),
    (3, "S17", "Piper", "data", "data „15.11.2026 r.” – liczebniki, końcówka „er”"),
    (4, "S17", "XTTS-v2", "data", "data „15.11.2026 r.” – czytana jak ułamek („przecinek”)"),
    (5, "S28", "Piper", "duze_liczby", "„943 492 412” – poprawnie, z milionami i tysiącami"),
    (6, "S28", "XTTS-v2", "duze_liczby", "„943 492 412” – trzy osobne grupy cyfr"),
    (7, "S23", "Piper", "wyrazy_obce", "„Crème brûlée”, „barbeque” – czytane po polsku"),
    (8, "S23", "XTTS-v2", "wyrazy_obce", "„Crème brûlée”, „Piña Colada” – wymowa zbliżona do oryginału"),
    (9, "S30", "Piper", "spolszczenia", "„overclockingu”, „Twitchu” – czytane po polsku, litera po literze"),
    (10, "S30", "XTTS-v2", "spolszczenia", "„overclockingu”, „Twitchu” – wymowa angielska"),
    (11, "S27", "Piper", "akronimy_M2", "„PKO BP”, „M.2”, „GeForce” – akronimy"),
    (12, "S27", "XTTS-v2", "akronimy_M2", "„M.2” zamienione przez normalizację XTTS na „pan dwa”"),
]

out = ROOT / "raport" / "nagrania"
out.mkdir(parents=True, exist_ok=True)
lista = []
for nr, smp, sy, slug, opis in NAGRANIA:
    r = by[(smp, sy)]
    name = f"Nagranie_{nr:02d}_{'Piper' if sy == 'Piper' else 'XTTS'}_{slug}.wav"
    shutil.copy2(ROOT / r["wav"], out / name)
    lista.append({"nr": nr, "plik": name, "sample": smp, "system": sy, "opis": opis, "tekst": r["text"]})
json.dump(lista, open(HERE / "nagrania.json", "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print("\n".join(x["plik"] for x in lista))
