def forall(pred, iterable):
    return all(pred(item) for item in iterable)

def exists(pred, iterable):
    return any(pred(item) for item in iterable)

def atleast(n, pred, iterable):
    count = sum(1 for item in iterable if pred(item))
    return count >= n

def atmost(n, pred, iterable):
    count = sum(1 for item in iterable if pred(item))
    return count <= n

if __name__ == "__main__":
    numbers = [1, 2, 3, 4, 5]
    print(forall(lambda x: x > 0, numbers))  # True
    print(forall(lambda x: x > 3, numbers))  # False
    print(exists(lambda x: x % 2 == 0, numbers))  # True
    print(exists(lambda x: x > 5, numbers))  # False
    print(atleast(3, lambda x: x > 2, numbers))  # True
    print(atleast(3, lambda x: x > 3, numbers))  # False
    print(atmost(2, lambda x: x > 3, numbers))  # True
    print(atmost(2, lambda x: x > 1, numbers))  # False
