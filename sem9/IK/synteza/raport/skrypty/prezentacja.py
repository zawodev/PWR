"""Generuje raport/Prezentacja_TTS.pptx na bazie szablonu PWr (prezentacja-pl.pot skonwertowany do .pptx).
Użycie: python prezentacja.py <szablon.pptx>
Wykresy są natywne (edytowalne w PowerPoincie -> "Edytuj dane").
"""
import json
import sys
from pathlib import Path

from pptx import Presentation
from pptx.chart.data import CategoryChartData
from pptx.dml.color import RGBColor
from pptx.enum.chart import XL_CHART_TYPE, XL_LEGEND_POSITION, XL_LABEL_POSITION
from pptx.enum.text import PP_ALIGN
from pptx.util import Inches, Pt

HERE = Path(__file__).resolve().parent
D = json.load(open(HERE / "dane.json", encoding="utf-8"))
OUT = HERE.parent / "Prezentacja_TTS.pptx"

RED = RGBColor(0xA7, 0x19, 0x0E)      # kolor szablonu PWr - Piper
GRAY = RGBColor(0xA6, 0xA6, 0xA6)     # XTTS-v2
INK = RGBColor(0x26, 0x26, 0x26)
FONT = "Trebuchet MS"  # czcionka szablonu
MUTED = RGBColor(0x59, 0x59, 0x59)
ERR = RGBColor(0xC0, 0x00, 0x00)
OK = RGBColor(0x2E, 0x7D, 0x32)
SYS = ["Piper", "XTTS-v2"]

rows = D["rows"]


def avg(system, key, cat=None):
    v = [r[key] for r in rows if r["system"] == system and (cat is None or r["category"] == cat)]
    return sum(v) / len(v)


def pl(x, n=2):
    return f"{x:.{n}f}".replace(".", ",")


prs = Presentation(sys.argv[1])
L_CONTENT, L_TITLE = prs.slide_layouts[0], prs.slide_layouts[1]
template_slides = list(prs.slides._sldIdLst)

# obszar treści pod czerwonym nagłówkiem szablonu (4:3, 10" x 7.5")
CX, CY, CW, CH = Inches(0.75), Inches(1.95), Inches(8.9), Inches(5.2)


def title_slide(title, subtitle, size):
    s = prs.slides.add_slide(L_TITLE)
    t = s.shapes.title
    t.left, t.top, t.width, t.height = 1873080, 2130120, 7089840, 2019600
    t.text = title
    for p in t.text_frame.paragraphs:
        for r in p.runs:
            r.font.size = Pt(size)
    sub = [p for p in s.placeholders if p.placeholder_format.type != 1][0]
    sub.left, sub.top, sub.width, sub.height = 1873080, 5697360, 7089840, 900000
    tf = sub.text_frame
    for i, line in enumerate(subtitle):
        p = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
        p.alignment = PP_ALIGN.CENTER
        r = p.add_run()
        r.text = line
        r.font.size = Pt(16)
    return s


def drop_body(slide):
    for ph in list(slide.placeholders):
        if ph.placeholder_format.type != 1:  # zostaw tylko tytuł
            ph._element.getparent().remove(ph._element)


def content(title, bullets=None, size=24):
    s = prs.slides.add_slide(L_CONTENT)
    s.shapes.title.text = title
    body = [p for p in s.placeholders if p.placeholder_format.type != 1][0]
    if bullets is None:
        drop_body(s)
        return s
    tf = body.text_frame
    for i, b in enumerate(bullets):
        p = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
        runs = b if isinstance(b, list) else [(b, None)]
        for txt, color in runs:
            r = p.add_run()
            r.text = txt
            r.font.size = Pt(size)
            if color is not None:
                r.font.color.rgb = color
        p.space_after = Pt(10)
        pPr = p._p.get_or_add_pPr()
        pPr.set("marL", "343080")
        pPr.set("indent", "-343080")
    return s


def note(slide, text, y=Inches(6.75), size=14):
    tb = slide.shapes.add_textbox(CX, y, CW, Inches(0.5))
    tf = tb.text_frame
    tf.word_wrap = True
    r = tf.paragraphs[0].add_run()
    r.text = text
    r.font.size = Pt(size)
    r.font.name = FONT
    r.font.color.rgb = MUTED
    return tb


def bar_chart(slide, cats, series, fmt="0.0", vmax=None, kind=XL_CHART_TYPE.COLUMN_CLUSTERED,
              y=CY, h=Inches(4.7), title=None, axis_title=None):
    cd = CategoryChartData()
    cd.categories = cats
    for name, vals in series:
        cd.add_series(name, vals)
    gf = slide.shapes.add_chart(kind, CX, y, CW, h, cd)
    ch = gf.chart
    ch.font.size = Pt(13)
    ch.font.name = FONT
    ch.font.color.rgb = INK
    ch.has_legend = True
    ch.legend.position = XL_LEGEND_POSITION.TOP
    ch.legend.include_in_layout = False
    ch.legend.font.size = Pt(14)
    if title:
        ch.has_title = True
        ch.chart_title.text_frame.text = title
        ch.chart_title.text_frame.paragraphs[0].runs[0].font.size = Pt(14)
    else:
        ch.has_title = False
    plot = ch.plots[0]
    plot.gap_width = 60
    plot.overlap = -10
    plot.has_data_labels = True
    dl = plot.data_labels
    dl.number_format = fmt
    dl.number_format_is_linked = False
    dl.position = XL_LABEL_POSITION.OUTSIDE_END
    dl.font.size = Pt(12)
    for s, col in zip(plot.series, (RED, GRAY)):
        s.format.fill.solid()
        s.format.fill.fore_color.rgb = col
    va = ch.value_axis
    va.has_major_gridlines = True
    va.major_gridlines.format.line.color.rgb = RGBColor(0xD9, 0xD9, 0xD9)
    va.format.line.fill.background()
    va.tick_labels.font.size = Pt(12)
    va.tick_labels.font.color.rgb = MUTED
    va.minimum_scale = 0
    if vmax:
        va.maximum_scale = vmax
    if axis_title:
        va.has_title = True
        va.axis_title.text_frame.text = axis_title
        va.axis_title.text_frame.paragraphs[0].runs[0].font.size = Pt(12)
    ca = ch.category_axis
    ca.tick_labels.font.size = Pt(13)
    ca.format.line.color.rgb = RGBColor(0xBF, 0xBF, 0xBF)
    return ch


def example(title, text, lines, foot, size=22):
    """Slajd z przykładem: tekst wejściowy + co usłyszeliśmy w każdym systemie.
    lines: lista (etykieta, [(fragment, kolor|None), ...])"""
    s = content(title)
    tb = s.shapes.add_textbox(CX, CY, CW, CH)
    tf = tb.text_frame
    tf.word_wrap = True
    first = True

    def para(runs, size=22, after=4, before=0):
        nonlocal first
        p = tf.paragraphs[0] if first else tf.add_paragraph()
        first = False
        p.space_after = Pt(after)
        p.space_before = Pt(before)
        for txt, col, bold in runs:
            r = p.add_run()
            r.text = txt
            r.font.size = Pt(size)
            r.font.bold = bold
            r.font.name = FONT
            r.font.color.rgb = col or INK

    para([("Tekst: ", MUTED, True), (text, INK, False)], size=20, after=14)
    for label, parts in lines:
        para([(label, RED if label.startswith("Piper") else MUTED, True)], size=size - 2, before=8)
        para([(t, c, False) for t, c in parts], size=size)
    note(s, foot)
    return s


# ---------------------------------------------------------------- 1. tytuł
title_slide("Badanie porównawcze systemów syntezy mowy na potrzeby projektowanych interfejsów konwersacyjnych",
            ["Aleksander Stepaniuk, 272644", "Mieszko Szczekla, 272688"], 28)

# ---------------------------------------------------------------- 2. agenda
content("Agenda", ["Temat projektu", "Wybrane syntezatory", "Przebieg badania", "Wyniki badań",
                   "Przykłady błędów", "Wnioski"], size=26)

# ---------------------------------------------------------------- 3. temat
content("Temat projektu", [
    "Interfejs konwersacyjny dla sklepu komputerowego pomagający skompletować komponenty komputera.",
    "Syntezator mowy odczytuje odpowiedzi asystenta: nazwy podzespołów, ceny, daty dostawy, adresy salonów.",
    "Sprawdzamy, który z dwóch lokalnych syntezatorów lepiej nadaje się do tej roli.",
], size=24)

# ---------------------------------------------------------------- 4-5. modele
content("Piper (głos darkman)", [
    "Lekki model VITS uruchamiany przez ONNX Runtime, działa na samym procesorze.",
    "Tekst zamieniany na fonemy przez eSpeak-NG – to on decyduje, jak czytane są liczby i skróty.",
    "Osobny model dla każdego języka i głosu; użyto polskiego głosu męskiego pl_PL-darkman-medium.",
    "Mały model (ok. 60 MB), nagrania 22 kHz.",
], size=22)
content("Coqui XTTS-v2 (głos Claribel Dervla)", [
    "Duży wielojęzyczny model autoregresyjny (GPT + dekoder, ok. 1,8 GB), wymaga karty graficznej.",
    "Możliwe klonowanie głosu z próbki; użyto wbudowanego głosu żeńskiego, język ustawiony na polski.",
    "Własna, uproszczona normalizacja tekstu: liczby przez num2words i tylko kilka skrótów.",
    "Wynik losowy – każde wygenerowanie brzmi trochę inaczej.",
], size=22)

# ---------------------------------------------------------------- 6. przebieg
content("Przebieg badania", [
    f"{D['n_texts']} tekstów ze wspólnej bazy grupy × 2 syntezatory = {2 * D['n_texts']} nagrań.",
    "Do odsłuchu 30 tekstów: 10 naszych, 15 z bazy i 5 dopisanych (skróty, duże liczby, nazwy, spolszczenia).",
    "Nagrania zanonimizowane (A/B) i ocenione przez 2 osoby w skali 1–5.",
    "Pomiar czasu generowania (3 powtórzenia, mediana) i automatyczna transkrypcja Whisperem large-v3.",
    "Platforma: AMD Ryzen 7 5800X, 32 GB RAM, RTX 5070 Ti, Fedora Linux.",
], size=21)

# ---------------------------------------------------------------- 7. oceny odsłuchowe
crit = [("Zrozumiałość", "k2"), ("Naturalność", "k3"), ("Intonacja", "k4"), ("Płynność", "k5"),
        ("Przydatność\nw dialogu", "k8")]
s = content("Ocena odsłuchowa")
cats = [c for c, _ in crit] + ["Stabilność"]
ser = [(sy, [avg(sy, k) for _, k in crit] + [D["stab"][sy]["avg"]]) for sy in SYS]
bar_chart(s, cats, ser, fmt="0.00", vmax=5, axis_title="średnia ocena (1–5)")
note(s, "Średnia z ocen dwóch osób dla 30 próbek; stabilność oceniana raz na system.")

# ---------------------------------------------------------------- 8. czas
s = content("Szybkość generowania")
cat_lab = {"1": "Komunikaty", "2": "Pytania", "3": "Liczby", "4": "Długie", "5": "Obce nazwy"}
ser = [(sy, [D["all"][sy]["time_by_cat"][c] for c in cat_lab]) for sy in SYS]
bar_chart(s, list(cat_lab.values()), ser, fmt="0.0", axis_title="średni czas [s]")
pa, xa = D["all"]["Piper"], D["all"]["XTTS-v2"]
note(s, f"Wszystkie {D['n_texts']} tekstów. Mediana: Piper {pl(pa['time_median'])} s (CPU), "
        f"XTTS {pl(xa['time_median'])} s (GPU); RTF {pl(pa['rtf_mean'], 3)} vs {pl(xa['rtf_mean'], 3)}.")

# ---------------------------------------------------------------- 9. błędy
s = content("Poprawność wymowy")
ec = [("Liczby", "err_L"), ("Daty i godziny", "err_D"), ("Skróty", "err_S"), ("Nazwy własne", "err_N"),
      ("Wyrazy obce", "err_O")]
ser = [(sy, [sum(r[k] for r in rows if r["system"] == sy) for _, k in ec]) for sy in SYS]
bar_chart(s, [c for c, _ in ec], ser, fmt="0", axis_title="liczba błędów (30 próbek)")
tot = {sy: sum(r["err_sum"] for r in rows if r["system"] == sy) for sy in SYS}
note(s, f"Razem: Piper {tot['Piper']}, XTTS {tot['XTTS-v2']} błędów. WER (Whisper, wszystkie nagrania): "
        f"{pl(pa['wer_all'] * 100, 1)}% vs {pl(xa['wer_all'] * 100, 1)}%.")

# ---------------------------------------------------------------- 10-12. przykłady
example("Przykład: skróty",
        "„czynny pn.–pt. 10:00–19:00, sob. 9:00–14:00”",
        [("Oczekiwane", [("od poniedziałku do piątku…", OK)]),
         ("Piper", [("„", None), ("pe en kropka pet", ERR), ("”", None)]),
         ("XTTS-v2", [("„", None), ("pnięta ptinung ptanina studa pidi", ERR), ("” – losowe dźwięki", None)])],
        "Nagrania 01–02. Żaden system nie rozwinął skrótu; XTTS zamiast słów wygenerował szum.")
example("Przykład: daty i liczby",
        "„15.11.2026 r.” oraz „943 492 412 komputerów”",
        [("Piper – data", [("„piętnasty, jedenasty dwa tysiące dwudziestego szósty ", None), ("er", ERR), ("”", None)]),
         ("XTTS-v2 – data", [("„piętnaście ", None), ("przecinek", ERR), (" jedenaście… dwadzieścia sześć ", None),
                             ("er", ERR), ("”", None)]),
         ("Piper – liczba", [("„dziewięćset czterdzieści trzy miliony czterysta dziewięćdziesiąt dwa tysiące…”", OK)]),
         ("XTTS-v2 – liczba", [("„dziewięćset czterdzieści trzy, czterysta dziewięćdziesiąt dwa, czterysta dwanaście”", ERR)])],
        "Nagrania 03–06. XTTS czyta datę jak ułamek, a dużą liczbę jako trzy osobne grupy cyfr.", size=19)
example("Przykład: wyrazy obce",
        "„Crème brûlée … Piña Colada … sosem barbeque”, „overclockingu … na Twitchu”",
        [("Piper", [("„", None), ("kremem brule", ERR), (", pińa colada, ", None), ("barbegwe", ERR),
                    (", ", None), ("owerclockingu", ERR), (", ", None), ("twitchu", ERR), ("”", None)]),
         ("XTTS-v2", [("„krem brulej, pinia kolada, ", OK), ("barbek", ERR), (", owerklokingu, tłitchu”", OK)])],
        "Nagrania 07–10. Piper czyta obce słowa po polsku, litera po literze; XTTS radzi sobie lepiej.")

# ---------------------------------------------------------------- 13. stabilność
s = content("Ocena według typu wypowiedzi")
cm = {"1-info": "Komunikaty", "2-qna": "Pytania", "3-numbers": "Liczby", "4-long": "Długie",
      "5-unique-foreign": "Obce nazwy"}


def subj(sy, cat):
    v = [sum(r[k] for k in ("k2", "k3", "k4", "k5", "k8")) / 5 for r in rows if r["system"] == sy and r["category"] == cat]
    return sum(v) / len(v)


ser = [(sy, [subj(sy, c) for c in cm]) for sy in SYS]
bar_chart(s, list(cm.values()), ser, fmt="0.00", vmax=5, axis_title="średnia z kryteriów 2–5 i 8")
note(s, "Oba systemy najsłabiej wypadają na tekstach z liczbami i skrótami; Piper jest wyżej w każdej grupie.")

# ---------------------------------------------------------------- 14. porównanie (tabela)
s = content("Porównanie")
data = [("Kryterium", "Piper", "XTTS-v2"),
        ("1. Poprawność wymowy (liczba błędów)", str(tot["Piper"]), str(tot["XTTS-v2"]))]
names = {"k2": "2. Zrozumiałość", "k3": "3. Naturalność", "k4": "4. Intonacja i prozodia", "k5": "5. Płynność"}
for k, n in names.items():
    data.append((n, pl(avg("Piper", k)), pl(avg("XTTS-v2", k))))
data.append(("6. Stabilność syntezy", pl(D["stab"]["Piper"]["avg"]), pl(D["stab"]["XTTS-v2"]["avg"])))
data.append(("7. Szybkość (mediana czasu)", pl(pa["time_median"]) + " s", pl(xa["time_median"]) + " s"))
data.append(("8. Przydatność w dialogu", pl(avg("Piper", "k8")), pl(avg("XTTS-v2", "k8"))))
tbl = s.shapes.add_table(len(data), 3, CX, CY, CW, Inches(0.5) * len(data)).table
tbl.columns[0].width = Inches(5.3)
tbl.columns[1].width = Inches(1.8)
tbl.columns[2].width = Inches(1.8)
for i, row in enumerate(data):
    for j, v in enumerate(row):
        c = tbl.cell(i, j)
        c.text = v
        p = c.text_frame.paragraphs[0]
        p.alignment = PP_ALIGN.LEFT if j == 0 else PP_ALIGN.RIGHT
        r = p.runs[0]
        r.font.size = Pt(17)
        c.fill.solid()
        if i == 0:
            c.fill.fore_color.rgb = RED
            r.font.bold = True
            r.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)
        else:
            c.fill.fore_color.rgb = RGBColor(0xFF, 0xFF, 0xFF) if i % 2 else RGBColor(0xF2, 0xF2, 0xF2)
            r.font.color.rgb = INK
            r.font.bold = (j == 1)  # Piper lepszy w każdym kryterium
note(s, "Pogrubiono lepszy wynik. Piper wygrał we wszystkich ośmiu kryteriach.", y=Inches(6.6))

# ---------------------------------------------------------------- 15. wnioski
content("Wnioski", [
    "Piper brzmiał dla nas lepiej i stabilniej, a przy tym był kilkanaście razy szybszy – bez karty graficznej.",
    "XTTS-v2 lepiej wymawia wyrazy obce, ale gubi się na skrótach, datach i dużych liczbach, czasem generuje szum.",
    "Oba systemy wymagają normalizacji tekstu przed syntezą – asystent powinien od razu pisać „do czytania”.",
    [("Werdykt: wybieramy Pipera.", RED)],
], size=22)

# ---------------------------------------------------------------- 16. zakończenie
title_slide("Dziękujemy za uwagę", ["Aleksander Stepaniuk, 272644", "Mieszko Szczekla, 272688"], 32)

# usunięcie przykładowych slajdów z szablonu
lst = prs.slides._sldIdLst
for sld in template_slides:
    prs.part.drop_rel(sld.rId)
    lst.remove(sld)
prs.save(OUT)
print("zapisano", OUT)
