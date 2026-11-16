"""Prosty normalizator tekstu polskiego do porównywania transkrypcji (WER/CER).

Ten sam normalizator stosujemy SYMETRYCZNIE do tekstu wzorcowego i do transkrypcji
Whispera, dzięki czemu różnice w zapisie (Whisper pisze "15 grudnia", "14:30", "zł")
nie są liczone jako błędy syntezatora. Rozwija: daty, godziny, liczby (także
z separatorem tysięcy w postaci spacji), ułamki dziesiętne, ceny, procenty, jednostki
i najczęstsze skróty. Odmiana przez przypadki jest przybliżona - dlatego obok WER
liczymy też WER "na rdzeniach" (porównanie pierwszych 4 liter wyrazu).
"""
import re

from num2words import num2words

MONTHS = ["stycznia", "lutego", "marca", "kwietnia", "maja", "czerwca", "lipca", "sierpnia",
          "września", "października", "listopada", "grudnia"]
ORD_1_19 = ["", "pierwszy", "drugi", "trzeci", "czwarty", "piąty", "szósty", "siódmy", "ósmy",
            "dziewiąty", "dziesiąty", "jedenasty", "dwunasty", "trzynasty", "czternasty", "piętnasty",
            "szesnasty", "siedemnasty", "osiemnasty", "dziewiętnasty"]
ORD_TENS = ["", "", "dwudziesty", "trzydziesty", "czterdziesty", "pięćdziesiąty", "sześćdziesiąty",
            "siedemdziesiąty", "osiemdziesiąty", "dziewięćdziesiąty"]

# Skróty (z kropką lub bez) -> forma mówiona. Kolejność ma znaczenie (dłuższe najpierw).
ABBREV = [
    (r"\bdr\.? hab\.", "doktor habilitowany"), (r"\bprof\.", "profesor"),
    (r"\bm\.in\.", "między innymi"), (r"\btj\.", "to jest"), (r"\bnp\.", "na przykład"),
    (r"\bitp\.", "i tym podobne"), (r"\bitd\.", "i tak dalej"), (r"\btzw\.", "tak zwany"),
    (r"\bul\.", "ulicy"), (r"\bpl\.", "placu"), (r"\bal\.", "alei"), (r"\bgodz\.", "godzinie"),
    (r"\bok\.", "około"), (r"\bnr\.?(?=\s)", "numer"), (r"\bdr\b\.?", "doktor"), (r"\binż\.", "inżynier"),
    (r"\bpn\.", "poniedziałek"), (r"\bwt\.", "wtorek"), (r"\bśr\.", "środa"), (r"\bczw\.", "czwartek"),
    (r"\bpt\.", "piątek"), (r"\bsob\.", "sobota"), (r"\bniedz\.", "niedziela"), (r"\btel\.", "telefon"),
    (r"\bszt\.", "sztuk"), (r"\bwys\.", "wysokości"), (r"\btyg\.", "tygodnie"), (r"\bmax\.", "maksymalnie"),
    (r"\btemp\.", "temperaturze"), (r"\bstr\.", "strony"), (r"\bpd\.", "południowej"),
    (r"\bGł\.", "Główny"), (r"\bCentr\.", "Centralna"), (r"\bodj\.", "odjazd"), (r"\bwag\.", "wagon"),
    (r"\bkat\.", "katalogowy"), (r"\bwew\.", "wewnętrzny"), (r"\bmin\.", "minut"),
    (r"(?<=\d)\s?r\.", " roku"), (r"\br\.(?=\s|$)", "roku"), (r"\bw\.(?=\s|$)", "wieku"),
    (r"\bm\.(?=\s*\d)", "miejsce"), (r"\bs\.(?=\s*\d)", "sala"),
]
UNITS = [  # tylko bezpośrednio po liczbie
    (r"l/100 km", "litrów na sto kilometrów"), (r"mg/l", "miligramów na litr"),
    (r"zł", "złotych"), (r"gr", "groszy"), (r"km", "kilometrów"), (r"kg", "kilogramów"), (r"mm", "milimetrów"),
    (r"cm", "centymetrów"),
    (r"GB", "gigabajtów"), (r"TB", "terabajtów"), (r"MHz", "megaherców"), (r"GHz", "gigaherców"),
    (r"°C", "stopni celsjusza"), (r"°", "stopni"), (r"%", "procent"), (r"h", "godzin"), (r"min", "minut"),
    (r"g", "gramów"), (r"l", "litrów"), (r"tyg\.", "tygodni"),
]
SYMBOLS = {"&": " i ", "×": " razy ", "=": " równa się ", "+": " plus ", "@": " małpa ", "%": " procent ",
           "⅓": " jedna trzecia ", "½": " jedna druga ", "°C": " stopni celsjusza ", "°": " stopni "}
PHONE_CTX = re.compile(r"(tel|telefon|numer\w*|nr|kod|blik|\+)\W*$", re.IGNORECASE)


def ordinal(n: int) -> str:
    """Liczebnik porządkowy, mianownik rodzaju męskiego (1-99)."""
    if n < 20:
        return ORD_1_19[n]
    t, u = divmod(n, 10)
    return ORD_TENS[t] + ("" if u == 0 else " " + ORD_1_19[u])


def _decl(words: str, fem: bool) -> str:
    out = []
    for w in words.split():
        if w.endswith("i"):
            out.append(w + ("ej" if fem else "ego"))
        elif w.endswith("y"):
            out.append(w[:-1] + ("ej" if fem else "ego"))
        else:
            out.append(w)
    return " ".join(out)


def ord_gen(n: int) -> str:  # "piętnastego"
    return _decl(ordinal(n), fem=False)


def ord_fem(n: int) -> str:  # "czternastej" (dopełniacz/miejscownik r.ż. - "o godzinie czternastej")
    return _decl(ordinal(n), fem=True)


def card(n) -> str:
    return num2words(int(n), lang="pl")


def year_gen(y: int) -> str:
    """2026 -> 'dwa tysiące dwudziestego szóstego'"""
    head, tail = divmod(y, 100)
    if tail == 0:
        return card(y)[:-1] + "nego" if y % 1000 == 0 else card(head * 100) + "nego"
    return card(head * 100) + " " + ord_gen(tail)


def digits_or_card(s: str) -> str:
    if len(s) > 1 and s.startswith("0"):
        return " ".join(card(c) for c in s)
    return card(s)


def time_words(h: str, m: str) -> str:
    out = ord_fem(int(h)) if int(h) else "zero"
    if int(m):
        out += " " + (("zero " + card(m)) if m.startswith("0") else card(m))
    return out


def normalize(text: str) -> str:
    t = text
    t = re.sub(r"[„”\"«»“]", " ", t)
    t = t.replace(" ", " ").replace("’", "'")
    t = re.sub(r"([₀-₉])", lambda m: str("₀₁₂₃₄₅₆₇₈₉".index(m.group(1))), t)
    # adresy www
    t = re.sub(r"\b(www\.[\w-]+(?:\.[\w-]+)+)", lambda m: m.group(1).replace(".", " kropka ").replace("-", " ") + " ", t)
    t = re.sub(r"\bpn\.\s?[–-]\s?pt\.", "od poniedziałku do piątku", t, flags=re.IGNORECASE)
    # daty dd.mm.rrrr [r.] / dd.mm
    t = re.sub(r"\b(\d{1,2})\.(\d{1,2})\.(\d{4})(\s?(r\.|roku))?",
               lambda m: (f"{ord_gen(int(m.group(1)))} {MONTHS[int(m.group(2)) - 1]} {year_gen(int(m.group(3)))}"
                          + (" roku" if m.group(4) else ""))
               if 1 <= int(m.group(2)) <= 12 and 1 <= int(m.group(1)) <= 31 else m.group(0), t)
    t = re.sub(r"\b(\d{1,2})\.(\d{2})\b(?!\.\d)(?=\s|$|,)",
               lambda m: f"{ord_gen(int(m.group(1)))} {MONTHS[int(m.group(2)) - 1]}"
               if 1 <= int(m.group(2)) <= 12 and 1 <= int(m.group(1)) <= 31 else m.group(0), t)
    t = re.sub(r"\b(\d{1,2}) (" + "|".join(MONTHS) + r")\b", lambda m: f"{ord_gen(int(m.group(1)))} {m.group(2)}", t,
               flags=re.IGNORECASE)
    # godziny zapisane z kropką (Whisper: "12.35", "14.30") - gdy nie da się ich odczytać jako daty
    t = re.sub(r"\b([01]?\d|2[0-4])\.([0-5]\d)\b(?![.,]\d)", lambda m: f"{m.group(1)}:{m.group(2)}", t)
    # rok: "2016 r." / "w 1993 roku"
    t = re.sub(r"\b(1\d{3}|20\d{2})\s?(r\.|roku)", lambda m: f"{year_gen(int(m.group(1)))} roku", t)
    # zakresy liczbowe 4–6, 9:00–18:00
    t = re.sub(r"(\d)\s?[–—-]\s?(?=\d)", r"\1 do ", t)
    # liczebniki porządkowe zapisane "1. tygodniu"
    t = re.sub(r"(?<![:\d.,])\b(\d{1,2})\.\s+(?=[a-ząćęłńóśźż])", lambda m: ordinal(int(m.group(1))) + " " if 0 < int(m.group(1)) < 100 else m.group(0), t)
    # godziny 14:30 / 9:00
    t = re.sub(r"\b(\d{1,2}):(\d{2})\b", lambda m: time_words(m.group(1), m.group(2)), t)
    # liczby z separatorem tysięcy (spacja) - poza numerami telefonów/kodami
    def join_groups(m):
        if PHONE_CTX.search(t[max(0, m.start() - 12):m.start()]):
            return m.group(0)
        return m.group(0).replace(" ", "")
    t = re.sub(r"(?<![\d,])\b\d{1,3}(?: \d{3})+\b(?!,\d)", join_groups, t)
    t = re.sub(r"(?<![\d,])\b\d{1,3}(?: \d{3})+(?=,\d)", lambda m: m.group(0).replace(" ", ""), t)
    # Whisper: "12,499 zł" / "129,900 zł" - przecinek jako separator tysięcy (3 cyfry po przecinku przy cenie)
    t = re.sub(r"\b(\d{1,3}),(\d{3})(?=\s?zł)", r"\1\2", t)
    # mnożenie zapisane "2x16"
    t = re.sub(r"(\d)\s?[xX]\s?(?=\d)", r"\1 × ", t)
    # ceny 1499,99 zł
    t = re.sub(r"\b(\d+),(\d{2})\s?zł", lambda m: f"{card(m.group(1))} złotych {card(m.group(2))} groszy", t)
    # ułamki dziesiętne
    t = re.sub(r"\b(\d+)[.,](\d+)\b", lambda m: f"{card(m.group(1))} przecinek {digits_or_card(m.group(2))}", t)
    # jednostki po liczbie
    for u, w in UNITS:
        t = re.sub(r"(\d)\s?" + re.escape(u) + r"(?![\w/])", r"\1 " + w, t)
        t = re.sub(r"(przecinek \w+|groszy|\d)\s" + re.escape(u) + r"(?![\w/])", r"\1 " + w, t)
    # skróty
    for pat, w in ABBREV:
        # skróty jednoliterowe (m., s., w., r.) i z wielką literą - z rozróżnianiem wielkości liter
        flags = 0 if re.search(r"\\b[a-z]\\\.|[A-ZŁ]", pat) else re.IGNORECASE
        t = re.sub(pat, " " + w + " ", t, flags=flags)
    for s, w in SYMBOLS.items():
        t = t.replace(s, w)
    t = re.sub(r"(\d+)/(\d+)", r"\1 na \2", t)
    # pozostałe liczby
    t = re.sub(r"\d+", lambda m: " " + digits_or_card(m.group(0)) + " ", t)
    # interpunkcja
    t = t.lower()
    t = re.sub(r"(\w)'(\w)", r"\1\2", t)
    t = re.sub(r"[^\w\s]", " ", t)
    t = t.replace("_", " ")
    return re.sub(r"\s+", " ", t).strip()


if __name__ == "__main__":
    import sys

    for line in sys.argv[1:] or [sys.stdin.read()]:
        print(normalize(line))
