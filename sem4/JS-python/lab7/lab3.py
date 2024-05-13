import random
import string

class PasswordGenerator:
    def __init__(self, length, charset=None, count=None):
        self.length = length
        self.charset = charset or (string.ascii_letters + string.digits)
        self.count = count
        self.generated_count = 0

    def __iter__(self):
        return self

    def __next__(self):
        if self.count is not None and self.generated_count >= self.count:
            raise StopIteration

        password = ''.join(random.choice(self.charset) for _ in range(self.length))
        self.generated_count += 1

        return password

if __name__ == "__main__":
    _password_gen = PasswordGenerator(length=24, count=8)

    print(next(_password_gen))
    print(next(_password_gen))

    for _password in _password_gen:
        print(_password)
