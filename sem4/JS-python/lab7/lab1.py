from functools import reduce

def acronym(phrases):
    return ''.join(map(lambda word: word[0].upper(), phrases))

def median(numbers):
    sorted_numbers = sorted(numbers)
    length = len(sorted_numbers)
    return (sorted_numbers[(length - 1) // 2] + sorted_numbers[length // 2]) / 2

def sqrt(x, epsilon=0.1):
    next_guess = lambda guess: (guess + x / guess) / 2
    good_enough = lambda guess: abs(guess**2 - x) < epsilon
    improve = lambda guess: next_guess(guess) if not good_enough(guess) else guess
    recursive_solve = lambda guess: improve(recursive_solve(next_guess(guess)) if not good_enough(guess) else guess)
    return recursive_solve(x / 2)

def make_alpha_dict(input_str):
    words = input_str.split()
    chars = sorted(set(''.join(words)))
    result_dict = dict(map(lambda char: (char, list(filter(lambda word: char in word, words))), chars))
    return result_dict

def flatten(lst):
    is_scalar = lambda item: not isinstance(item, (list, tuple))
    reduce_list = lambda acc, x: acc + (flatten(x) if not is_scalar(x) else [x])
    return reduce(reduce_list, lst, [])

if __name__ == '__main__':
    print(acronym(['Zakład', 'Ubezpieczeń', 'Społecznych']))
    print(median([1, 1, 19, 2, 3, 4, 4, 5, 1]))
    print(sqrt(3, epsilon=0.1))
    print(make_alpha_dict('on i ona'))
    print(flatten([1, [2, 3], [[4, 5], 6]]))
