from datetime import timedelta

def time_to_seconds(t: str) -> int:
    h, m, s = map(int, t.split(':'))
    extra = 0
    if h >= 24:
        h -= 24
        extra = 86400
    return h * 3600 + m * 60 + s + extra

def seconds_to_time(s: int) -> str:
    s = s % 86400
    return str(timedelta(seconds=s))
