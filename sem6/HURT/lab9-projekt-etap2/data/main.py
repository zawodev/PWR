import codecs

input_file = 'BRAZIL_CITIES.csv'
output_file = 'cities_1250.csv'

# read UTF‑8, write Windows‑1250 (ANSI 1250)
with codecs.open(input_file, 'r', encoding='utf-8') as src, codecs.open(output_file, 'w', encoding='cp1250', errors='replace') as dst:
    for line in src:
        dst.write(line)
