import csv
import matplotlib.pyplot as plt

def load_stops(csv_path, max_name_length=8):
    """
    Wczytuje plik CSV i zwraca słownik: nazwa przystanku -> (lat, lon).
    Uwzględnia tylko przystanki, których nazwa ma max_name_length lub mniej znaków.
    """
    stops = {}
    with open(csv_path, newline='', encoding='utf-8') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            for stop_type in ['start_stop', 'end_stop']:
                name = row[stop_type].strip()
                if len(name) <= max_name_length:  # Filtr na długość nazwy
                    lat = float(row[f'{stop_type}_lat'])
                    lon = float(row[f'{stop_type}_lon'])
                    if name not in stops:
                        stops[name] = (lat, lon)
    return stops

def plot_stops(stops):
    """
    Rysuje punkty reprezentujące przystanki i anotu, podając ich nazwy.
    """
    lats = []
    lons = []
    names = []

    for name, (lat, lon) in stops.items():
        lats.append(lat)
        lons.append(lon)
        names.append(name)

    plt.figure(figsize=(10, 8))
    plt.scatter(lons, lats, c='blue', s=50, alpha=0.7, edgecolors='k')
    plt.title('Wizualizacja przystanków')
    plt.xlabel('Długość geograficzna')
    plt.ylabel('Szerokość geograficzna')

    for name, lon, lat in zip(names, lons, lats):
        plt.annotate(name, (lon, lat), textcoords="offset points", xytext=(5, 5), fontsize=8)

    plt.grid(True)
    plt.show()

def main():
    csv_path = "connection_graph.csv"
    stops = load_stops(csv_path)
    plot_stops(stops)

if __name__ == "__main__":
    main()
    