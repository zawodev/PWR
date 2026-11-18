"""Generuje raport/Raport_TTS.docx (python-docx) + wykres do raportu (matplotlib).
Użycie: python raport.py   (wymaga dane.json i nagrania.json z dane.py / nagrania.py)
"""
import json
import statistics
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from docx import Document
from docx.enum.section import WD_ORIENT
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_CELL_VERTICAL_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Cm, Pt, RGBColor

HERE = Path(__file__).resolve().parent
OUT = HERE.parent / "Raport_TTS.docx"
D = json.load(open(HERE / "dane.json", encoding="utf-8"))
NAG = json.load(open(HERE / "nagrania.json", encoding="utf-8"))
rows = D["rows"]
SYS = ["Piper", "XTTS-v2"]
RED, GRAY = "#A7190E", "#A6A6A6"
PA, XA = D["all"]["Piper"], D["all"]["XTTS-v2"]
CAT = {"1-info": "Komunikat", "2-qna": "Pytanie", "3-numbers": "Liczby", "4-long": "Długa", "5-unique-foreign": "Obce/nazwy"}


def pl(x, n=2):
    return f"{x:.{n}f}".replace(".", ",")


def avg(sy, key, cat=None):
    v = [r[key] for r in rows if r["system"] == sy and (cat is None or r["category"] == cat)]
    return sum(v) / len(v)


def subj(r):
    return sum(r[k] for k in ("k2", "k3", "k4", "k5", "k8")) / 5


TOT = {sy: sum(r["err_sum"] for r in rows if r["system"] == sy) for sy in SYS}
ERRS = {sy: {e: sum(r[f"err_{e}"] for r in rows if r["system"] == sy) for e in "LDSNO"} for sy in SYS}
WER30 = {sy: statistics.mean(r["wer"] for r in rows if r["system"] == sy) for sy in SYS}

# ------------------------------------------------------------------ wykres
crit = [("Zrozumiałość", "k2"), ("Naturalność", "k3"), ("Intonacja", "k4"), ("Płynność", "k5"),
        ("Przydatność\nw dialogu", "k8")]
labels = [c for c, _ in crit] + ["Stabilność"]
vals = {sy: [avg(sy, k) for _, k in crit] + [D["stab"][sy]["avg"]] for sy in SYS}
plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 10})
fig, ax = plt.subplots(figsize=(7.5, 3.4), dpi=200)
w = 0.38
for i, (sy, col) in enumerate(zip(SYS, (RED, GRAY))):
    xs = [j + (i - 0.5) * w for j in range(len(labels))]
    bars = ax.bar(xs, vals[sy], w * 0.94, color=col, label=sy)
    for b, v in zip(bars, vals[sy]):
        ax.text(b.get_x() + b.get_width() / 2, v + 0.06, pl(v), ha="center", va="bottom", fontsize=8, color="#262626")
ax.set_xticks(range(len(labels)), labels)
ax.set_ylim(0, 5)
ax.set_ylabel("średnia ocena (1–5)", color="#595959")
ax.yaxis.grid(True, color="#D9D9D9", linewidth=0.8)
ax.set_axisbelow(True)
for sp in ("top", "right", "left"):
    ax.spines[sp].set_visible(False)
ax.spines["bottom"].set_color("#BFBFBF")
ax.tick_params(colors="#404040", length=0)
ax.legend(frameon=False, ncol=2, loc="upper center", bbox_to_anchor=(0.5, 1.12))
fig.tight_layout()
CHART = HERE / "wykres_oceny.png"
fig.savefig(CHART)

# ------------------------------------------------------------------ dokument
doc = Document()
st = doc.styles["Normal"]
st.font.name = "Arial"
st.font.size = Pt(10.5)
st.element.rPr.rFonts.set(qn("w:eastAsia"), "Arial")
st.paragraph_format.space_after = Pt(6)
st.paragraph_format.line_spacing = 1.15
for name, size, before in (("Title", 22, 0), ("Heading 1", 16, 16), ("Heading 2", 13, 10)):
    s = doc.styles[name]
    s.font.name = "Arial"
    s.font.size = Pt(size)
    s.font.bold = name != "Title"
    s.font.color.rgb = RGBColor(0, 0, 0) if name != "Heading 2" else RGBColor(0x59, 0x59, 0x59)
    rf =s.element.rPr.find(qn("w:rFonts"))
    if rf is not None:
        for a in ("w:asciiTheme", "w:hAnsiTheme", "w:eastAsiaTheme", "w:cstheme"):
            rf.attrib.pop(qn(a), None)
        rf.set(qn("w:ascii"), "Arial")
        rf.set(qn("w:hAnsi"), "Arial")
    s.paragraph_format.space_before = Pt(before)
    s.paragraph_format.space_after = Pt(6)
    s.paragraph_format.keep_with_next = True

sec = doc.sections[0]
sec.page_width, sec.page_height = Cm(21), Cm(29.7)
for m in ("left_margin", "right_margin"):
    setattr(sec, m, Cm(2.2))
sec.top_margin = sec.bottom_margin = Cm(2)


def P(text="", bold_prefix=None, style=None, size=None, align=None):
    p = doc.add_paragraph(style=style)
    if bold_prefix:
        r = p.add_run(bold_prefix)
        r.bold = True
    if text:
        r = p.add_run(text)
        if size:
            r.font.size = Pt(size)
    if align:
        p.alignment = align
    return p


def B(text, bold_prefix=None):
    return P(text, bold_prefix, style="List Bullet")


def shade(cell, hex_):
    tcPr = cell._tc.get_or_add_tcPr()
    sh = OxmlElement("w:shd")
    sh.set(qn("w:val"), "clear")
    sh.set(qn("w:color"), "auto")
    sh.set(qn("w:fill"), hex_)
    tcPr.append(sh)


def cell_text(cell, text, size=10, bold=False, align=None, color=None):
    cell.text = ""
    p = cell.paragraphs[0]
    p.paragraph_format.space_after = Pt(0)
    p.paragraph_format.line_spacing = 1.0
    r = p.add_run(text)
    r.font.size = Pt(size)
    r.bold = bold
    if color:
        r.font.color.rgb = color
    if align:
        p.alignment = align
    cell.vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER


def fix_widths(t, widths):
    """Stały układ tabeli + jawna siatka kolumn (Word i LibreOffice respektują wtedy szerokości)."""
    t.autofit = False
    tblPr = t._tbl.tblPr
    lay = OxmlElement("w:tblLayout")
    lay.set(qn("w:type"), "fixed")
    tblPr.append(lay)
    tw = OxmlElement("w:tblW")
    tw.set(qn("w:w"), str(int(sum(Cm(w) for w in widths) / 635)))
    tw.set(qn("w:type"), "dxa")
    for old in tblPr.findall(qn("w:tblW")):
        tblPr.remove(old)
    tblPr.append(tw)
    grid = t._tbl.tblGrid
    for gc, w in zip(grid.findall(qn("w:gridCol")), widths):
        gc.set(qn("w:w"), str(int(Cm(w) / 635)))
    for row in t.rows:
        for c, w in zip(row.cells, widths):
            c.width = Cm(w)


def table(data, widths, size=10, header_fill="A7190E", num_cols=(), bold_cells=(), spacer=True):
    t = doc.add_table(rows=len(data), cols=len(data[0]))
    t.style = "Table Grid"
    t.alignment = WD_TABLE_ALIGNMENT.CENTER
    for i, row in enumerate(data):
        for j, v in enumerate(row):
            c = t.cell(i, j)
            c.width = Cm(widths[j])
            al = WD_ALIGN_PARAGRAPH.RIGHT if (j in num_cols and i > 0) else None
            if i == 0:
                cell_text(c, v, size, True, color=RGBColor(0xFF, 0xFF, 0xFF))
                shade(c, header_fill)
            else:
                cell_text(c, v, size, (i, j) in bold_cells, al)
    fix_widths(t, widths)
    for row in t.rows[:-1]:
        for c in row.cells:
            for par in c.paragraphs:
                par.paragraph_format.keep_with_next = True
    if spacer:
        doc.add_paragraph()
    return t


# ------------------------------------------------------------------ treść
doc.add_paragraph("Raport: Badanie porównawcze systemów syntezy mowy na potrzeby projektowanych "
                  "interfejsów konwersacyjnych", style="Title")
P(bold_prefix="Autorzy badania")
P("Aleksander Stepaniuk (272644)\nMieszko Szczekla (272688)")

doc.add_heading("1. Wstęp i cel projektu", 1)
P("Celem ćwiczenia było porównanie dwóch systemów syntezy mowy polskiej (TTS – text-to-speech) pod kątem "
  "ich użycia w projektowanym przez nas interfejsie konwersacyjnym. Interfejs ma pomagać klientom sklepu "
  "komputerowego w kompletowaniu podzespołów, dlatego syntezator musi poprawnie czytać nie tylko zwykłe zdania, "
  "ale też nazwy marek i modeli, ceny, daty dostawy, adresy salonów oraz liczne skróty i skrótowce "
  "(np. DDR5, PKO BP, M.2).")
P("Do porównania wybrano dwa systemy, które działają w całości lokalnie, bez wysyłania tekstu do usług "
  "zewnętrznych: lekki syntezator Piper oraz duży, wielojęzyczny model Coqui XTTS-v2. Oceniono je według ośmiu "
  "kryteriów z wytycznych ćwiczenia: poprawności wymowy, zrozumiałości, naturalności brzmienia, intonacji "
  "i prozodii, płynności, stabilności syntezy, szybkości generowania i przydatności w dialogu.")

doc.add_heading("2. Charakterystyka badanych systemów", 1)
doc.add_heading("2.1. Piper", 2)
P("Piper to syntezator oparty na architekturze VITS, wyeksportowanej do formatu ONNX. Tekst jest najpierw "
  "zamieniany na fonemy przez program eSpeak-NG i to właśnie jego reguły decydują o tym, jak czytane są liczby, "
  "skróty i wyrazy obce. Dla każdego języka i głosu istnieje osobny, niewielki model. Synteza działa szybko "
  "na zwykłym procesorze, więc system nadaje się także na słabszy sprzęt.")
doc.add_heading("2.2. Coqui XTTS-v2", 2)
P("XTTS-v2 to duży, wielojęzyczny model autoregresyjny (część językowa typu GPT oraz dekoder dźwięku). "
  "Pozwala sklonować głos z kilkusekundowej próbki, ma też zestaw głosów wbudowanych. Do pracy w rozsądnym "
  "czasie potrzebuje karty graficznej. Przed syntezą tekst przechodzi przez prostą, wbudowaną normalizację: "
  "liczby są zamieniane na słowa biblioteką num2words, a rozwijanych jest tylko kilka skrótów. Wynik syntezy "
  "jest losowy – ten sam tekst za każdym razem brzmi trochę inaczej.")
doc.add_heading("2.3. Konfiguracja", 2)
P("Oba systemy uruchomiono z ustawieniami domyślnymi, bez zmiany tempa mowy, z językiem polskim:").paragraph_format.keep_with_next = True
table([("Parametr", "Piper", "XTTS-v2"),
       ("Głos", "pl_PL-darkman-medium (męski)", "Claribel Dervla, wbudowany (żeński)"),
       ("Rozmiar modelu", "ok. 60 MB", "ok. 1,8 GB"),
       ("Sprzęt", "procesor (CPU)", "karta graficzna (CUDA)"),
       ("Format wyjściowy", "WAV 22,05 kHz, mono", "WAV 24 kHz, mono"),
       ("Normalizacja tekstu", "fonemy z eSpeak-NG", "num2words + kilka skrótów")],
      [4.2, 6, 6.4])

doc.add_heading("3. Przebieg badania", 1)
doc.add_heading("3.1. Zbiór tekstów i wybór próbek", 2)
P(f"Grupa przygotowała wspólną bazę {D['n_texts'] - 5} tekstów (po 5 od każdej osoby: komunikat, pytanie "
  "z odpowiedzią, wypowiedź z liczbami, dłuższa wypowiedź oraz tekst z nazwami własnymi i wyrazami obcymi). "
  "Nasze własne teksty miały wszystkie liczby zapisane słownie i nie zawierały skrótów, dlatego do odsłuchu "
  "dobraliśmy 15 tekstów z bazy, które sprawdzają słabe punkty syntezy (adresy i numery telefonów, daty, "
  "skróty kolejowe, wzory chemiczne, nazwy francuskie i angielskie, bardzo długi tekst). Dopisaliśmy też "
  "5 własnych tekstów z kontekstu sklepu komputerowego: ze skrótami („ul.”, „dr inż.”, „m.in.”), skrótowcami "
  "(PKO BP, AMD, M.2), dużymi liczbami („943 492 412”), słowami zmieniającymi wydźwięk zdania oraz spolszczonymi "
  f"wyrazami obcymi. Łącznie syntezie poddano {D['n_texts']} tekstów, z czego 30 (10 naszych, 15 z bazy "
  "i 5 dopisanych) oceniono odsłuchowo.")
doc.add_heading("3.2. Generowanie mowy i pomiar czasu", 2)
P(f"Wszystkie teksty zsyntezowano oboma systemami ({2 * D['n_texts']} nagrań). Każdy tekst był przekazywany "
  "jako jedno żądanie, a syntezatory działały kolejno, nigdy równocześnie. Czas mierzono od przekazania tekstu "
  "do zapisania gotowego pliku WAV. Przed pomiarami wykonano dwa żądania rozgrzewkowe, każdy tekst zsyntezowano "
  "trzy razy i przyjęto medianę. Czas ładowania modelu nie był wliczany. Badanie przeprowadzono na komputerze "
  "z procesorem AMD Ryzen 7 5800X, 32 GB RAM i kartą NVIDIA RTX 5070 Ti, pod systemem Fedora Linux.")
doc.add_heading("3.3. Ocena odsłuchowa", 2)
P("Sześćdziesiąt nagrań do odsłuchu sprowadzono do wspólnego formatu (WAV 24 kHz, mono, 16 bit) z wyrównaną "
  "głośnością i zanonimizowano – każde oznaczono literą A lub B, przydzieloną losowo dla każdej próbki. Obie "
  "osoby niezależnie oceniły kryteria 2–5 i 8 w pięciostopniowej skali Likerta (5 – bardzo dobrze, 1 – bardzo "
  "słabo); wynikiem jest średnia z obu ocen. Stabilność syntezy (kryterium 6) oceniono raz dla każdego systemu, "
  "po wysłuchaniu wszystkich próbek. Pełna anonimizacja nie była możliwa, bo głosy różnią się płcią.")
doc.add_heading("3.4. Poprawność wymowy", 2)
P("Dla 30 próbek przygotowano listę 159 trudnych fragmentów (np. „dr inż.”, „15.11.2026 r.”, „M.2”) wraz "
  "z oczekiwaną wymową. Nagrania przepisano automatycznie modelem Whisper large-v3 i sprawdzono, czy oczekiwana "
  "forma pojawia się w transkrypcji; najciekawsze przypadki zweryfikowaliśmy odsłuchowo. Błędy przypisano do "
  "kategorii: liczby, daty i godziny, skróty i skrótowce, nazwy własne, wyrazy obce. Dodatkowo dla wszystkich "
  f"{2 * D['n_texts']} nagrań policzono wskaźnik WER (odsetek błędnych słów) między tekstem wejściowym a "
  "transkrypcją, po zamianie cyfr i skrótów na słowa w obu tekstach. Whisper potrafi „poprawić” lekko błędną "
  "wymowę, więc wyniki automatyczne należy traktować raczej jako dolne oszacowanie liczby błędów.")

doc.add_heading("4. Wyniki badań", 1)
doc.add_heading("4.1. Ocena odsłuchowa", 2)
P("Piper uzyskał wyższe średnie oceny we wszystkich kryteriach subiektywnych. Różnice wynoszą od "
  f"{pl(avg('Piper', 'k4') - avg('XTTS-v2', 'k4'))} pkt (intonacja) do "
  f"{pl(avg('Piper', 'k8') - avg('XTTS-v2', 'k8'))} pkt (przydatność w dialogu), a największa jest przy "
  f"stabilności syntezy ({pl(D['stab']['Piper']['avg'], 1)} wobec {pl(D['stab']['XTTS-v2']['avg'], 1)}).")
doc.add_picture(str(CHART), width=Cm(16))
doc.paragraphs[-1].alignment = WD_ALIGN_PARAGRAPH.CENTER
P("Rys. 1. Średnie oceny odsłuchowe (30 próbek, dwie osoby).", size=9, align=WD_ALIGN_PARAGRAPH.CENTER)

doc.add_heading("4.2. Poprawność wymowy", 2)
P(f"W 30 próbkach znaleziono {TOT['Piper']} błędów wymowy u Pipera i {TOT['XTTS-v2']} u XTTS-v2. Średni WER "
  f"dla tych próbek wyniósł {pl(WER30['Piper'] * 100, 1)}% i {pl(WER30['XTTS-v2'] * 100, 1)}%, a dla wszystkich "
  f"nagrań {pl(PA['wer_all'] * 100, 1)}% i {pl(XA['wer_all'] * 100, 1)}%. Rozkład błędów jest różny: XTTS-v2 "
  "częściej myli się przy liczbach i skrótach, Piper – przy nazwach własnych i wyrazach obcych.")
names = {"L": "Liczby", "D": "Daty i godziny", "S": "Skróty i skrótowce", "N": "Nazwy własne", "O": "Wyrazy obce"}
data = [("Kategoria", "Piper", "XTTS-v2")] + [(names[e], str(ERRS["Piper"][e]), str(ERRS["XTTS-v2"][e])) for e in "LDSNO"]
data.append(("Razem", str(TOT["Piper"]), str(TOT["XTTS-v2"])))
table(data, [6, 3, 3], num_cols=(1, 2), bold_cells={(len(data) - 1, 1), (len(data) - 1, 2)})
P("Najczęstsze i najciekawsze błędy (numery nagrań – patrz rozdział 6):")
B("żaden system nie rozwinął skrótów „pn.–pt.”, „ul.”, „tj.”. Piper czyta je jako litery („pe en kropka pet”, "
  "„ul”), a XTTS-v2 przy „pn.–pt.” wygenerował ciąg losowych dźwięków niepodobnych do słów (nagrania 01–02).",
  "Skróty: ")
B("oba systemy czytają „r.” jako „er”. XTTS-v2 czyta datę „15.11.2026” jak ułamek („piętnaście przecinek "
  "jedenaście…”), bo jego normalizacja traktuje kropkę jak separator dziesiętny (nagrania 03–04).", "Daty: ")
B("Piper czyta „943 492 412” poprawnie, z milionami i tysiącami, a XTTS-v2 jako trzy osobne grupy cyfr "
  "(nagrania 05–06). Ta sama reguła działa u Pipera na niekorzyść przy numerach telefonów: „799 267 267” "
  "brzmi jak „siedemset dziewięćdziesiąt dziewięć milionów…”.", "Duże liczby: ")
B("normalizacja XTTS-v2 zamienia skrót „m.” na „pan”, przez co „M.2” staje się „pan dwa”, „m.in.” – „panin”, "
  "a „m. 42” (miejsce w pociągu) – „pan czterdzieści dwa” (nagranie 12).", "Skrót „m.”: ")
B("Piper czyta je po polsku, litera po literze („kremem brule”, „barbegwe”, „owerclockingu”, „twitchu”), "
  "XTTS-v2 – znacznie bliżej oryginału („krem brulej”, „owerklokingu”, „tłitchu”) (nagrania 07–10).",
  "Wyrazy obce: ")
B("„58/3” Piper czyta jako „pięćdziesiąt osiem slesz trzy”, XTTS-v2 pomija ukośnik. Według zapisu "
  "fonetycznego eSpeak-NG Piper czyta też „zł” jako „zet eł”.", "Symbole: ")

doc.add_heading("4.3. Szybkość generowania", 2)
P(f"Piper generował wypowiedź w medianie {pl(PA['time_median'])} s na samym procesorze, XTTS-v2 w "
  f"{pl(XA['time_median'])} s na karcie graficznej, czyli około {round(XA['time_median'] / PA['time_median'])} razy "
  f"wolniej. Średni współczynnik czasu rzeczywistego (RTF – czas generowania podzielony przez długość nagrania) "
  f"wyniósł {pl(PA['rtf_mean'], 3)} dla Pipera i {pl(XA['rtf_mean'], 3)} dla XTTS-v2. Najdłuższe nagranie XTTS "
  f"powstawało {pl(XA['time_max'], 1)} s, co w rozmowie z klientem oznacza wyraźnie odczuwalną przerwę. "
  f"Dla obu systemów czas rośnie z długością tekstu: od {pl(PA['time_by_cat']['1'])} s / "
  f"{pl(XA['time_by_cat']['1'])} s dla krótkich komunikatów do {pl(PA['time_by_cat']['4'])} s / "
  f"{pl(XA['time_by_cat']['4'])} s dla długich wypowiedzi.")
doc.add_heading("4.4. Stabilność syntezy", 2)
cm = list(CAT)
rng = {sy: max(statistics.mean(subj(r) for r in rows if r["system"] == sy and r["category"] == c) for c in cm)
       - min(statistics.mean(subj(r) for r in rows if r["system"] == sy and r["category"] == c) for c in cm) for sy in SYS}
P(f"Stabilność oceniliśmy na {pl(D['stab']['Piper']['avg'], 1)} pkt dla Pipera i "
  f"{pl(D['stab']['XTTS-v2']['avg'], 1)} pkt dla XTTS-v2. Oba systemy najsłabiej wypadły na tekstach z liczbami "
  "i skrótami. Rozrzut średnich ocen między typami wypowiedzi był nawet nieco większy u Pipera "
  f"({pl(rng['Piper'])} pkt wobec {pl(rng['XTTS-v2'])} pkt), ale to XTTS-v2 sprawiał wrażenie mniej "
  "przewidywalnego: przy podobnych tekstach raz brzmiał poprawnie, a raz pojawiały się zniekształcenia, "
  "zmiany tempa lub losowe dźwięki. Piper brzmi bardziej mechanicznie, ale za każdym razem podobnie.")

doc.add_heading("4.5. Zestawienie", 2)
data = [("Kryterium", "Piper", "XTTS-v2"),
        ("1. Poprawność wymowy (liczba błędów)", str(TOT["Piper"]), str(TOT["XTTS-v2"]))]
for k, n in (("k2", "2. Zrozumiałość"), ("k3", "3. Naturalność"), ("k4", "4. Intonacja i prozodia"), ("k5", "5. Płynność")):
    data.append((n, pl(avg("Piper", k)), pl(avg("XTTS-v2", k))))
data += [("6. Stabilność syntezy", pl(D["stab"]["Piper"]["avg"]), pl(D["stab"]["XTTS-v2"]["avg"])),
         ("7. Szybkość generowania (mediana)", pl(PA["time_median"]) + " s", pl(XA["time_median"]) + " s"),
         ("8. Przydatność w dialogu", pl(avg("Piper", "k8")), pl(avg("XTTS-v2", "k8")))]
table(data, [8, 3.5, 3.5], num_cols=(1, 2), bold_cells={(i, 1) for i in range(1, len(data))})
P("Pogrubiono lepszy wynik w każdym kryterium.", size=9)

doc.add_heading("5. Wnioski i werdykt", 1)
P("Z przeprowadzonego badania wynikają następujące wnioski:")
for t, b in [
    ("Piper wypadł lepiej we wszystkich ośmiu kryteriach. W ocenach odsłuchowych przewaga wynosiła od około "
     "0,2 do 0,5 pkt, a przy stabilności – 1 pkt. Jego mowa jest bardziej mechaniczna, ale przewidywalna.",
     "Jakość mowy. "),
    ("Piper działa na samym procesorze z modelem 60 MB i odpowiada w ułamku sekundy. XTTS-v2 wymaga karty "
     "graficznej i modelu około 1,8 GB, a mimo to potrzebuje kilku sekund na wypowiedź, co w dialogu jest odczuwalne.",
     "Szybkość i zasoby. "),
    ("XTTS-v2 wyraźnie lepiej wymawia wyrazy obce i angielskie nazwy, co w sklepie komputerowym ma znaczenie. "
     "Jego błędy przy skrótach, datach i dużych liczbach są jednak poważniejsze – zdarza się, że zamiast słów "
     "generuje szum, a takie wypowiedzi stają się niezrozumiałe.", "Mocne i słabe strony XTTS-v2. "),
    ("Oba systemy źle radzą sobie z tekstem „pisanym” – skrótami, datami, symbolami. Ponieważ odpowiedzi "
     "asystenta generuje sam system, można je od razu tworzyć w formie „do czytania” (liczby i daty słownie, "
     "rozwinięte skróty) lub poprzedzić syntezę prostą normalizacją. Dla Pipera warto dodatkowo przygotować "
     "słownik wymowy nazw produktów.", "Normalizacja tekstu. "),
]:
    B(t, b)
p = doc.add_paragraph()
r = p.add_run("Werdykt: ")
r.bold = True
p.add_run("ze względu na lepsze oceny odsłuchowe, stabilność oraz wielokrotnie krótszy czas odpowiedzi na "
          "zwykłym sprzęcie do wdrożenia w projekcie wybieramy ")
r = p.add_run("Pipera")
r.bold = True
p.add_run(", uzupełnionego o normalizację tekstu przed syntezą.")

doc.add_heading("6. Załączone nagrania", 1)
P("Do raportu dołączono wybrane nagrania (folder nagrania/), ilustrujące opisane wyżej przypadki:").paragraph_format.keep_with_next = True
data = [("Nr", "Plik", "Próbka", "Co słychać")]
for n in NAG:
    data.append((f"{n['nr']:02d}", n["plik"], n["sample"], n["opis"]))
table(data, [1, 6.6, 1.5, 7.5], size=9, spacer=False)

# ------------------------------------------------------------------ dane (poziomo)
new = doc.add_section()
new.orientation = WD_ORIENT.LANDSCAPE
new.page_width, new.page_height = Cm(29.7), Cm(21)
new.left_margin = new.right_margin = Cm(1.8)
new.top_margin = new.bottom_margin = Cm(1.6)
doc.add_heading("7. Kompletne dane", 1)
P("W tabeli zamieszczono wyniki dla wszystkich 30 próbek ocenianych odsłuchowo (dla każdej próbki osobny wiersz "
  "dla każdego systemu). Oznaczenia: Z – zrozumiałość, N – naturalność, I – intonacja i prozodia, P – płynność, "
  "D – przydatność w dialogu (średnia ocen dwóch osób, skala 1–5); Bł. – liczba błędów wymowy (kryterium 1); "
  "WER – odsetek błędnych słów w transkrypcji Whisper; Czas – czas generowania (mediana z trzech pomiarów).",
  size=9)
hdr = ["Próbka", "Typ", "Tekst wejściowy", "System", "Transkrypcja (Whisper)", "WER", "Bł.", "Czas [s]",
       "Z", "N", "I", "P", "D"]
W = [1.4, 1.85, 6.8, 1.45, 6.75, 1.1, 0.8, 1.15, 0.8, 0.8, 0.8, 0.8, 0.8]
samples = sorted({r["sample"] for r in rows})
t = doc.add_table(rows=1 + 2 * len(samples), cols=len(hdr))
t.style = "Table Grid"
t.alignment = WD_TABLE_ALIGNMENT.CENTER
for j, h in enumerate(hdr):
    c = t.cell(0, j)
    c.width = Cm(W[j])
    cell_text(c, h, 8, True, color=RGBColor(0xFF, 0xFF, 0xFF))
    shade(c, "A7190E")
trPr = t.rows[0]._tr.get_or_add_trPr()
th = OxmlElement("w:tblHeader")
th.set(qn("w:val"), "true")
trPr.append(th)
for i, smp in enumerate(samples):
    for k, sy in enumerate(SYS):
        r = next(x for x in rows if x["sample"] == smp and x["system"] == sy)
        ri = 1 + 2 * i + k
        vals = [smp, CAT[r["category"]], r["text"], sy, r["hyp"], pl(r["wer"] * 100, 0) + "%", str(r["err_sum"]),
                pl(r["time"]), pl(r["k2"], 1), pl(r["k3"], 1), pl(r["k4"], 1), pl(r["k5"], 1), pl(r["k8"], 1)]
        for j, v in enumerate(vals):
            c = t.cell(ri, j)
            c.width = Cm(W[j])
            if k == 1 and j in (0, 1, 2):
                continue
            cell_text(c, v, 7.5, j == 0, WD_ALIGN_PARAGRAPH.RIGHT if j >= 5 else None)
            if i % 2:
                shade(c, "F2F2F2")
    for j in (0, 1, 2):
        a, b = t.cell(1 + 2 * i, j), t.cell(2 + 2 * i, j)
        a.merge(b)
        if i % 2:
            shade(a, "F2F2F2")
    # nie dziel pary wierszy jednej próbki między stronami
    for ri in (1 + 2 * i, 2 + 2 * i):
        trp = t.rows[ri]._tr.get_or_add_trPr()
        cs = OxmlElement("w:cantSplit")
        cs.set(qn("w:val"), "true")
        trp.append(cs)

fix_widths(t, W)
# porządkowanie kolejności elementów wg schematu OOXML (Word odrzuca/naprawia złą kolejność)
TC_ORDER = ["tcW", "gridSpan", "hMerge", "vMerge", "tcBorders", "shd", "noWrap", "tcMar", "textDirection",
            "tcFitText", "vAlign", "hideMark"]
TBL_ORDER = ["tblStyle", "tblpPr", "tblOverlap", "bidiVisual", "tblStyleRowBandSize", "tblStyleColBandSize", "tblW",
             "jc", "tblCellSpacing", "tblInd", "tblBorders", "shd", "tblLayout", "tblCellMar", "tblLook",
             "tblCaption", "tblDescription"]


def reorder(el, order):
    seen = {}
    for k in list(el):  # duplikaty: zostaje ostatni element danego typu
        if k.tag in seen:
            el.remove(seen[k.tag])
        seen[k.tag] = k
    kids = list(el)
    kids.sort(key=lambda k: order.index(k.tag.split("}")[1]) if k.tag.split("}")[1] in order else len(order))
    for k in kids:
        el.remove(k)
        el.append(k)


body = doc.element.body
for tcPr in body.iter(qn("w:tcPr")):
    reorder(tcPr, TC_ORDER)
for tblPr in body.iter(qn("w:tblPr")):
    reorder(tblPr, TBL_ORDER)
zoom = doc.settings.element.find(qn("w:zoom"))
if zoom is not None and zoom.get(qn("w:percent")) is None:
    zoom.set(qn("w:percent"), "100")

doc.core_properties.author = "Aleksander Stepaniuk, Mieszko Szczekla"
doc.core_properties.title = "Badanie porównawcze systemów syntezy mowy"
doc.save(OUT)
print("zapisano", OUT)
