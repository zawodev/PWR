import matplotlib.pyplot as plt
import numpy as np

def main():
    # wykres 1
    x1 = [1, 2, 3, 4, 5]
    y1 = [0, 2, 1, 2, 1]
    
    plt.subplot(2, 3, 1)
    plt.plot(x1, y1, marker='o')
    plt.title('Połączone punkty wykres')
    plt.xlabel('X')
    plt.ylabel('Y')
    
    # wykres 2 (nie wyświetlamy)
    x2 = np.linspace(0, 2 * np.pi, 100)
    y2 = np.sin(x2)
    
    # wykres 3
    x3 = np.linspace(-5, 2 * np.pi, 100)
    y3 = np.sin(x3) * np.exp(-(x3/5)**2)
    y4 = np.cos(x3) * np.exp(-(x3/2)**2)
    
    plt.subplot(2, 3, 3)
    plt.plot(x3, y3, label='sin(x) * exp(-(x/5)^2)')
    plt.plot(x3, y4, '--', label='cos(x) * exp(-(x/2)^2)')
    plt.title('Nakładające się funkcje')
    plt.xlabel('X')
    plt.ylabel('Y')
    plt.legend()
    
    # wykres 4
    data = np.random.randn(100)
    plt.subplot(2, 3, 2)
    plt.hist(data, bins=20)
    plt.title('Histogram 100 liczb losowych')
    plt.xlabel('Wartość')
    plt.ylabel('Częstość')
    
    # wykres 5
    x5 = np.random.rand(20) * 10
    y5 = np.random.rand(20) * 10
    plt.subplot(2, 3, 4)
    plt.scatter(x5, y5, marker='*')
    plt.title('Gwiazdki w losowych miejscach')
    plt.xlabel('X')
    plt.ylabel('Y')

    # wykres 6
    # z = x**2 + x * y**2 + y**3
    x6 = np.linspace(-5, 5, 50)
    y6 = np.linspace(-5, 5, 50)
    X6, Y6 = np.meshgrid(x6, y6)
    Z6 = X6**2 + X6 * Y6**2 + Y6**3
    
    ax = plt.subplot(2, 3, 5, projection='3d')
    ax.plot_surface(X6, Y6, Z6, cmap='viridis')
    ax.set_title('Płaszczyzna z = x^2 + x*y^2 + y^3')
    ax.set_xlabel('X')
    ax.set_ylabel('Y')
    ax.set_zlabel('Z')

    # wykres 7
    ax7 = plt.subplot(2, 3, 6, projection='3d')
    
    # cluster 1: gwiazdki, czerwone
    x7_1 = np.random.normal(0, 0.5, 20)
    y7_1 = np.random.normal(0, 0.5, 20)
    z7_1 = x7_1**2 + x7_1 * y7_1**2 + y7_1**3
    ax7.scatter(x7_1, y7_1, z7_1, marker='*', color='red', label='Klaster 1')
    
    # cluster 2: krzyżyki, niebieskie
    x7_2 = np.random.normal(3, 0.5, 20)
    y7_2 = np.random.normal(3, 0.5, 20)
    z7_2 = x7_2**2 + x7_2 * y7_2**2 + y7_2**3
    ax7.scatter(x7_2, y7_2, z7_2, marker='x', color='blue', label='Klaster 2')
    
    # cluster 3: kółka, zielone
    x7_3 = np.random.normal(-3, 0.5, 20)
    y7_3 = np.random.normal(-3, 0.5, 20)
    z7_3 = x7_3**2 + x7_3 * y7_3**2 + y7_3**3
    ax7.scatter(x7_3, y7_3, z7_3, marker='o', color='green', label='Klaster 3')
    
    ax7.set_title('Trzy klastry punktów na płaszczyźnie 3D')
    ax7.set_xlabel('X')
    ax7.set_ylabel('Y')
    ax7.set_zlabel('Z')
    ax7.legend()

    # wyświetlenie wszystkich wykresów
    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    main()