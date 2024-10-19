from lorem_text import lorem
import re

# tekst 1: litera 'n' powtórzona 2000 razy
text1 = 'n' * 2000

# tekst 2: powtórzenie podanego tekstu 1000 razy
text2 = "i ja jechalem na rowerze i potem jeszcze do biedronki na lody " * 1000

# tekst 3: pierwsze 1000 słów lorem ipsum
text3 = ''.join(lorem.words(1000))

def clean_text(text):
    # zamiana polskich znaków na angielskie
    polish_to_english = {
        'ą': 'a', 'ć': 'c', 'ę': 'e', 'ł': 'l', 'ń': 'n',
        'ó': 'o', 'ś': 's', 'ź': 'z', 'ż': 'z',
        'Ą': 'A', 'Ć': 'C', 'Ę': 'E', 'Ł': 'L', 'Ń': 'N',
        'Ó': 'O', 'Ś': 'S', 'Ź': 'Z', 'Ż': 'Z'
    }
    translation_table = str.maketrans(polish_to_english)

    # usuń nowe linie
    text = text.replace('\n', ' ')
    # zamień polskie znaki
    text = text.translate(translation_table)
    # usuń znaki, które nie są w angielskim alfabecie ani spacjami, oraz zamień na małe litery
    cleaned_text = re.sub(r'[^a-zA-Z\s]', '', text).lower()
    # usuń nadmiarowe spacje
    cleaned_text = re.sub(r'\s+', ' ', cleaned_text)
    return cleaned_text.strip()  # usuń spacje z początku i końca tekstu

# przykładowe użycie
text4 = """
Litwo! Ojczyzno moja! ty jesteś jak zdrowie.

Ile cię trzeba cenić, ten tylko się dowie,

Kto cię stracił. Dziś piękność twą w całej ozdobie

Widzę i opisuję, bo tęsknię po tobie.

 

Panno Święta, co Jasnej bronisz Częstochowy

I w Ostrej świecisz Bramie! Ty, co gród zamkowy

Nowogródzki ochraniasz z jego wiernym ludem!

Jak mnie dziecko do zdrowia powróciłaś cudem

(Gdy od płaczącej matki pod Twoję opiekę

Ofiarowany, martwą podniosłem powiekę

I zaraz mogłem pieszo do Twych świątyń progu

Iść za wrócone życie podziękować Bogu),

Tak nas powrócisz cudem na Ojczyzny łono.

Tymczasem przenoś moję duszę utęsknioną

Do tych pagórków leśnych, do tych łąk zielonych,

Szeroko nad błękitnym Niemnem rozciągnionych;

Do tych pól malowanych zbożem rozmaitem,

Wyzłacanych pszenicą, posrebrzanych żytem;

Gdzie bursztynowy świerzop, gryka jak śnieg biała,

Gdzie panieńskim rumieńcem dzięcielina pała,

A wszystko przepasane, jakby wstęgą, miedzą

Zieloną, na niej z rzadka ciche grusze siedzą.

 

Śród takich pól przed laty, nad brzegiem ruczaju,

Na pagórku niewielkim, we brzozowym gaju,

Stał dwór szlachecki, z drzewa, lecz podmurowany;

Świeciły się z daleka pobielane ściany,

Tem bielsze, że odbite od ciemnej zieleni

Topoli, co go bronią od wiatrów jesieni.

Dóm mieszkalny niewielki, lecz zewsząd chędogi,

I stodołę miał wielką, i przy niej trzy stogi

Użątku, co pod strzechą zmieścić się nie może;

Widać, że okolica obfita we zboże,

I widać z liczby kopic, co wzdłuż i wszerz smugów

Świecą gęsto jak gwiazdy, widać z liczby pługów

Orzących wcześnie łany ogromne ugoru,

Czarnoziemne, zapewne należne do dworu,

Uprawne dobrze na kształt ogrodowych grządek:

Że w tym domu dostatek mieszka i porządek.

Brama na wciąż otwarta przechodniom ogłasza,

Że gościnna i wszystkich w gościnę zaprasza.

Właśnie dwókonną bryką wjechał młody panek

I obiegłszy dziedziniec zawrócił przed ganek,

Wysiadł z powozu; konie porzucone same,

Szczypiąc trawę ciągnęły powoli pod bramę.

We dworze pusto, bo drzwi od ganku zamknięto

Zaszczepkami i kołkiem zaszczepki przetknięto.

Podróżny do folwarku nie biegł sług zapytać;

Odemknął, wbiegł do domu, pragnął go powitać.

Dawno domu nie widział, bo w dalekim mieście

Kończył nauki, końca doczekał nareszcie.

Wbiega i okiem chciwie ściany starodawne

Ogląda czule, jako swe znajome dawne.

Też same widzi sprzęty, też same obicia,

Z któremi się zabawiać lubił od powicia;

Lecz mniej wielkie, mniej piękne, niż się dawniej zdały.

I też same portrety na ścianach wisiały.

Tu Kościuszko w czamarce krakowskiej, z oczyma

Podniesionymi w niebo, miecz oburącz trzyma;

Takim był, gdy przysięgał na stopniach ołtarzów,

Że tym mieczem wypędzi z Polski trzech mocarzów

Albo sam na nim padnie. Dalej w polskiej szacie

Siedzi Rejtan żałośny po wolności stracie,

W ręku trzymna nóż, ostrzem zwrócony do łona,

A przed nim leży Fedon i żywot Katona.

Dalej Jasiński, młodzian piękny i posępny,

Obok Korsak, towarzysz jego nieodstępny,

Stoją na szańcach Pragi, na stosach Moskali,

Siekąc wrogów, a Praga już się wkoło pali.

Nawet stary stojący zegar kurantowy

W drewnianej szafie poznał u wniścia alkowy

I z dziecinną radością pociągnął za sznurek,

By stary Dąbrowskiego usłyszyć mazurek.

Biegał po całym domu i szukał komnaty,

Gdzie mieszkał, dzieckiem będąc, przed dziesięciu laty.

Wchodzi, cofnął się, toczył zdumione źrenice

Po ścianach: w tej komnacie mieszkanie kobiéce?

Któż by tu mieszkał? stary stryj nie był żonaty,

A ciotka w Petersburgu mieszkała przed laty.

To nie był ochmistrzyni pokój! Fortepiano?

Na niem noty i książki; wszystko porzucano

Niedbale i bezładnie; nieporządek miły!

Niestare były rączki, co je tak rzuciły.

Tuż i sukienka biała, świeżo z kołka zdjęta

Do ubrania, na krzesła poręczu rozpięta.

A na oknach donice z pachnącemi ziołki,

Geranium, lewkonija, astry i fijołki.

Podróżny stanął w jednym z okien - nowe dziwo:

W sadzie, na brzegu niegdyś zarosłym pokrzywą,

Był maleńki ogródek, ścieżkami porznięty,

Pełen bukietów trawy angielskiej i mięty.

Drewniany, drobny, w cyfrę powiązany płotek

Połyskał się wstążkami jaskrawych stokrotek.

Grządki widać, że były świeżo polewane;

Tuż stało wody pełne naczynie blaszane,

Ale nigdzie nie widać było ogrodniczki;

Tylko co wyszła; jeszcze kołyszą się drzwiczki

Świeżo trącone; blisko drzwi ślad widać nóżki

Na piasku: bez trzewika była i pończoszki;

Na piasku drobnym, suchym, białym na kształt śniegu,

Ślad wyraźny, lecz lekki; odgadniesz, że w biegu

Chybkim był zostawiony nóżkami drobnemi

Od kogoś, co zaledwie dotykał się ziemi.

Podróżny długo w oknie stał patrząc, dumając,

Wonnemi powiewami kwiatów oddychając,

Oblicze aż na krzaki fijołkowe skłonił,

Oczyma ciekawemi po drożynach gonił

I znowu je na drobnych śladach zatrzymywał,

Myślał o nich i, czyje były, odgadywał.

Przypadkiem oczy podniosł, i tu na parkanie

Stała młoda dziewczyna. - Białe jej ubranie

Wysmukłą postać tylko aż do piersi kryje,

Odsłaniając ramiona i łabędzią szyję.

W takiem Litwinka tylko chodzić zwykła z rana,

W takiem nigdy nie bywa od mężczyzn widziana:

Więc choć świadka nie miała, założyła ręce

Na piersiach, przydawając zasłony sukience.

Włos w pukle nierozwity, lecz w węzełki małe

Pokręcony, schowany w drobne strączki białe,

Dziwnie ozdabiał głowę, bo od słońca blasku

Świecił się, jak korona na świętych obrazku.

Twarzy nie było widać. Zwrócona na pole

Szukała kogoś okiem, daleko, na dole;

Ujrzała, zaśmiała się i klasnęła w dłonie,

Jak biały ptak zleciała z parkanu na błonie

I wionęła ogrodem przez płotki, przez kwiaty,

I po desce opartej o ścianę komnaty,

Nim spostrzegł się, wleciała przez okno, świecąca,

Nagła, cicha i lekka jak światłość miesiąca.

Nócąc chwyciła suknie, biegła do zwierciadła;

Wtem ujrzała młodzieńca i z rąk jej wypadła

Suknia, a twarz od strachu i dziwu pobladła.

Twarz podróżnego barwą spłonęła rumianą

Jak obłok, gdy z jutrzenką napotka się ranną;

Skromny młodzieniec oczy zmrużył i przysłonił,

Chciał coś mówić, przepraszać, tylko się ukłonił

I cofnął się; dziewica krzyknęła boleśnie,

Niewyraźnie, jak dziecko przestraszone we śnie;

Podróżny zląkł się, spójrzał, lecz już jej nie było,

Wyszedł zmieszany i czuł, że serce mu biło

Głośno, i sam nie wiedział, czy go miało śmieszyć

To dziwaczne spotkanie, czy wstydzić, czy cieszyć.

Tymczasem na folwarku nie uszło baczności,

Że przed ganek zajechał któryś z nowych gości.

Już konie w stajnię wzięto, już im hojnie dano

Jako w porządnym domu, i obrok, i siano;

Bo Sędzia nigdy nie chciał, według nowej mody,

Odsyłać konie gości Żydom do gospody.

Słudzy nie wyszli witać, ale nie myśl wcale,

Aby w domu Sędziego służono niedbale;

Słudzy czekają, nim się pan Wojski ubierze,

Który teraz za domem urządzał wieczerzę.

On Pana zastępuje i on w niebytności

Pana, zwykł sam przyjmować i zabawiać gości
"""
text4 = clean_text(text4)

# zapisz do osobnych plików tekstowych
with open('tekst1.txt', 'w', encoding='utf-8') as f1:
    f1.write(text1)

with open('tekst2.txt', 'w', encoding='utf-8') as f2:
    f2.write(text2)

with open('tekst3.txt', 'w', encoding='utf-8') as f3:
    f3.write(text4)
