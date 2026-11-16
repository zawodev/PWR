"""Budowa arkusza ocena_TTS.xlsx (wywoływane z evaluate.py)."""
from openpyxl import Workbook
from openpyxl.comments import Comment
from openpyxl.formatting.rule import CellIsRule, ColorScaleRule
from openpyxl.styles import Alignment, Border, Font, PatternFill, Side
from openpyxl.utils import get_column_letter as L
from openpyxl.worksheet.datavalidation import DataValidation

from selection import SELECTED, CATS

FONT = "Arial"
F = Font(name=FONT, size=10)
FB = Font(name=FONT, size=10, bold=True)
FH = Font(name=FONT, size=10, bold=True, color="FFFFFF")
FT = Font(name=FONT, size=14, bold=True)
FAUTO = Font(name=FONT, size=10, italic=True, color="808080")
FIN = Font(name=FONT, size=10, color="0000FF")
HDR = PatternFill("solid", fgColor="305496")
SUB = PatternFill("solid", fgColor="D9E1F2")
INP = PatternFill("solid", fgColor="FFF2CC")   # komórki do uzupełnienia
AUTO = PatternFill("solid", fgColor="EDEDED")  # wstępnie wypełnione automatycznie - do weryfikacji
THIN = Side(style="thin", color="BFBFBF")
BOX = Border(left=THIN, right=THIN, top=THIN, bottom=THIN)
WRAP = Alignment(wrap_text=True, vertical="top")
CENTER = Alignment(horizontal="center", vertical="center", wrap_text=True)
ENGINES = ["piper", "xtts"]
LBL = {"piper": "Piper", "xtts": "XTTS-v2"}
CATN = {"1": "1-info", "2": "2-qna", "3": "3-numbers", "4": "4-long", "5": "5-unique-foreign"}

SUBJ = [("2", "Zrozumiałość"), ("3", "Naturalność"), ("4", "Intonacja i prozodia"), ("5", "Płynność"),
        ("8", "Przydatność w dialogu")]
ERRC = [("L", "liczby"), ("D", "daty/godz."), ("S", "skróty"), ("N", "nazwy wł."), ("O", "obce/spolszcz."),
        ("W", "słowa nośne"), ("A", "akcent/inna wymowa")]


def hdr(ws, row, col, text, fill=HDR, font=FH):
    c = ws.cell(row=row, column=col, value=text)
    c.fill, c.font, c.alignment, c.border = fill, font, CENTER, BOX
    return c


def put(ws, row, col, val, font=F, fill=None, fmt=None, align=None):
    c = ws.cell(row=row, column=col, value=val)
    c.font, c.border = font, BOX
    c.alignment = align or WRAP
    if fill:
        c.fill = fill
    if fmt:
        c.number_format = fmt
    return c


def build(path, rows, probes, key, sample_ids, findings, phrase_cnt, frontend):
    wb = Workbook()
    by_file = {r["file"]: r for r in rows}
    sample_cat = {sid: by_file[rel]["category"] for rel, sid in sample_ids.items()}

    # ================================================================ Instrukcja
    ws = wb.active
    ws.title = "Instrukcja"
    instr(ws)

    # ================================================================ Oceny (zanonimizowane)
    wo = wb.create_sheet("Oceny")
    FIRST = 3
    last = FIRST + len(key) - 1
    base = ["ID nagrania", "Próbka", "Plik do odsłuchu", "Kat. tekstu", "Tekst wejściowy",
            "Transkrypcja Whisper (auto)", "WER auto"]
    for i, h in enumerate(base, 1):
        wo.merge_cells(start_row=1, start_column=i, end_row=2, end_column=i)
        hdr(wo, 1, i, h)
    col = len(base) + 1
    subj_cols = {}
    for num, name in SUBJ:
        wo.merge_cells(start_row=1, start_column=col, end_row=1, end_column=col + 2)
        hdr(wo, 1, col, f"Kryt. {num}: {name} (1-5)")
        for k, s in enumerate(["Osoba 1", "Osoba 2", "Średnia"]):
            hdr(wo, 2, col + k, s, SUB, FB)
        subj_cols[num] = col
        col += 3
    c1 = col
    wo.merge_cells(start_row=1, start_column=c1, end_row=1, end_column=c1 + len(ERRC) + 2)
    hdr(wo, 1, c1, "Kryt. 1: Poprawność wymowy - LICZBA BŁĘDÓW wg kategorii (szare = wstępnie z automatu, popraw po odsłuchu)")
    hdr(wo, 2, c1, "Sondy niezaliczone (auto)", SUB, FB)
    for k, (code, name) in enumerate(ERRC, 1):
        hdr(wo, 2, c1 + k, f"{code}: {name}", SUB, FB)
    sum_col = c1 + len(ERRC) + 1
    hdr(wo, 2, sum_col, "SUMA błędów", SUB, FB)
    hdr(wo, 2, sum_col + 1, "Opis błędów / uwagi", SUB, FB)
    err_cols = {code: c1 + k for k, (code, _) in enumerate(ERRC, 1)}

    probes_by = {}
    for p in probes:
        probes_by.setdefault(p["sample"], []).append(p)
    for i, k in enumerate(key):
        r = FIRST + i
        row = by_file[k["file"]]
        e = k["engine"]
        put(wo, r, 1, k["id"], FB)
        put(wo, r, 2, k["sample"])
        put(wo, r, 3, f"odsluch/{k['id']}.wav")
        put(wo, r, 4, CATN[row["category"]])
        put(wo, r, 5, row["text"])
        put(wo, r, 6, row[f"{e}_hyp"], FAUTO, AUTO)
        put(wo, r, 7, row[f"{e}_wer"], FAUTO, AUTO, "0%")
        for num, cc in subj_cols.items():
            put(wo, r, cc, None, FIN, INP, align=CENTER)
            put(wo, r, cc + 1, None, FIN, INP, align=CENTER)
            a, b = f"{L(cc)}{r}", f"{L(cc + 1)}{r}"
            put(wo, r, cc + 2, f'=IF(COUNT({a}:{b})=0,"",AVERAGE({a}:{b}))', FB, fmt="0.00", align=CENTER)
        ps = probes_by.get(k["sample"], [])
        bad = [p for p in ps if p[e] != "OK"]
        put(wo, r, c1, f"{len(bad)}/{len(ps)}" if ps else "-", FAUTO, AUTO, align=CENTER)
        for code, cc in err_cols.items():
            n = sum(p["cat"] == code for p in bad)
            put(wo, r, cc, n if ps else None, FAUTO if ps else FIN, AUTO if ps else INP, align=CENTER)
        put(wo, r, sum_col, f"=SUM({L(err_cols['L'])}{r}:{L(err_cols['A'])}{r})", FB, align=CENTER)
        note = "; ".join(f"{p['fragment']}?" for p in bad)
        put(wo, r, sum_col + 1, ("auto: " + note) if note else None, FAUTO if note else FIN, INP)
    widths = {1: 9, 2: 7, 3: 17, 4: 11, 5: 55, 6: 55, 7: 7}
    for c in range(1, sum_col + 2):
        wo.column_dimensions[L(c)].width = widths.get(c, 8)
    wo.column_dimensions[L(sum_col + 1)].width = 45
    wo.row_dimensions[2].height = 45
    wo.freeze_panes = "H3"
    dv = DataValidation(type="whole", operator="between", formula1="1", formula2="5", allow_blank=True,
                        showErrorMessage=True, errorTitle="Skala Likerta", error="Wpisz liczbę całkowitą 1-5")
    wo.add_data_validation(dv)
    for num, cc in subj_cols.items():
        dv.add(f"{L(cc)}{FIRST}:{L(cc + 1)}{last}")
    wo.conditional_formatting.add(
        f"{L(subj_cols['2'] + 2)}{FIRST}:{L(subj_cols['8'] + 2)}{last}",
        ColorScaleRule(start_type="num", start_value=1, start_color="F8696B", mid_type="num", mid_value=3,
                       mid_color="FFEB84", end_type="num", end_value=5, end_color="63BE7B"))
    wo.cell(row=1, column=6).comment = Comment(
        "Transkrypcja automatyczna (Whisper large-v3) - pomocniczo. Whisper potrafi 'poprawić' błędną wymowę, "
        "więc nie zastępuje odsłuchu.", "evaluate.py")

    # ================================================================ Klucz (ukryty)
    wk = wb.create_sheet("Klucz")
    for i, h in enumerate(["ID nagrania", "System", "Plik tekstu", "Kat."], 1):
        hdr(wk, 2, i, h)
    put(wk, 1, 1, "Klucz anonimizacji - NIE ODKRYWAĆ przed zakończeniem ocen. Wiersze wyrównane z arkuszem Oceny.", FB)
    for i, k in enumerate(key):
        r = FIRST + i
        put(wk, r, 1, k["id"])
        put(wk, r, 2, LBL[k["engine"]])
        put(wk, r, 3, k["file"])
        put(wk, r, 4, CATN[by_file[k["file"]]["category"]])
    wk.column_dimensions["C"].width = 55
    wk.sheet_state = "hidden"

    # ================================================================ Stabilność (kryt. 6)
    wst = wb.create_sheet("Stabilnosc")
    put(wst, 1, 1, "Kryterium 6: Stabilność syntezy - czy jakość jest podobna dla różnych typów wypowiedzi", FT)
    put(wst, 2, 1, "Oceniane raz na system, PO odsłuchu wszystkich 30 próbek (skala 1-5). "
                   "Pomocniczo: średnie kryteriów 2-5, 8 w podziale na kategorie tekstów (z arkusza Oceny) "
                   "oraz rozrzut WER. Arkusz pokazuje nazwy systemów - uzupełnij go na końcu.", F)
    wst.merge_cells("A2:H2")
    wst.row_dimensions[2].height = 45
    for i, h in enumerate(["System", "Osoba 1", "Osoba 2", "Średnia", "Uzasadnienie"], 1):
        hdr(wst, 4, i, h)
    for j, e in enumerate(ENGINES):
        r = 5 + j
        put(wst, r, 1, LBL[e], FB)
        put(wst, r, 2, None, FIN, INP, align=CENTER)
        put(wst, r, 3, None, FIN, INP, align=CENTER)
        put(wst, r, 4, f'=IF(COUNT(B{r}:C{r})=0,"",AVERAGE(B{r}:C{r}))', FB, fmt="0.00", align=CENTER)
        put(wst, r, 5, None, FIN, INP)
    dv6 = DataValidation(type="whole", operator="between", formula1="1", formula2="5", allow_blank=True)
    wst.add_data_validation(dv6)
    dv6.add("B5:C6")
    hdr(wst, 8, 1, "Średnia z kryt. 2-5, 8 wg kategorii")
    for j, e in enumerate(ENGINES):
        hdr(wst, 8, 2 + j, LBL[e])
    hdr(wst, 8, 4, "WER auto Piper (wszystkie nagr.)")
    hdr(wst, 8, 5, "WER auto XTTS (wszystkie nagr.)")
    avg_cols = [L(subj_cols[n] + 2) for n, _ in SUBJ]
    for i, (code, name) in enumerate(CATN.items()):
        r = 9 + i
        put(wst, r, 1, name, FB)
        for j, e in enumerate(ENGINES):
            parts = "+".join(
                f"SUMIFS(Oceny!{c}${FIRST}:{c}${last},Klucz!$B${FIRST}:$B${last},\"{LBL[e]}\",Oceny!$D${FIRST}:$D${last},$A{r})"
                for c in avg_cols)
            cnts = "+".join(
                f"COUNTIFS(Oceny!{c}${FIRST}:{c}${last},\">0\",Klucz!$B${FIRST}:$B${last},\"{LBL[e]}\",Oceny!$D${FIRST}:$D${last},$A{r})"
                for c in avg_cols)
            put(wst, r, 2 + j, f'=IF(({cnts})=0,"",({parts})/({cnts}))', F, fmt="0.00", align=CENTER)
        for j, e in enumerate(ENGINES):
            ecol = "I" if e == "piper" else "O"
            put(wst, r, 4 + j,
                f"=SUMIFS(WER_auto!${ecol}$4:${ecol}${3 + len(rows)},WER_auto!$C$4:$C${3 + len(rows)},$A{r})"
                f"/SUMIFS(WER_auto!$F$4:$F${3 + len(rows)},WER_auto!$C$4:$C${3 + len(rows)},$A{r})",
                F, fmt="0.0%", align=CENTER)
    r = 14
    put(wst, r, 1, "Rozstęp (max-min)", FB)
    for j in range(4):
        cl = L(2 + j)
        put(wst, r, 2 + j, f'=IFERROR(MAX({cl}9:{cl}13)-MIN({cl}9:{cl}13),"")', FB,
            fmt="0.00" if j < 2 else "0.0%", align=CENTER)
    for c, wdt in zip("ABCDE", [30, 14, 14, 18, 18]):
        wst.column_dimensions[c].width = wdt
    wst.column_dimensions["E"].width = 40

    # ================================================================ Sondy
    wsd = wb.create_sheet("Sondy")
    hs = ["Próbka", "Plik", "Kat. błędu", "Fragment w tekście", "Oczekiwana wymowa", "Piper auto", "XTTS auto",
          "Piper ODSŁUCH", "XTTS ODSŁUCH", "Uwagi (co faktycznie powiedział)"]
    put(wsd, 1, 1, "Sondy: trudne fragmenty 30 próbek. Kolumny 'auto' wypełnił Whisper; po odsłuchu wpisz OK / BŁĄD "
                   "w kolumnach ODSŁUCH (puste = przyjmij wynik auto). Nie anonimizowane - wypełnij PO arkuszu Oceny.", FB)
    wsd.merge_cells("A1:J1")
    wsd.row_dimensions[1].height = 30
    for i, h in enumerate(hs, 1):
        hdr(wsd, 2, i, h)
    dvp = DataValidation(type="list", formula1='"OK,BŁĄD"', allow_blank=True)
    wsd.add_data_validation(dvp)
    for i, p in enumerate(probes):
        r = 3 + i
        vals = [p["sample"], p["file"], f"{p['cat']}: {CATS[p['cat']]}", p["fragment"], p["expected"],
                p["piper"], p["xtts"]]
        for j, v in enumerate(vals, 1):
            put(wsd, r, j, v, FAUTO if j in (6, 7) else F, AUTO if j in (6, 7) else None)
        for j in (8, 9, 10):
            put(wsd, r, j, None, FIN, INP)
    pl = 2 + len(probes)
    dvp.add(f"H3:I{pl}")
    red = PatternFill("solid", fgColor="F8CBAD")
    wsd.conditional_formatting.add(f"F3:I{pl}", CellIsRule(operator="equal", formula=['"BŁĄD?"'], fill=red))
    wsd.conditional_formatting.add(f"F3:I{pl}", CellIsRule(operator="equal", formula=['"BŁĄD"'], fill=red))
    for c, wdt in zip("ABCDEFGHIJ", [7, 40, 22, 26, 40, 10, 10, 11, 11, 40]):
        wsd.column_dimensions[c].width = wdt
    wsd.freeze_panes = "A3"
    wsd.auto_filter.ref = f"A2:J{pl}"

    # ================================================================ Czas generowania (kryt. 7)
    wc = wb.create_sheet("Czas_generowania")
    hc = ["Plik", "Kat.", "W 30?", "Znaki", "Piper: czas [s] (mediana z 3)", "Piper: audio [s]", "Piper: RTF",
          "XTTS: czas [s] (mediana z 3)", "XTTS: audio [s]", "XTTS: RTF", "XTTS / Piper (krotność)"]
    put(wc, 1, 1, "Kryterium 7: czas od przekazania tekstu do syntezatora do zapisania pliku WAV (main.py, "
                  "po rozgrzewce, 3 pomiary - mediana). RTF = czas generowania / długość nagrania (<1 = szybciej niż "
                  "czas rzeczywisty).", FB)
    wc.merge_cells("A1:K1")
    wc.row_dimensions[1].height = 30
    for i, h in enumerate(hc, 1):
        hdr(wc, 3, i, h)
    n = len(rows)
    for i, row in enumerate(rows):
        r = 4 + i
        vals = [row["file"], CATN[row["category"]], "TAK" if row["selected"] else "", len(row["text"]),
                row["piper_time"], row["piper_audio"], row["piper_rtf"], row["xtts_time"], row["xtts_audio"],
                row["xtts_rtf"]]
        fm = [None, None, None, "0", "0.000", "0.00", "0.000", "0.000", "0.00", "0.000"]
        for j, (v, f_) in enumerate(zip(vals, fm), 1):
            put(wc, r, j, v, F, fmt=f_)
        put(wc, r, 11, f"=H{r}/E{r}", F, fmt="0.0")
    lr = 3 + n
    # podsumowanie obok tabeli
    sc = 13
    hdr(wc, 3, sc, "Statystyka")
    for j, e in enumerate(ENGINES):
        hdr(wc, 3, sc + 1 + j, LBL[e])
    stats = [("Średni czas [s] - wszystkie", "AVERAGE({c}4:{c}%d)" % lr),
             ("Mediana czasu [s] - wszystkie", "MEDIAN({c}4:{c}%d)" % lr),
             ("Min czas [s]", "MIN({c}4:{c}%d)" % lr), ("Max czas [s]", "MAX({c}4:{c}%d)" % lr),
             ("Średni czas [s] - 30 wybranych", 'AVERAGEIFS({c}4:{c}%d,$C$4:$C$%d,"TAK")' % (lr, lr)),
             ("Średni RTF - wszystkie", "AVERAGE({r}4:{r}%d)" % lr),
             ("Łączny czas [s]", "SUM({c}4:{c}%d)" % lr),
             ("Znaki na sekundę (łącznie)", "SUM($D$4:$D$%d)/SUM({c}4:{c}%d)" % (lr, lr))]
    for i, (name, f_) in enumerate(stats):
        r = 4 + i
        put(wc, r, sc, name, FB)
        for j, (c, rr) in enumerate([("E", "G"), ("H", "J")]):
            put(wc, r, sc + 1 + j, "=" + f_.format(c=c, r=rr), F, fmt="0.000")
    r0 = 4 + len(stats) + 1
    hdr(wc, r0, sc, "Średni czas [s] wg kategorii")
    for j, e in enumerate(ENGINES):
        hdr(wc, r0, sc + 1 + j, LBL[e])
    for i, cn in enumerate(CATN.values()):
        r = r0 + 1 + i
        put(wc, r, sc, cn, FB)
        for j, c in enumerate(["E", "H"]):
            put(wc, r, sc + 1 + j, f'=AVERAGEIFS({c}$4:{c}${lr},$B$4:$B${lr},${L(sc)}{r})', F, fmt="0.000")
    r1 = r0 + 7
    put(wc, r1, sc, "Konfiguracja", FB)
    put(wc, r1 + 1, sc, "Piper: pl_PL-darkman-medium (ONNX, CPU), głos męski, ustawienia domyślne", F)
    put(wc, r1 + 2, sc, "XTTS-v2: speaker 'Claribel Dervla', language='pl', GPU (CUDA), ustawienia domyślne", F)
    put(wc, r1 + 3, sc, "Czas ładowania modelu i rozgrzewka NIE są wliczone (patrz output/generation_log.txt)", F)
    for c, wdt in zip("ABCDEFGHIJK", [48, 14, 6, 7, 12, 10, 9, 12, 10, 9, 10]):
        wc.column_dimensions[c].width = wdt
    wc.column_dimensions[L(sc)].width = 36
    wc.column_dimensions[L(sc + 1)].width = 12
    wc.column_dimensions[L(sc + 2)].width = 12
    wc.row_dimensions[3].height = 45
    wc.freeze_panes = "B4"
    wc.auto_filter.ref = f"A3:K{lr}"

    # ================================================================ WER_auto (kryt. 1 automatycznie, wszystkie)
    ww = wb.create_sheet("WER_auto")
    hw = ["Plik", "Autor", "Kat.", "W 30?", "Tekst wzorcowy (znormalizowany)", "Słowa wzorca",
          "Piper: transkrypcja", "Piper: WER", "Piper: błędy (S+D+I)", "Piper: WER rdzenie", "Piper: CER",
          "Piper: dł. audio / mediana",
          "XTTS: transkrypcja", "XTTS: WER", "XTTS: błędy (S+D+I)", "XTTS: WER rdzenie", "XTTS: CER",
          "XTTS: dł. audio / mediana", "Tekst po normalizacji XTTS (to dostaje model)", "Wykryte problemy normalizacji XTTS"]
    # kolumny: A plik, B autor, C kat, D w30, E ref, F słowa, G..L piper, M..R xtts, S, T
    put(ww, 1, 1, "Kryterium 1 (automatycznie, wszystkie nagrania): transkrypcja Whisper large-v3 porównana z tekstem "
                  "wejściowym po normalizacji (cyfry/skróty -> słowa, ta sama procedura dla obu stron). WER zawiera "
                  "też szum normalizacji i odmiany - porównuj systemy względnie (ten sam wzorzec dla obu).", FB)
    ww.merge_cells("A1:T1")
    ww.row_dimensions[1].height = 30
    for i, h in enumerate(hw, 1):
        hdr(ww, 3, i, h)
    # Uwaga: Stabilnosc korzysta z kolumn I (Piper błędy) i O (XTTS błędy), F (słowa), C (kat.)
    for i, row in enumerate(rows):
        r = 4 + i
        vals = [row["file"], row["author"], CATN[row["category"]], "TAK" if row["selected"] else "",
                row["ref_norm"], row["ref_words"],
                row["piper_hyp"], None, row["piper_errors"], row["piper_wer_stem"], row["piper_cer"],
                row["piper_len_ratio"],
                row["xtts_hyp"], None, row["xtts_errors"], row["xtts_wer_stem"], row["xtts_cer"],
                row["xtts_len_ratio"], row["xtts_input"], row["xtts_bugs"]]
        fm = {8: "0.0%", 10: "0.0%", 11: "0.0%", 12: "0.00", 14: "0.0%", 16: "0.0%", 17: "0.0%", 18: "0.00"}
        for j, v in enumerate(vals, 1):
            put(ww, r, j, v, F, fmt=fm.get(j))
        put(ww, r, 8, f"=I{r}/F{r}", F, fmt="0.0%")
        put(ww, r, 14, f"=O{r}/F{r}", F, fmt="0.0%")
    lw = 3 + len(rows)
    for c in ("H", "N"):
        ww.conditional_formatting.add(f"{c}4:{c}{lw}", ColorScaleRule(
            start_type="num", start_value=0, start_color="63BE7B", mid_type="num", mid_value=0.15,
            mid_color="FFEB84", end_type="num", end_value=0.5, end_color="F8696B"))
    for c, wdt in zip("ABCDEFGHIJKLMNOPQRST", [40, 16, 12, 6, 50, 7, 50, 8, 8, 8, 8, 8, 50, 8, 8, 8, 8, 8, 50, 35]):
        ww.column_dimensions[c].width = wdt
    ww.row_dimensions[3].height = 45
    ww.freeze_panes = "B4"
    ww.auto_filter.ref = f"A3:T{lw}"

    # ================================================================ Najczęstsze błędy
    wn = wb.create_sheet("Najczestsze_bledy")
    put(wn, 1, 1, "Najczęstsze różnice: fraza w tekście wzorcowym -> fraza w transkrypcji (wszystkie nagrania). "
                  "Część to szum normalizacji/odmiany (np. 'złotych'->'złote') - interesujące są frazy specyficzne "
                  "dla jednego systemu.", FB)
    wn.merge_cells("A1:H1")
    wn.row_dimensions[1].height = 30
    for j, e in enumerate(ENGINES):
        c0 = 1 + j * 4
        wn.merge_cells(start_row=2, start_column=c0, end_row=2, end_column=c0 + 2)
        hdr(wn, 2, c0, LBL[e])
        for k, h in enumerate(["Wzorzec", "Transkrypcja", "Ile razy"]):
            hdr(wn, 3, c0 + k, h, SUB, FB)
        for i, ((a, b), cnt) in enumerate(phrase_cnt[e].most_common(60)):
            put(wn, 4 + i, c0, a or "∅ (wstawienie)")
            put(wn, 4 + i, c0 + 1, b or "∅ (pominięcie)")
            put(wn, 4 + i, c0 + 2, cnt, align=CENTER)
        for k, wdt in enumerate([34, 34, 8]):
            wn.column_dimensions[L(c0 + k)].width = wdt

    # ================================================================ Ciekawe przypadki
    wf = wb.create_sheet("Ciekawe_przypadki")
    put(wf, 1, 1, "Ciekawe przypadki wyłowione automatycznie (sondy różnicujące systemy, błędy normalizacji tekstu XTTS, "
                  "anomalie długości/WER). Kolumna 'Potwierdzone?' - do uzupełnienia po odsłuchu; najlepsze przykłady "
                  "do prezentacji i raportu.", FB)
    wf.merge_cells("A1:G1")
    wf.row_dimensions[1].height = 30
    for i, h in enumerate(["Typ", "Próbka", "Plik", "Opis", "Transkrypcja / dowód", "Potwierdzone? (TAK/NIE)", "Uwagi"], 1):
        hdr(wf, 2, i, h)
    for i, x in enumerate(findings):
        r = 3 + i
        for j, v in enumerate([x["typ"], x["probka"], x["plik"], x["opis"], x["dowod"]], 1):
            put(wf, r, j, v)
        put(wf, r, 6, None, FIN, INP)
        put(wf, r, 7, None, FIN, INP)
    for c, wdt in zip("ABCDEFG", [22, 8, 36, 50, 70, 12, 30]):
        wf.column_dimensions[c].width = wdt
    wf.freeze_panes = "A3"
    wf.auto_filter.ref = f"A2:G{2 + len(findings)}"

    # ================================================================ Front-end tekstu
    wfe = wb.create_sheet("Frontend_tekstu")
    put(wfe, 1, 1, "Jak każdy system zamienia trudne zapisy na mowę - wynik deterministyczny (bez Whispera). "
                   "Piper: fonemy eSpeak-NG = dokładnie to, co powie. XTTS: tekst po wbudowanej normalizacji = to, co "
                   "dostaje model; MODEL = skrót nierozwinięty, model zgaduje wymowę (sprawdź odsłuchem, kolumna J).", FB)
    wfe.merge_cells("A1:J1")
    wfe.row_dimensions[1].height = 42
    for i, h in enumerate(["Zapis", "Oczekiwana wymowa", "Piper: werdykt", "Piper mówi (z fonemów)", "Piper: fonemy IPA",
                           "XTTS: werdykt", "XTTS: tekst wejściowy modelu", "XTTS: uwaga", "Piper: ODSŁUCH",
                           "XTTS: ODSŁUCH (dla MODEL)"], 1):
        hdr(wfe, 2, i, h)
    vfill = {"OK": PatternFill("solid", fgColor="C6EFCE"), "BŁĄD": PatternFill("solid", fgColor="F8CBAD"),
             "CZĘŚCIOWO": PatternFill("solid", fgColor="FFEB9C"), "MODEL": PatternFill("solid", fgColor="DDEBF7")}
    for i, f in enumerate(frontend):
        r = 3 + i
        vals = [f["fragment"], f["expected"], f["piper_verdict"], f["piper_says"], f["piper_ipa"], f["xtts_verdict"],
                f["xtts_input"], f["xtts_note"]]
        for j, v in enumerate(vals, 1):
            put(wfe, r, j, v, FB if j in (3, 6) else F, vfill.get(v) if j in (3, 6) else None,
                align=CENTER if j in (3, 6) else None)
        put(wfe, r, 9, None, FIN, INP)
        put(wfe, r, 10, None, FIN, INP)
    fl = 2 + len(frontend)
    dvf = DataValidation(type="list", formula1='"OK,CZĘŚCIOWO,BŁĄD"', allow_blank=True)
    wfe.add_data_validation(dvf)
    dvf.add(f"I3:J{fl}")
    r = fl + 2
    hdr(wfe, r, 1, "Podsumowanie")
    for j, h in enumerate(["OK", "CZĘŚCIOWO", "BŁĄD", "MODEL"]):
        hdr(wfe, r, 2 + j, h)
    for k, (lab, col) in enumerate([("Piper", "C"), ("XTTS-v2", "F")]):
        put(wfe, r + 1 + k, 1, lab, FB)
        for j, h in enumerate(["OK", "CZĘŚCIOWO", "BŁĄD", "MODEL"]):
            put(wfe, r + 1 + k, 2 + j, f'=COUNTIF({col}$3:{col}${fl},"{h}")', align=CENTER)
    for c, wdt in zip("ABCDEFGHIJ", [20, 36, 12, 36, 40, 12, 40, 34, 12, 14]):
        wfe.column_dimensions[c].width = wdt
    wfe.freeze_panes = "B3"

    # ================================================================ Podsumowanie
    wp = wb.create_sheet("Podsumowanie", 1)
    summary(wp, subj_cols, err_cols, sum_col, FIRST, last, lr, lw, len(probes), fl)
    wb.save(path)


def summary(wp, subj_cols, err_cols, sum_col, FIRST, last, lr, lw, nprobes, fl):
    put(wp, 1, 1, "Podsumowanie ocen (wyliczane automatycznie z pozostałych arkuszy)", FT)
    wp.merge_cells("A1:F1")
    for i, h in enumerate(["Lp", "Kryterium", "Miara", "Piper", "XTTS-v2", "Lepszy"], 1):
        hdr(wp, 3, i, h)
    K = f"Klucz!$B${FIRST}:$B${last}"
    lines = []
    lines.append(("1", "Poprawność wymowy", "łączna liczba błędów w 30 próbkach (Oceny, po odsłuchu)",
                  [f"=SUMIFS(Oceny!${L(sum_col)}${FIRST}:${L(sum_col)}${last},{K},\"{LBL[e]}\")" for e in ENGINES],
                  "min", "0"))
    pcol = {"piper": ("F", "H"), "xtts": ("G", "I")}
    lines.append(("1", "Poprawność wymowy", f"sondy zaliczone [%] (z {nprobes}; ODSŁUCH, a gdy puste - auto)",
                  [f'=(COUNTIFS(Sondy!${pcol[e][1]}$3:${pcol[e][1]}${2 + nprobes},"OK")'
                   f'+COUNTIFS(Sondy!${pcol[e][1]}$3:${pcol[e][1]}${2 + nprobes},"",Sondy!${pcol[e][0]}$3:${pcol[e][0]}${2 + nprobes},"OK"))/{nprobes}'
                   for e in ENGINES], "max", "0.0%"))
    lines.append(("1", "Poprawność wymowy", "WER auto - wszystkie nagrania (Whisper)",
                  [f"=SUM(WER_auto!I4:I{lw})/SUM(WER_auto!F4:F{lw})", f"=SUM(WER_auto!O4:O{lw})/SUM(WER_auto!F4:F{lw})"],
                  "min", "0.0%"))
    lines.append(("1", "Poprawność wymowy", "WER auto - 30 wybranych",
                  [f'=SUMIFS(WER_auto!I4:I{lw},WER_auto!D4:D{lw},"TAK")/SUMIFS(WER_auto!F4:F{lw},WER_auto!D4:D{lw},"TAK")',
                   f'=SUMIFS(WER_auto!O4:O{lw},WER_auto!D4:D{lw},"TAK")/SUMIFS(WER_auto!F4:F{lw},WER_auto!D4:D{lw},"TAK")'],
                  "min", "0.0%"))
    lines.append(("1", "Poprawność wymowy", f"front-end: poprawnie odczytane trudne zapisy (OK + 0,5×CZĘŚCIOWO) / {fl - 2}",
                  [f'=(COUNTIF(Frontend_tekstu!{c}3:{c}{fl},"OK")+0.5*COUNTIF(Frontend_tekstu!{c}3:{c}{fl},"CZĘŚCIOWO"))/{fl - 2}'
                   for c in ("C", "F")], "max", "0.0%"))
    for num, name in SUBJ[:4]:
        c = L(subj_cols[num] + 2)
        lines.append((num, name, "średnia ocen (1-5), obie osoby",
                      [f'=IFERROR(AVERAGEIFS(Oceny!${c}${FIRST}:${c}${last},{K},"{LBL[e]}"),"")' for e in ENGINES],
                      "max", "0.00"))
    lines.append(("6", "Stabilność syntezy", "średnia ocen (1-5), arkusz Stabilnosc",
                  ["=Stabilnosc!D5", "=Stabilnosc!D6"], "max", "0.00"))
    lines.append(("7", "Szybkość generowania", "mediana czasu [s] / wypowiedź (wszystkie)",
                  ["=Czas_generowania!N5", "=Czas_generowania!O5"], "min", "0.000"))
    lines.append(("7", "Szybkość generowania", "średni RTF (wszystkie)",
                  ["=Czas_generowania!N9", "=Czas_generowania!O9"], "min", "0.000"))
    c = L(subj_cols["8"] + 2)
    lines.append(("8", "Przydatność w dialogu", "średnia ocen (1-5), obie osoby",
                  [f'=IFERROR(AVERAGEIFS(Oceny!${c}${FIRST}:${c}${last},{K},"{LBL[e]}"),"")' for e in ENGINES],
                  "max", "0.00"))
    for i, (num, name, miara, fs, better, fmt) in enumerate(lines):
        r = 4 + i
        put(wp, r, 1, num, FB, align=CENTER)
        put(wp, r, 2, name, FB)
        put(wp, r, 3, miara)
        put(wp, r, 4, fs[0], fmt=fmt, align=CENTER)
        put(wp, r, 5, fs[1], fmt=fmt, align=CENTER)
        cmp_ = ">" if better == "max" else "<"
        put(wp, r, 6, f'=IF(OR(D{r}="",E{r}=""),"",IF(D{r}=E{r},"remis",IF(D{r}{cmp_}E{r},"Piper","XTTS-v2")))',
            FB, align=CENTER)
    r = 5 + len(lines)
    put(wp, r, 1, "Błędy wymowy wg kategorii (30 próbek, arkusz Oceny)", FB)
    wp.merge_cells(start_row=r, start_column=1, end_row=r, end_column=3)
    hdr(wp, r + 1, 2, "Kategoria")
    hdr(wp, r + 1, 4, "Piper")
    hdr(wp, r + 1, 5, "XTTS-v2")
    for i, (code, name) in enumerate(ERRC):
        rr = r + 2 + i
        put(wp, rr, 2, f"{code}: {name}", FB)
        cl = L(err_cols[code])
        for j, e in enumerate(ENGINES):
            put(wp, rr, 4 + j, f"=SUMIFS(Oceny!${cl}${FIRST}:${cl}${last},{K},\"{LBL[e]}\")", align=CENTER)
    r = r + 3 + len(ERRC)
    put(wp, r, 1, "Średnia ocen subiektywnych (kryt. 2-5, 8) wg kategorii tekstu - patrz arkusz Stabilnosc (wiersze 9-14)", F)
    wp.merge_cells(start_row=r, start_column=1, end_row=r, end_column=6)
    for c, wdt in zip("ABCDEF", [5, 24, 55, 12, 12, 10]):
        wp.column_dimensions[c].width = wdt


def instr(ws):
    ws.column_dimensions["A"].width = 120
    text = [
        ("Ćwiczenie 2 - ocena porównawcza TTS: Piper (pl_PL-darkman-medium) vs XTTS-v2 (Claribel Dervla)", FT),
        ("", F),
        ("CO JEST W PLIKU", FB),
        ("• Oceny - główny arkusz do odsłuchu: 30 próbek × 2 systemy = 60 wierszy, ZANONIMIZOWANE (A/B losowo dla każdej próbki).", F),
        ("• Podsumowanie - średnie i zwycięzca w każdym kryterium; liczy się samo z pozostałych arkuszy.", F),
        ("• Stabilnosc - kryterium 6 (jedna ocena na system), z pomocniczym zestawieniem wyników wg kategorii tekstu.", F),
        ("• Sondy - ok. 160 trudnych fragmentów (skróty, liczby, nazwy...) z oczekiwaną wymową i wynikiem automatycznym.", F),
        ("• Czas_generowania - kryterium 7, pomiary dla wszystkich 160 tekstów (gotowe, nic nie trzeba wpisywać).", F),
        ("• WER_auto - kryterium 1 automatycznie dla wszystkich 160 tekstów (Whisper large-v3).", F),
        ("• Frontend_tekstu - deterministyczne porównanie, jak każdy system czyta ~40 trudnych zapisów (skróty, daty, jednostki, duże liczby).", F),
        ("• Najczestsze_bledy, Ciekawe_przypadki - materiał do raportu/prezentacji.", F),
        ("• Klucz - UKRYTY arkusz z przypisaniem A/B -> system. Nie odkrywać przed zakończeniem ocen.", F),
        ("", F),
        ("KOLORY", FB),
        ("• Żółte komórki = do uzupełnienia ręcznie. Szare komórki z szarą kursywą = wstępnie wypełnione automatycznie, do weryfikacji/poprawy.", F),
        ("", F),
        ("PROCEDURA (każda osoba osobno, potem wspólnie)", FB),
        ("1. Odtwarzaj nagrania z folderu output/odsluch/ (S01_A.wav, S01_B.wav, ...). Wszystkie mają ten sam format (24 kHz, mono, 16 bit) i wyrównaną głośność.", F),
        ("   Teksty wejściowe są też w output/odsluch/teksty.txt. Nie zaglądaj do output/piper i output/xtts ani do klucza.", F),
        ("2. Najpierw przesłuchaj kilka próbek obu systemów (kalibracja skali), potem oceniaj po kolei. Każde nagranie można odtworzyć wielokrotnie.", F),
        ("3. Kryteria 2, 3, 4, 5, 8 - wpisz liczbę 1-5 w kolumnie 'Osoba 1' (Aleksander) lub 'Osoba 2' (Mieszko). Oceniajcie niezależnie, bez podglądania ocen drugiej osoby.", F),
        ("   5 = bardzo dobra (naturalna, płynna, zrozumiała), 4 = dobra (niewielkie niedoskonałości), 3 = dostateczna (zauważalne, ale zrozumiała),", F),
        ("   2 = słaba (liczne niedoskonałości utrudniające odbiór), 1 = bardzo słaba (trudna do zrozumienia). Średnia liczy się sama.", F),
        ("   2 Zrozumiałość - na ile łatwo rozpoznać treść | 3 Naturalność - podobieństwo do mowy ludzkiej | 4 Intonacja i prozodia - akcent, rytm, tempo, intonacja (pytania!, wykrzykniki!)", F),
        ("   5 Płynność - nienaturalne przerwy, zniekształcenia, artefakty, urwane końcówki | 8 Przydatność w dialogu - czy nadaje się do rozmowy z klientem sklepu.", F),
        ("4. Kryterium 1 (obiektywne) - w kolumnach L/D/S/N/O/W/A wpisz LICZBĘ błędów danej kategorii w nagraniu (wspólnie, jedna wartość).", F),
        ("   Szare liczby to sugestia z automatu (sondy niezaliczone w transkrypcji Whisper) - popraw je po odsłuchu (Whisper czasem 'naprawia' błędną wymowę, czasem sam się myli).", F),
        ("   L liczby | D daty/godziny | S skróty i skrótowce (ul., dr, DDR, USB) | N nazwy własne | O wyrazy obce/spolszczone | W zgubione/zmienione słowa nośne znaczenia (nie, tylko, aż, niestety)", F),
        ("   A błędny akcent lub inna zła wymowa zwykłego słowa. W kolumnie 'Opis błędów' zapisz krótko, co było źle (np. 'dr -> de er', '15.12.2026 -> piętnaście przecinek...').", F),
        ("   Kolumna 'Opis błędów' zawiera listę automatycznie podejrzanych fragmentów ('auto: ...') - nadpisz ją swoim opisem.", F),
        ("5. Dopiero po arkuszu Oceny: arkusz Sondy - w kolumnach ODSŁUCH wybierz OK/BŁĄD dla wierszy, gdzie automat się pomylił (puste = wynik auto jest przyjęty).", F),
        ("6. Arkusz Stabilnosc - po wysłuchaniu wszystkiego oceń każdy system 1-5: czy jakość jest równa dla krótkich komunikatów, pytań, liczb, długich zdań i obcych nazw.", F),
        ("7. Arkusz Ciekawe_przypadki - zaznacz TAK przy potwierdzonych przypadkach; to gotowe przykłady do prezentacji (nagrania: output/piper, output/xtts).", F),
        ("8. Odkryj arkusz Klucz (PPM na karcie -> Odkryj) dopiero na końcu; Podsumowanie i Stabilnosc liczą średnie per system niezależnie od tego.", F),
        ("", F),
        ("PRZYKŁAD WYPEŁNIENIA (jeden wiersz arkusza Oceny)", FB),
        ("S13_A | Zrozumiałość 4 / 5 | Naturalność 3 / 3 | Intonacja 3 / 2 | Płynność 4 / 4 | Przydatność 3 / 3 | L=1 D=2 S=3 N=0 O=0 W=0 A=1 | 'pn.–pt. przeczytane jako pe en pe te; 10:00 -> dziesięć zero zero; 58/3 -> pięćdziesiąt osiem trzy'", F),
        ("", F),
        ("UWAGI METODOLOGICZNE", FB),
        ("• Czas (kryt. 7) mierzono w main.py: od wywołania syntezy do zapisania WAV, po 2 żądaniach rozgrzewkowych, 3 powtórzenia - mediana. Ładowanie modelu nie jest wliczone. Piper na CPU, XTTS na GPU.", F),
        ("• WER auto: tekst wejściowy i transkrypcję normalizujemy tą samą procedurą (pl_norm.py: cyfry, daty, skróty -> słowa). Zawiera szum odmiany przez przypadki; ten sam wzorzec dla obu systemów, więc porównanie względne jest uczciwe.", F),
        ("• XTTS-v2 ma własną, uproszczoną normalizację tekstu polskiego (num2words + 5 skrótów). Kolumna 'Tekst po normalizacji XTTS' w WER_auto pokazuje, co faktycznie trafia do modelu - wyjaśnia wiele błędów (np. 'm.' -> 'pan', daty -> 'przecinek').", F),
        ("• Piper czyta tekst przez fonemizator eSpeak-NG (własne reguły liczb i skrótów).", F),
        ("• Głosy różnią się płcią (Piper - męski, XTTS - żeński), więc pełna anonimizacja nie jest możliwa; mimo to oceniajcie według kryteriów, nie według preferencji głosu.", F),
    ]
    for i, (t, f) in enumerate(text, 1):
        c = ws.cell(row=i, column=1, value=t)
        c.font = f
        c.alignment = Alignment(wrap_text=True, vertical="top")
