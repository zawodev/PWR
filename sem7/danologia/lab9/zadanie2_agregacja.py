import numpy as np
import seaborn as sns

print(f"{'-'*20} Zadanie 2: Agregacja {'-'*20}")

# standaryzacja iris
df = sns.load_dataset("iris")
data = np.array(df.iloc[:, 0:4]) # wybieramy tylko kolumny liczbowe (pierwsze 4)
print("Dane oryginalne (pierwszy wiersz):")
print(data[0])
print(data[1])

# ---------------------- Zadanie 2a ----------------------

print(f"\n{'-'*20} Zadanie 2a {'-'*20}")

# standaryzacja: (x - średnia) / odchylenie
# axis=0 oznacza operację wzdłuż kolumn (dla każdej cechy osobno)
means = np.mean(data, axis=0)
stds = np.std(data, axis=0)
standardized = (data - means) / stds

print("Dane po standaryzacji (pierwszy wiersz):")
print(standardized[0])
print(standardized[1])

# ---------------------- Zadanie 2b ----------------------

print(f"\n{'-'*20} Zadanie 2b {'-'*20}")

# algorytm quicksort z partition
def partition(arr, low, high):
    # wybieramy ostatni element jako pivot
    pivot = arr[high]
    i = low - 1
    for j in range(low, high):
        if arr[j] <= pivot:
            i += 1
            arr[i], arr[j] = arr[j], arr[i]
    arr[i + 1], arr[high] = arr[high], arr[i + 1]
    return i + 1

def quicksort(arr, low, high):
    if low < high:
        pi = partition(arr, low, high)
        quicksort(arr, low, pi - 1)
        quicksort(arr, pi + 1, high)

arr = [10, 7, 8, 9, 1, 5]
print(f"Tablica przed sortowaniem: {arr}")
quicksort(arr, 0, len(arr) - 1)
print(f"Posortowana tablica: {arr}")

# ---------------------- Zadanie 2c ----------------------

print(f"\n{'-'*20} Zadanie 2c {'-'*20}")

# moda (dominanta)
def get_mode(vec):
    # unique zwraca unikalne wartości i ich liczniki
    vals, counts = np.unique(vec, return_counts=True)
    # argmax zwraca indeks największej wartości
    index = np.argmax(counts)
    return vals[index]

vec = np.array([1, 2, 3, 2, 2, 4, 5, 5, 2, 1])
print(f"Wektor: {vec}")
print(f"Moda dla wektora: {get_mode(vec)}")
