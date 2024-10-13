import string


def caesar_cipher_decrypt(text, shift):
    decrypted_text = []
    alphabet = string.ascii_uppercase
    text = text.upper()

    for char in text:
        if char in alphabet:
            # znajdź indeks litery, przesun ją i dodaj do wyniku
            new_index = (alphabet.index(char) - shift) % 26
            decrypted_text.append(alphabet[new_index])
        else:
            # jeśli znak nie jest literą, pozostaje taki sam
            decrypted_text.append(char)

    return ''.join(decrypted_text)


def all_caesar_shifts(text):
    for shift in range(26):
        decrypted_text = caesar_cipher_decrypt(text, shift)
        print(f"Shift {shift}: {decrypted_text}")


# przykładowy tekst zaszyfrowany
ciphertext = "Znk Ktomsg sginotk cgy g lokrj atoz aykj ot Cuxrj Cgx OO he Mkxsgt lokrj gmktzy zu ktixevz gtj jkixevz skyygmky gtj iussatoigzouty. Yosorgx zu znk Lkoyzkr latizout ul znk 1970y, znk Ktomsg sginotk cgy utk ul znk loxyz skingtofkj skznujy ul ktixevzotm zkdz ayotm gt ozkxgzobk iovnkx. Oz ksvruekj g ykxoky ul xuzuxy zngz, cozn yusk krkizxoioze, g romnz harh, gtj g xklrkizux, grruckj znk uvkxgzux zu koznkx ktixevz ux jkixevz g skyygmk. Znk uxomotgr vuyozout ul znk xuzuxy, ykz cozn kgin ktixevzout gtj hgykj ut g vxkgxxgtmkj vgzzkxt zngz ot zaxt cgy hgykj ut znk igrktjgx, grruckj znk sginotk zu hk aykj, kbkt ol oz cgy iusvxusoykj. Cnkt znk Ktomsg cgy ot ayk, cozn kgin yahykwaktz qke vxkyy, znk xuzuxy cuarj ingtmk ot gromtsktz lxus znkox ykz vuyozouty ot yain g cge zngz g jollkxktz rkzzkx cgy vxujaikj kgin zosk. Znk uvkxgzux, cozn g skyygmk ot ngtj, cuarj ktzkx kgin ingxgizkx otzu znk sginotk he vxkyyotm g zevkcxozkx-roqk qke. Znk xuzuxy cuarj gromt, gtj g rkzzkx cuarj znkt orrasotgzk, zkrrotm znk uvkxgzux cngz znk rkzzkx xkgrre cgy. Roqkcoyk, cnkt ktiovnkxotm, znk uvkxgzux cuarj vxkyy znk qke gtj znk orrasotgzkj rkzzkx cuarj hk znk iovnkx zkdz. Znk iutzotagrre ingtmotm otzkxtgr lruc ul krkizxoioze zngz igaykj znk xuzuxy zu ingtmk cgy tuz xgtjus, haz oz joj ixkgzk g vuregrvnghkzoi iovnkx zngz iuarj hk jollkxktz kgin zosk oz cgy aykj."

# wypisz wszystkie przesunięcia
all_caesar_shifts(ciphertext)
