from functools import lru_cache

# ===================================================== generators =====================================================

def make_generator(f):
    def generator():
        n = 1
        while True:
            yield f(n)
            n += 1

    return generator

def make_generator_mem(f):
    @lru_cache(maxsize=None)
    def cached_f(n):
        return f(n)

    def generator():
        n = 1
        while True:
            yield cached_f(n)
            n += 1

    return generator

# ====================================================== funcs =========================================================

@lru_cache(maxsize=None) # memoization of recursive function
def fibonacci(n):
    if n <= 0:
        return 0
    elif n == 1:
        return 1
    else:
        return fibonacci(n - 1) + fibonacci(n - 2)

def natural_numbers(n):
    return n

arithmetic_sequence = lambda n, a=5, d=3: a + (n - 1) * d
geometric_sequence = lambda n, a=4, r=2: a * (r ** (n - 1))

# ====================================================== print =========================================================

def print_first_10_elements(title_str, generator):
    print(title_str)
    for _ in range(10):
        print(next(generator), end=' ')
    print()
