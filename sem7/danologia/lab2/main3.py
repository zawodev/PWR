import matplotlib.pyplot as plt
import numpy as np
from scipy import signal

def main():
    t = np.linspace(0, 10, 1000)
    fs = 1 / (t[1] - t[0])
    
    # Fale
    y_a = signal.square(2 * np.pi * 1 * t)  # kwadratowy
    y_b = signal.chirp(t, f0=1, t1=10, f1=100)  # świergotliwy
    y_c = signal.sawtooth(2 * np.pi * 1 * t, width=1)  # piła
    
    y_d = (np.sin(2*np.pi*1*t) + np.sin(2*np.pi*3*t) + np.sin(2*np.pi*5*t) + 
           np.cos(2*np.pi*2*t) + np.cos(2*np.pi*4*t) + np.cos(2*np.pi*6*t))  # superpozycja
    
    # Okienko pierwsze: fale
    plt.figure(1)
    plt.subplot(2, 2, 1)
    plt.plot(t, y_a)
    plt.title('Kwadratowy')
    plt.xlabel('Czas')
    plt.ylabel('Amplituda')
    
    plt.subplot(2, 2, 2)
    plt.plot(t, y_b)
    plt.title('Piła')
    plt.xlabel('Czas')
    plt.ylabel('Amplituda')
    
    plt.subplot(2, 2, 3)
    plt.plot(t, y_c)
    plt.title('Świergotliwy')
    plt.xlabel('Czas')
    plt.ylabel('Amplituda')
    
    plt.subplot(2, 2, 4)
    plt.plot(t, y_d)
    plt.title('Superpozycja sinusów i cosinusów')
    plt.xlabel('Czas')
    plt.ylabel('Amplituda')
    
    plt.tight_layout()
    
    # Okienko drugie: Welch
    plt.figure(2)
    freq_a, Pxx_a = signal.welch(y_a, fs=fs)
    plt.subplot(2, 2, 1)
    plt.semilogy(freq_a, Pxx_a)
    plt.title('Welch - Kwadratowy')
    plt.xlabel('Częstotliwość [Hz]')
    plt.ylabel('Gęstość mocy')
    
    freq_b, Pxx_b = signal.welch(y_b, fs=fs)
    plt.subplot(2, 2, 2)
    plt.semilogy(freq_b, Pxx_b)
    plt.title('Welch - Piła')
    plt.xlabel('Częstotliwość [Hz]')
    plt.ylabel('Gęstość mocy')
    
    freq_c, Pxx_c = signal.welch(y_c, fs=fs)
    plt.subplot(2, 2, 3)
    plt.semilogy(freq_c, Pxx_c)
    plt.title('Welch - Świergotliwy')
    plt.xlabel('Częstotliwość [Hz]')
    plt.ylabel('Gęstość mocy')
    
    freq_d, Pxx_d = signal.welch(y_d, fs=fs)
    plt.subplot(2, 2, 4)
    plt.semilogy(freq_d, Pxx_d)
    plt.title('Welch - Superpozycja')
    plt.xlabel('Częstotliwość [Hz]')
    plt.ylabel('Gęstość mocy')
    
    plt.tight_layout()
    plt.show()
    
    # Zadanie 2: Filtr Wienera
    t2 = np.linspace(0, 10, 1000)
    f = 1  # Częstotliwość sinusa
    y_clean = np.sin(2 * np.pi * f * t2)
    noise = np.random.randn(len(t2)) * 0.5  # Biały szum
    y_noisy = y_clean + noise
    
    # Filtr Wienera
    y_filtered = signal.wiener(y_noisy)
    
    # Wykresy
    plt.figure(3)
    plt.subplot(2, 1, 1)
    plt.plot(t2, y_noisy, label='Z szumem')
    plt.plot(t2, y_clean, label='Oryginalny', linewidth=2)
    plt.title('Sinus z białym szumem')
    plt.xlabel('Czas')
    plt.ylabel('Amplituda')
    plt.legend()
    
    plt.subplot(2, 1, 2)
    plt.plot(t2, y_filtered, label='Po filtrze Wienera')
    plt.plot(t2, y_clean, label='Oryginalny', linewidth=2)
    plt.title('Próba odszumienia filtrem Wienera')
    plt.xlabel('Czas')
    plt.ylabel('Amplituda')
    plt.legend()
    
    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    main()