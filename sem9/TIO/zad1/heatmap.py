import matplotlib.pyplot as plt
import numpy as np

data = np.loadtxt("results.txt", skiprows=1)
crossovers = np.unique(data[:, 0])
mutations = np.unique(data[:, 1])
fitness = np.array([
	[data[(data[:, 0] == crossover) & (data[:, 1] == mutation), 2][0]
	 for mutation in mutations]
	for crossover in crossovers
])

plt.imshow(fitness, cmap="viridis", aspect="auto")
plt.xticks(range(len(mutations)), mutations)
plt.yticks(range(len(crossovers)), crossovers)
plt.xlabel("mutation")
plt.ylabel("crossover")

for row in range(len(crossovers)):
	for column in range(len(mutations)):
		plt.text(column, row, f"{fitness[row, column]:.0f}",
			ha="center", va="center", color="white")

plt.savefig("heatmap.png", dpi=150, bbox_inches="tight")
print("Zapisano heatmap.png")