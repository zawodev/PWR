# ZAPYTANIE OFERTOWE
## TAKT (Transport, Automatyzacja, Kontrola, Trasy) - Platforma dyspozytorska transportu pracowniczego
**XYZ Transport Sp. z o.o.** | Wrocław, styczeń 2025

---

## 1. Zamawiający

**XYZ Transport Sp. z o.o.**  
ul. Przykładowa 1, 50-000 Wrocław  
NIP: 000-000-00-00  
Kontakt: Jan Kowalski, j.kowalski@xyztransport.pl

---

## 2. Opis aktualnego procesu biznesowego

Firma świadczy usługi transportu pracowników do zakładów pracy w aglomeracji wrocławskiej. Flotę stanowi ok. 30 pojazdów (samochody osobowe, busy, autobusy). Obsługiwanych jest ok. 15 kontrahentów abonamentowych i kilkudziesięciu incydentalnych miesięcznie.

**Obecne narzędzia:** arkusze Excel, telefon, komunikator.

**I — Obsługa zapytania o transport** (wyzwalacz: zgłoszenie kontrahenta)

Zapytanie wpływa do biura. Jeśli transport ma być natychmiastowy, koordynator od razu sprawdza dostępność kierowcy i pojazdu w Excelu. Jeśli wymaga planowania, zapytanie trafia do podprocesu planowania: koordynator analizuje arkusz dostępności, a następnie albo aktualizuje arkusz transportów (transport zaplanowany), albo kontaktuje się z klientem informując o braku możliwości realizacji.

**II — Planowanie tygodniowe** (wyzwalacz: cykliczny — przygotowanie planu na nowy tydzień)

Koordynator sprawdza, czy arkusz na dany tydzień już istnieje. Jeśli nie — tworzy nowy. Następnie analizuje arkusz zleceń cyklicznych i planuje transporty na nadchodzący tydzień, uzupełniając arkusz tygodniowy.

**III — Powiadamianie kierowców** (wyzwalacz: cykliczny — dzień przed realizacją)

Koordynator analizuje Excele z planami i tworzy plan na kolejny dzień. Każdy kierowca informowany jest przez chat (standardowo) lub telefonicznie. Kierowca odczytuje zlecenie i realizuje transport.

Proces realizowany jest przez trzy powiązane przepływy wyzwalane różnymi zdarzeniami:
![Aktualny proces biznesowy](transport_bpmn.png "Aktualny proces biznesowy")

**Zidentyfikowane problemy:**
- transporty cykliczne przepisywane ręcznie z arkusza zleceń do arkusza tygodniowego — podatne na błędy i czasochłonne,
- plan dnia tworzony ręcznie każdego wieczoru na podstawie analizy wielu arkuszy,
- powiadamianie kierowców dwoma kanałami (chat + telefon) bez jednolitego systemu potwierdzenia odbioru,
- brak weryfikacji tożsamości pasażerów na etapie realizacji transportu,
- brak automatycznego rozliczania i fakturowania.

---

## 3. Uzasadnienie zapotrzebowania na dedykowany system

Przeprowadzono przegląd dostępnych na rynku systemów TMS (Transport Management System):

| System | Zarządzanie listą pasażerów | Weryfikacja QR | Rozliczenia abonamentowe | Transport pracowniczy (nie towarowy) |
|---|---|---|---|---|
| TMS Falcon (optidata.pl) | Nie | Nie | Nie | Nie |
| Trans.eu | Nie | Nie | Częściowo | Nie |
| Route4Me | Nie | Nie | Nie | Nie |
| SimpliRoute | Nie | Nie | Nie | Nie |

Żaden z przeanalizowanych systemów nie obsługuje łącznie: zarządzania uprawnieniami pasażerów, weryfikacji tożsamości przez QR oraz rozliczeń abonamentowych właściwych dla transportu pracowniczego. Konieczne jest zamówienie rozwiązania dedykowanego.

---

## 4. Wymagania funkcjonalne

Wymagania zapisano w formie historyjek użytkownika. Role: **Kontrahent** (zamawiający transport), **Koordynator** (dyspozytor XYZ), **Kierowca**.

### 4.1 Zamawianie transportu

| ID | Historyjka | Uwagi |
|---|---|---|
| US-01 | Jako **kontrahent** chcę złożyć zamówienie na jednorazowy transport (trasa, liczba osób, termin), aby obsłużyć niestandardową zmianę. | |
| US-02 | Jako **kontrahent** chcę zdefiniować cykliczny transport (harmonogram tygodniowy), aby nie składać zamówienia co tydzień. | |
| US-03 | Jako **kontrahent** chcę otrzymać potwierdzenie lub odmowę zamówienia w ciągu 30 min, aby móc poinformować pracowników. | SLA |
| US-04 | Jako **kontrahent** chcę zarządzać listą uprawnionych pracowników i generować dla nich kody QR, aby kontrolować dostęp do pojazdu. | |

### 4.2 Planowanie i dyspozycja

| ID | Historyjka | Uwagi |
|---|---|---|
| US-05 | Jako **koordynator** chcę przypisać kierowcę i pojazd do transportu z uwzględnieniem dostępności i pojemności, aby zoptymalizować flotę. | |
| US-06 | Jako **koordynator** chcę, aby transporty cykliczne były automatycznie dodawane do planu tygodniowego, aby wyeliminować ręczne przepisywanie. | |
| US-07 | Jako **koordynator** chcę edytować plan dnia w trakcie jego realizacji i automatycznie powiadamiać kierowcę, aby reagować na zmiany. | |

### 4.3 Realizacja transportu (kierowca)

| ID | Historyjka | Uwagi |
|---|---|---|
| US-08 | Jako **kierowca** chcę widzieć plan dnia na urządzeniu mobilnym (trasy, godziny, liczba pasażerów), aby nie potrzebować kontaktu telefonicznego z koordynatorem w typowych przypadkach. | Urządzenie: Android 8.0+, praca offline |
| US-09 | Jako **kierowca** chcę zeskanować kod QR pasażera i natychmiast zobaczyć wynik weryfikacji (uprawniony/nieautoryzowany), aby kontrolować dostęp do pojazdu. | Czas odczytu < 0,5 s |
| US-10 | Jako **kierowca** chcę rejestrować zdarzenia (spóźnienie pasażera, odmowa przejazdu), aby koordynator miał kompletny obraz realizacji. | |

### 4.4 Rozliczenia

| ID | Historyjka | Uwagi |
|---|---|---|
| US-11 | Jako **koordynator** chcę, aby system automatycznie wygenerował zestawienie wykonanych transportów per kontrahent na koniec okresu rozliczeniowego, aby przyspieszyć fakturowanie. | |
| US-12 | Jako **koordynator** chcę obsługiwać model abonamentowy (limit przejazdów) z automatycznym wyliczeniem niedowykonania/nadwykonania i kwoty korekty, aby wyeliminować ręczne kalkulacje. | |

---

## 5. Wymagania niefunkcjonalne

| Obszar | Wymaganie |
|---|---|
| Dostępność | System webowy i mobilny: dostępność ≥ 99,5% (24/7) |
| Wydajność | Weryfikacja QR: < 0,5 s przy połączeniu LTE; tryb offline z synchronizacją po powrocie zasięgu |
| Bezpieczeństwo | Szyfrowanie danych w transmisji (TLS 1.2+); przechowywanie danych osobowych zgodne z RODO |
| Integracja | API REST do eksportu danych rozliczeniowych do systemów FK zewnętrznych |
| Urządzenia kierowcy | Android 8.0+; klasa ochrony min. IP54; praca w zakresie temp. −10°C ÷ +45°C |
| Skalowalność | Obsługa do 100 pojazdów i 500 aktywnych kontrahentów bez zmiany architektury |

---

## 6. Wymagania wobec Oferenta

Oferent zobowiązany jest wykazać:

- min. 3 wdrożone systemy webowo-mobilne w ciągu ostatnich 3 lat,
- doświadczenie w integracji aplikacji mobilnych z czytnikami kodów kreskowych/QR,
- gotowość do realizacji projektu w metodyce zwinnej (Scrum/Kanban) z dostarczaniem działającego oprogramowania co sprint.

---

## 7. Kryteria oceny ofert

| Kryterium | Waga |
|---|---|
| Cena (łączna, netto) | 40% |
| Jakość techniczna (architektura, bezpieczeństwo, UX) | 30% |
| Harmonogram i propozycja MVP | 20% |
| Doświadczenie w podobnych projektach | 10% |

---

## 8. Oczekiwana zawartość oferty

1. Proponowana architektura systemu (diagram komponentów lub C4).
2. Lista funkcjonalności MVP wraz z uzasadnieniem wyboru.
3. Harmonogram realizacji (Gantt lub roadmapa sprintów).
4. Kosztorys z podziałem na etapy (fixed price / T&M — z uzasadnieniem).
5. Wykaz referencji i skład zespołu.

---

## 9. Warunki formalne

- **Termin składania ofert:** 27.01.2025, godz. 12:00
- **Forma:** elektroniczna na adres rfp@xyztransport.pl
- **Termin związania ofertą:** 30 dni
- **Pytania do RFP:** do 20.01.2025 na powyższy adres; odpowiedzi publikowane zbiorczo.

