from datetime import timedelta

def time_to_seconds(t: str) -> int:
    h, m, s = map(int, t.split(':'))
    return h * 3600 + m * 60 + s

def seconds_to_time(s: int) -> str:
    return str(timedelta(seconds=s))
