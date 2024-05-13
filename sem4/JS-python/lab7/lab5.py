from generators import make_generator_mem, fibonacci, natural_numbers, arithmetic_sequence, geometric_sequence
from generators import print_first_10_elements

fibonacci_gen = make_generator_mem(fibonacci)
print_first_10_elements("Fibonacci sequence:", fibonacci_gen())

natural_numbers_gen = make_generator_mem(natural_numbers)
print_first_10_elements("Natural numbers sequence:", natural_numbers_gen())

arithmetic_gen = make_generator_mem(arithmetic_sequence)
print_first_10_elements("Arithmetic sequence:", arithmetic_gen())

geometric_gen = make_generator_mem(geometric_sequence)
print_first_10_elements("Geometric sequence:", geometric_gen())
