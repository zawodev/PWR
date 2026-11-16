# Ćwiczenie 2 – badanie porównawcze TTS: Piper vs XTTS-v2

Grupa: Aleksander Stepaniuk, Mieszko Szczekla. Kontekst: asystent sklepu komputerowego pomagający złożyć komputer.

## Systemy i konfiguracja

| | Piper | XTTS-v2 (Coqui) |
|---|---|---|
| Model / głos | `pl_PL-darkman-medium` (męski) | `xtts_v2`, speaker `Claribel Dervla` (żeński), `language="pl"` |
| Sprzęt | CPU | GPU (CUDA, RTX 5070 Ti) |
| Tempo / parametry | domyślne | domyślne |
| Front-end tekstu | eSpeak-NG (własne reguły liczb/skrótów) | uproszczona normalizacja: num2words + 5 skrótów (`p.`→pani, `m.`→pan, `dr.`→doktor...) |
| Format wyjściowy | WAV 22,05 kHz | WAV 24 kHz |

Do odsłuchu oba systemy są sprowadzone do wspólnego formatu (WAV 24 kHz mono 16 bit, głośność -20 LUFS) i zanonimizowane (A/B losowo dla każdej próbki).

## Pipeline (kolejność uruchamiania)

```bash
.venv/bin/python main.py -y --repeat 3   # synteza 160 tekstów × 2 systemy + pomiar czasu -> output/{piper,xtts}/, output/timings_*.csv
.venv/bin/python transcribe.py --beams 1 # Whisper large-v3 (lokalnie, GPU) -> output/transcripts.csv
.venv/bin/python evaluate.py             # WER/CER, sondy, front-end, anonimizacja, arkusz -> output/wyniki/, output/odsluch/
```

Pliki:
- `main.py` – synteza + pomiar czasu (kryt. 7): od przekazania tekstu do zapisu WAV, po rozgrzewce, 3 powtórzenia → mediana.
- `transcribe.py` – ponowna transkrypcja wszystkich 320 nagrań Whisperem.
- `pl_norm.py` – normalizator polski (cyfry, daty, godziny, skróty → słowa), stosowany symetrycznie do wzorca i transkrypcji.
- `selection.py` – wybór 30 próbek, 159 „sond” (trudne fragmenty z oczekiwaną wymową) i 42 przypadki przeglądu front-endu.
- `evaluate.py` + `build_xlsx.py` – analiza i arkusz.

## Wybór 30 próbek

10 naszych + 15 z bazy grupy + 5 dopisanych w `data/Additional/` (pełna lista z uzasadnieniem: `output/wyniki/wybor_30_probek.md`).
Nasze teksty mają liczby zapisane słownie i nie zawierają skrótów/cyfr, dlatego pozostałe 20 dobrano pod luki:

- **skróty**: `ul.`, `pl.`, `pn.–pt.`, `sob.`, `dr inż.`, `drem`, `m.in.`, `tj.`, `np.`, `itp.`, `str. pd.`, `Gł.`, `odj.`, `wag.`, `m.`, `s.`, `nr`, `Tel.`, `max.`, `XXI w.`
- **skrótowce / nazwy o specyficznej wymowie**: PKO BP, AMD, MSI, USB-C, HDMI, SSD NVMe, M.2, DPD, KFC, IC, C-HR, B2, 4K, DDR
- **duże liczby cyframi**: `943 492 412`, `43 436 324`, `21 760 000 000`, `16384`, `129 900 zł` (oraz kontrastowo numery telefonów/kont)
- **słowa zmieniające wydźwięk / intonacja**: para pytanie–stwierdzenie z tymi samymi słowami, „tylko/aż”, „ledwo”, „niestety / na szczęście”, wielokropek
- **daty, godziny, jednostki, symbole**: `15.12.2026 r.`, `14:30`, `°C`, `⅓`, `l/100 km`, `24/7`, `×`, `=`, `27"`
- **wyrazy obce i spolszczone**: upgrade'zie, overclockingu, iPhone'em, equalizer, Crème brûlée, Piña Colada, „Why should we hire you?”
- **stabilność**: najdłuższy tekst w bazie (~1000 znaków, zdania > 224 znaków – limit XTTS dla pl)

## Wyniki wstępne (obiektywne, przed odsłuchem)

| | Piper | XTTS-v2 |
|---|---|---|
| Mediana czasu generowania / wypowiedź | **0,31 s** | 4,34 s |
| Średni RTF | **0,026** (~38× szybciej niż czas rzeczywisty) | 0,306 (~3×) |
| Znaki / s | **~511** | ~36 |
| WER auto – wszystkie 160 nagrań | **10,4%** | 13,4% |
| WER auto – 30 wybranych | **16,4%** | 22,7% |
| Sondy zaliczone automatycznie | **102/159** | 92/159 |
| Front-end: poprawnie odczytane trudne zapisy (42) | 8 OK + 8 częściowo | 3 OK + 2 częściowo (22 nierozwinięte → model zgaduje) |

Najwięcej błędów w obu systemach: kategoria **3-numbers** (WER 18% vs 27%). Najmniej: krótkie komunikaty i pytania (4–6%).

### Najciekawsze przypadki (do potwierdzenia odsłuchem)

**XTTS-v2**
- Reguła normalizacji `m.` → „pan”: `M.2` → „pandwa” (Whisper: „złącza PAN-2”), `m.in.` → „panin”, `m. 42` (miejsce) → „pan czterdzieści dwa”.
- Daty `15.12.2026` → „piętnaście **przecinek** dwanaście.dwa tysiące…”, godziny `14:30` → „czternaście:trzydzieści”.
- Duże liczby czytane grupami bez „milionów/tysięcy”: `943 492 412` → „dziewięćset czterdzieści trzy, czterysta dziewięćdziesiąt dwa, …”; `21 760 000 000` → „dwadzieścia jeden siedemset sześćdziesiąt zero zero”.
- Sklejenia: `DDR5` → „ddrpięć”, `4K` → „czteryk”, `6E` → „sześće”.
- Skróty bez rozwinięcia (`ul.`, `pn.–pt.`, `tj.`, `zł`, `godz.`) – model improwizuje: `pn.–pt.` → „pnięta. Ptyn. Pani tu na nas uda”.
- Halucynacje: po „Why should we hire you?” dopowiedziane „I don't know”; po „Uwaga!” bełkot („Daj naka, sył”); w S23 dopisane „Bessie. Kini?”.
- Plus: lepiej wymawia angielskie nazwy (overclocking, benchmark, Cinebench, Tiguan, Kodiaq) i całe angielskie zdanie.

**Piper**
- Duże liczby czytane poprawnie („…miliony …tysiące…”, „…miliardów…”), ale z tego samego powodu **numery telefonów** czyta jako liczby: `799 267 267` → „siedemset dziewięćdziesiąt dziewięć milionów…”.
- `zł` → „zet eł” (we wszystkich kwotach! Whisper tego nie wykrywa, bo zapisuje „zł”), `r.` → „er”, `godz.` → „gocz”, `nr` → „en er”, `ul.` → „ul”, `pl.` → „pe el”, `m.in.` → „em kropka in”, `pn.–pt.` → „pe en kropka pe te”.
- `PKO BP` → „pko be pe” („PKO” jako słowo), `⅓` → „wan third” (po angielsku), `l/100 km` → „el slesz sto ka em”, `XXI w.` → „ksksi wy”.
- Daty liczebnikami głównymi: `15.12.2026 r.` → „piętnaście dwanaście dwa tysiące dwadzieścia sześć er”.
- Słaba wymowa obcych nazw: „Vengeance” → „w engrance”, „DDR” → „DDL/DDE”, „Tiguana” → „T1”, angielskie zdanie czytane po polsku („w Hiszoldwech i Ryjou”).
- Plus: `dr inż.` → „doktor inżynier”, `np.`, `itp.`, `ok.` poprawnie.

**Oba**: „drem” zamiast „doktorem”, `27"` bez „cali”, `w 1. tygodniu` → „jeden”.

## Zastrzeżenia metodologiczne
- Whisper ma silny model językowy: potrafi „naprawić” błędną wymowę i zapisuje liczby cyframi, więc wynik automatyczny to **dolne oszacowanie** błędów. Dlatego dla Pipera dodatkowo analizowane są fonemy eSpeak (deterministyczne), a 30 próbek jest weryfikowanych odsłuchem.
- WER zawiera szum normalizacji/odmiany przez przypadki – ten sam wzorzec dla obu systemów, więc porównanie względne jest uczciwe.
- Transkrypcja z dekodowaniem zachłannym (beam 1) – podczas transkrypcji GPU było częściowo zajęte przez inną aplikację.
- XTTS jest niedeterministyczny (próbkowanie); zapisany plik to ostatnie z 3 wygenerowań.
- Głosy różnią się płcią – pełna anonimizacja nie jest możliwa.
