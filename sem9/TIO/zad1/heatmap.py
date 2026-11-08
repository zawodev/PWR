import matplotlib.pyplot as plt
import numpy as np
from matplotlib.colors import LinearSegmentedColormap, Normalize


def load_results():
	with open("results.txt", newline="", encoding="utf-8") as file:
		return [
			(parts[0], float(parts[1]), float(parts[2]),
				int(parts[3]), float(parts[4]))
			for line in file
			for parts in [line.split()]
			if parts and parts[0] != "optimizer"
		]


def matrix(rows):
	x_values = sorted({row[1] for row in rows})
	y_values = sorted({row[2] for row in rows})
	values = np.full((len(x_values), len(y_values)), np.nan)
	for x_index, x_value in enumerate(x_values):
		for y_index, y_value in enumerate(y_values):
			samples = [
				row[4] for row in rows
				if row[1] == x_value and row[2] == y_value
			]
			values[x_index, y_index] = np.mean(samples)
	return values, x_values, y_values


def draw_matrix(axis, values, x_values, y_values, title, xlabel, ylabel,
				cmap, normalization):
	def format_tick(value):
		return f"{value:g}" if isinstance(value, (int, float)) else str(value)

	image = axis.imshow(
		values,
		cmap=cmap,
		norm=normalization,
		aspect="auto",
	)
	axis.set_title(title)
	axis.set_xticks(range(len(y_values)), [format_tick(v) for v in y_values])
	axis.set_yticks(range(len(x_values)), [format_tick(v) for v in x_values])
	axis.set_xlabel(xlabel)
	axis.set_ylabel(ylabel)
	for row in range(values.shape[0]):
		for column in range(values.shape[1]):
			normalized_value = normalization(values[row, column])
			text_color = "white" if normalized_value < 0.35 else "black"
			axis.text(
				column,
				row,
				f"{values[row, column]:.0f}",
				ha="center",
				va="center",
				color=text_color,
			)
	return image


results = load_results()
optimizer1_rows = [row for row in results if row[0] == "optimizer1"]
optimizer2_values = [row[4] for row in results if row[0] == "optimizer2"]
optimizer3_rows = [row for row in results if row[0] == "optimizer3"]

optimizer1_values, optimizer1_x, optimizer1_y = matrix(optimizer1_rows)
optimizer3_values, optimizer3_x, optimizer3_y = matrix(optimizer3_rows)
optimizer2_values_matrix = np.array(optimizer2_values).reshape(3, 3)

all_values = np.concatenate([
	optimizer1_values.ravel(),
	optimizer2_values_matrix.ravel(),
	optimizer3_values.ravel(),
])
normalization = Normalize(vmin=np.min(all_values), vmax=np.max(all_values))
cmap = LinearSegmentedColormap.from_list(
	"traffic_lights",
	["#16803c", "#ffe600", "#d62828"],
)

fig, axes = plt.subplots(1, 3, figsize=(15, 5), constrained_layout=True)
images = [
	draw_matrix(
		axes[0], optimizer1_values, optimizer1_x, optimizer1_y,
		"optimizer1", "Pm", "Pc", cmap, normalization,
	),
	draw_matrix(
		axes[1], optimizer2_values_matrix, ["1", "2", "3"], ["1", "2", "3"],
		"optimizer2", "przebieg", "przebieg",
		cmap, normalization,
	),
	draw_matrix(
		axes[2], optimizer3_values, optimizer3_x, optimizer3_y,
		"optimizer3", "evaporation", "ants", cmap, normalization,
	),
]
fig.colorbar(images[0], ax=axes, shrink=0.8, label="fitness")

plt.savefig("heatmap.png", dpi=150, bbox_inches="tight")
print("Zapisano heatmap.png")
