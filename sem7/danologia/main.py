# PEP8
# gość mówi "rozumią" zamiast "rozumieją"
# umią zamiast umieją
# compare times:

# start time counting:
import time
start_time = time.time()

# 1.
for p in range(100_000_000):
    p**2

end_time = time.time()
print("Execution time:", end_time - start_time)

# 2.

start_time = time.time()

[p**2 for p in range(100_000_000)]

end_time = time.time()

print("Execution time:", end_time - start_time)

# collections->Counter usage
from collections import Counter
a = [1, 2, 3, 4, 5, 1, 2, 3, 4, 5, 1, 2, 3, 4, 5]
Counter(a)
# Counter({'1': 3, '2': 3, '3': 3, '4': 3, '5': 3})
Counter(a).most_common(2)
# [(1, 3), (2, 3)]
Counter(a).most_common(1)
# [(1, 3)]
Counter(a).most_common()[-1]
# (5, 3)

L = [10, 10, 10, 11]
L.sort(reverse=True)

sorted(key = lambda x : x[2])


# dict1 + dict2 => dict1.update(dict2)



# menager kontekstów
with open('file.txt', 'r') as file:
    file.readline()

[line.upper() for line in open('file.txt', 'r')]



class Zesp:
    def __init__(self, re, ur):
        self.re = re
        self.ur = ur
    def add(self, stata):
        pass





