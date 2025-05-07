import time

def timing(func):
    """Decorator to measure execution time and node count."""
    def wrapper(*args, **kwargs):
        start = time.time()
        result, stats = func(*args, **kwargs)
        elapsed = time.time() - start
        stats['time'] = elapsed
        return result, stats
    return wrapper

def notation_to_index(move: str, rows: int, cols: int):
    """Convert 'e2e3' to board indices ((r1,c1),(r2,c2))."""
    col_map = {chr(ord('a')+i): i for i in range(cols)}
    c1 = col_map[move[0]]
    r1 = rows - int(move[1])
    c2 = col_map[move[2]]
    r2 = rows - int(move[3])
    return (r1, c1), (r2, c2)
