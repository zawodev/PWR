import string
from collections import Counter


def find_most_frequent_mapping(plain_text, cipher_text):
    # tworzenie klucza (pustego słownika) dla alfabetu
    alphabet = string.ascii_uppercase
    key_mapping = {letter: [] for letter in alphabet}

    # upewnij się, że tekst jawny i zaszyfrowany są w wielkich literach i mają tę samą długość
    plain_text = plain_text.upper()
    cipher_text = cipher_text.upper()

    # inicjalizacja słownika do przechowywania liczby wystąpień liter w obu tekstach
    plain_freq = Counter(plain_text)
    cipher_freq = Counter(cipher_text)

    # iteracja po każdym znaku w tekście
    for i, (plain_char, cipher_char) in enumerate(zip(plain_text, cipher_text)):
        if plain_char in alphabet and cipher_char in alphabet:
            key_mapping[plain_char].append(cipher_char)

    # dla każdej litery tekstu jawnego znajdź najczęściej pojawiającą się zamianę w tekście zaszyfrowanym
    results = {}
    for letter, mapped_letters in key_mapping.items():
        if mapped_letters:
            most_common_letter, count = Counter(mapped_letters).most_common(1)[0]
            plain_count = plain_freq[letter]
            effectiveness = count / plain_count if plain_count > 0 else 0  # oblicz skuteczność
            results[letter] = (most_common_letter, count, plain_count, effectiveness)

    return results


def print_key_mapping(results):
    print(f"{'Letter':<8} {'Mapping':<8} {'Count':<8} {'PlainCount':<12} {'Effectiveness'}")
    print('-' * 55)
    for letter in string.ascii_uppercase:
        if letter in results:
            mapped_letter, count, plain_count, effectiveness = results[letter]
            print(f"{letter:<8} {mapped_letter:<8} {count:<8} {plain_count:<12} {effectiveness:.2f}")
        else:
            print(f"{letter:<8} {'_':<8} {0:<8} {0:<12} {0.00:.2f}")


# przykładowy tekst jawny i zaszyfrowany
plain_text = "The Enigma machine was a field unit used in World War II by German field agents to encrypt and decrypt messages and communications. Similar to the Feistel function of the 1970s, the Enigma machine was one of the first mechanized methods of encrypting text using an iterative cipher. It employed a series of rotors that, with some electricity, a light bulb, and a reflector, allowed the operator to either encrypt or decrypt a message. The original position of the rotors, set with each encryption and based on a prearranged pattern that in turn was based on the calendar, allowed the machine to be used, even if it was compromised. When the Enigma was in use, with each subsequent key press, the rotors would change in alignment from their set positions in such a way that a different letter was produced each time. The operator, with a message in hand, would enter each character into the machine by pressing a typewriter-like key. The rotors would align, and a letter would then illuminate, telling the operator what the letter really was. Likewise, when enciphering, the operator would press the key and the illuminated letter would be the cipher text. The continually changing internal flow of electricity that caused the rotors to change was not random, but it did create a polyalphabetic cipher that could be different each time it was used."
cipher_text = "Hjw Incuua qautyno egi m vownx unch wiax en Mmtph Egj WS lc Ywvoin lscph aiwhhc ho whylcxh enr xqylcxh uwsimusi mnr yuoygjsiavsyny. Iookpqj pm ntk Vasmhsp bgjyfsyn kv htk 1970i, htk Whswoi oiypsbw gay mfw ev htk vojsh uwotwncbwx swptgxa md whylcxhgni hsdt gusbu en chsjuhgfc ymlpwv. Sj wkldmywl a ywvsci wv nmnmti htwh, qsjt umiw ipeyfjwymhk, a tswtr zkpn, anx c jivfwohoj, upjmewl hjw elyjuhoj pm gsjtkj inujalf mt xqylcxh e owikaiw. Ptk mtswsbat luiohgmf md hjw vmnmti, kwp eihj wuyp whylcxhgmf anx zaywl mf a hjiabjuniwl lkhzwvn vtwh gn vgxn may zsiax mn vtk ykpenrab, atpaeux xtk oiypsbw pm pw miax, qfcn cv oh qay yuopjeokiax. Otkn vtk Whswoi egi on sia, eihj wuyp iezqwygknv qmc xjiik, hjw vmnmti ymkph ypanus sb atswnqwhh pjeo dtksp iah lmqsjsyny sb ieyp a mag hjav a rszvajinv pehzwv egi tjexuyyx qaut rsew. Ptk mzwvavmt, eihj a qwsimus sb twnr, eqgpx qnvwv wuyp ypabauhsj wnvm ntk oiypsbw rc xjiiksbu e hklyehsjwv-psqm qmc. Ltk jehojs eqgpx cpsur, anx c pehzwv eqgpx xtkn cpjgmsbavw, pwnpsni hjw elyjuhoj gtwh ztk pehzwv jiatpw egi. Fskwgsmw, gtkn onusvtkjwni, hjw elyjuhoj gmkph llwsi htk qmc qnr hjw wpjgmsbavwl pehzwv eqgpx zw ptk ymlpwv hsdt. Hjw omfhgnsatpw ypanugni sbhsjhat vfme md wnwohfsisjc ltwh yasiax xtk jehojs ho ypanus egi zmn junrmi, zkh gh vsf ylwuhs a hmlcqpxtwzghgy esvtkj ptwh ymkph zg xevxwvwhh saut rsew wh qay guwl."

# znajdź mapowanie liter
key_mapping = find_most_frequent_mapping(plain_text, cipher_text)

# wypisz klucz
print_key_mapping(key_mapping)
