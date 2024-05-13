import logging
import functools
import time

def log(level=logging.DEBUG):
    logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s', level=level)

    def decorator(func_or_class):
        if isinstance(func_or_class, type): # decorating a class
            return log_class_creation(func_or_class)
        else: # decorating a function
            return log_function_call(func_or_class)

    def log_class_creation(cls):
        class_name = cls.__name__

        @functools.wraps(cls)
        def wrapped(*args, **kwargs):
            logging.log(level, f"Creating instance of {class_name}")
            instance = cls(*args, **kwargs)
            return instance

        return wrapped

    def log_function_call(func):
        @functools.wraps(func)
        def wrapped(*args, **kwargs):
            start_time = time.time()
            result = func(*args, **kwargs)
            end_time = time.time()

            arg_str = ', '.join([repr(a) for a in args] + [f"{k}={repr(v)}" for k, v in kwargs.items()])
            return_value_str = repr(result)

            logging.log(
                level,
                f"Function '{func.__name__}' called with args: {arg_str}. "
                f"Returned: {return_value_str}. "
                f"Execution time: {end_time - start_time:.4f} seconds."
            )

            return result

        return wrapped

    return decorator

# ===================================================== testing  =======================================================

if __name__ == "__main__":
    @log(level=logging.INFO)
    def example_function(x, y):
        return x + y

    _result = example_function(3, 5)

    @log(level=logging.INFO)
    class MyClass:
        def __init__(self, name):
            self.name = name

    _obj = MyClass("example")
