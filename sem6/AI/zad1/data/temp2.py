import re

# Ścieżki do plików wejściowego i wyjściowego
input_file = 'connection_graph_temp.csv'  # Zmień na swoją nazwę pliku
output_file = 'connection_graph_temp2.csv'

# Otwieranie pliku wejściowego i tworzenie pliku wyjściowego
with open(input_file, 'r', encoding='utf-8') as infile, open(output_file, 'w', encoding='utf-8', newline='') as outfile:
    content = infile.read()

    # Poprawna podmiana wszystkich wystąpień ,24: na ,00: bez dodawania dodatkowych przecinków
    updated_content = re.sub(r'(?<=,)24:(\d{2}:\d{2})', r'00:\1', content)

    updated_content = re.sub(r'(?<=,)25:(\d{2}:\d{2})', r'01:\1', updated_content)
    updated_content = re.sub(r'(?<=,)26:(\d{2}:\d{2})', r'02:\1', updated_content)
    updated_content = re.sub(r'(?<=,)27:(\d{2}:\d{2})', r'03:\1', updated_content)
    updated_content = re.sub(r'(?<=,)28:(\d{2}:\d{2})', r'04:\1', updated_content)
    updated_content = re.sub(r'(?<=,)29:(\d{2}:\d{2})', r'05:\1', updated_content)
    updated_content = re.sub(r'(?<=,)30:(\d{2}:\d{2})', r'06:\1', updated_content)

    outfile.write(updated_content)

print(f"Plik został przetworzony i zapisany jako '{output_file}'")
