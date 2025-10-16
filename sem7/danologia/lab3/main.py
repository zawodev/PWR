from sklearn.linear_model import LinearRegression
import pandas as pd
import numpy as np
import csv
import matplotlib.pyplot as plt

data = pd.read_excel('pomiary2017.xlsx')
data = data.to_numpy()

with open('file.csv', encoding='utf-8') as file:
    reader = csv.reader(file, delimiter=';')
    data = list(reader)