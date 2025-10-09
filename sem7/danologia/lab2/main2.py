import matplotlib.pyplot as plt
import numpy as np
from scipy import signal

def main():
    t = np.linspace(0, 10, 1000)
    fs = 1 / (t[1] - t[0])
    
    # 1) Fala kwadratowa
    y1 = signal.square(2 * np.pi * 1 * t)
    plt.subplot(3, 2, 1)
    plt.plot(t, y1)
    plt.title('Fala kwadratowa')
    plt.xlabel('Czas')
    plt.ylabel('Amplituda')
    
    freq1, Pxx1 = signal.periodogram(y1, fs=fs)
    plt.subplot(3, 2, 2)
    plt.loglog(freq1, Pxx1)
    plt.title('Periodogram - Fala kwadratowa')
    plt.xlabel('Częstotliwość [Hz]')
    plt.ylabel('Gęstość mocy')
    
    # 2) Fala trójkątna
    y2 = signal.sawtooth(2 * np.pi * 1 * t, width=0.5)
    plt.subplot(3, 2, 3)
    plt.plot(t, y2)
    plt.title('Fala trójkątna')
    plt.xlabel('Czas')
    plt.ylabel('Amplituda')
    
    freq2, Pxx2 = signal.periodogram(y2, fs=fs)
    plt.subplot(3, 2, 4)
    plt.loglog(freq2, Pxx2)
    plt.title('Periodogram - Fala trójkątna')
    plt.xlabel('Częstotliwość [Hz]')
    plt.ylabel('Gęstość mocy')
    
    # 3) Fala świergotowa (chirp)
    y3 = signal.chirp(t, f0=1, t1=10, f1=100)
    plt.subplot(3, 2, 5)
    plt.plot(t, y3)
    plt.title('Fala świergotowa')
    plt.xlabel('Czas')
    plt.ylabel('Amplituda')
    
    freq3, Pxx3 = signal.periodogram(y3, fs=fs)
    plt.subplot(3, 2, 6)
    plt.loglog(freq3, Pxx3)
    plt.title('Periodogram - Fala świergotowa')
    plt.xlabel('Częstotliwość [Hz]')
    plt.ylabel('Gęstość mocy')
    
    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    main()

