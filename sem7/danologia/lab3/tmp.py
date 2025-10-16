from sklearn.linear_model import LinearRegression
import pandas as pd
import numpy as np
import csv
import matplotlib.pyplot as plt

data = pd.read_excel('pomiary2017.xlsx')
data = data.to_numpy()

wzrosty = data[:, 5]

def bootstrap(data, iter_num, sample_size):
    output = []
    for i in range(iter_num):
        sample = np.random.choice(data, size=sample_size, replace=True)
        stat = np.mean(sample)
        output.append(stat)
    return output

output = bootstrap(wzrosty, 10, len(wzrosty))

# get variance from output
variance

print()
