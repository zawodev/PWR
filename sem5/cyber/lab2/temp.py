import string

def generate_substitution_key(plaintext, ciphertext):
    # utwórz listę dla klucza, wypełnioną początkowo znakami '-'
    alphabet = list(string.ascii_uppercase)
    key = ['-' for _ in range(26)]

    # przechodzimy przez tekst jawny i zaszyfrowany, mapując litery
    for pt_char, ct_char in zip(plaintext.upper(), ciphertext.upper()):
        if pt_char in alphabet and ct_char in alphabet:
            pt_index = alphabet.index(pt_char)
            key[pt_index] = ct_char

    # uzupełniamy brakujące litery w porządku rosnącym
    used_letters = set(key) - {'-'}
    remaining_letters = [ch for ch in alphabet if ch not in used_letters]

    # wstawiamy brakujące litery w odpowiednie miejsca
    for i in range(len(key)):
        if key[i] == '-':
            key[i] = remaining_letters.pop(0)

    return ''.join(key)

# przykładowe teksty jawny i zaszyfrowany
plaintext = """
The Enigma machine was a field unit used in World War II by German field agents to encrypt and decrypt messages and communications. 
"""
ciphertext = """
Obt Ticahq hqebcit uqn q yctgr pico pntr ci Ujmgr Uqm CC wx Atmhqi yctgr qation oj tiemxko qir rtemxko htnnqatn qir ejhhpiceqocjin.
"""

# generowanie klucza
key = generate_substitution_key(plaintext, ciphertext)
print("Substitution key:", key)
