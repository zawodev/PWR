from collections import namedtuple
from datetime import datetime
import sys


LogEntry = namedtuple("LogEntry", [
    "original_log", # 199.72.81.55 - - [01/Jul/1995:00:01:43 -0400] "GET /img/temp.gif HTTP/1.0" 200 7074
    "host_addr", # 199.72.81.55
    "host_domain", # 55
    "date", # 1995-07-01 00:01:43-04:00
    "path", # /img/temp.gif
    "file_extension", # gif
    "response_code", # 200
    "bytes_sent" # 7074
])


def read_log():
    log = []
    for line in sys.stdin:
        if line not in ["\n", ""]:
            try:
                parts = line.split(" ")  # split by space
                cmd = line[line.find('"') + 1:line.rfind('"')]  # command within quotes ""
                path = "".join(cmd.split(" ")[1:-1])  # path without GET/POST and HTTP/1.0/1.1
                fwe = path.split("/")[-1]  # file with extension
                log.append(LogEntry(
                    original_log=line,
                    host_addr=parts[0],
                    host_domain=parts[0].split(".")[-1] if "." in parts[0] else "",

                    date=datetime.strptime((parts[3] + " " + parts[4])[1:-1], "%d/%b/%Y:%H:%M:%S %z"),
                    path=path,
                    file_extension=fwe.split(".")[1] if "." in fwe else "",

                    response_code=int(parts[-2]),
                    bytes_sent=int(parts[-1])
                ))
            except IndexError:
                print(f"Line parsing Error! look in: {line}")
                sys.exit(1)
    return log


def sort_log(log, key):
    try:
        sorted_log = sorted(log, key=lambda x: x[key])
        return sorted_log
    except IndexError:
        print("Podany klucz przekracza rozmiar krotki.")
        return None


def get_entries_by_addr(log, addr):
    filtered_entries = [entry for entry in log if entry.host_addr == addr and 100 <= entry.response_code < 600]
    return filtered_entries


def get_entries_by_code(log, code):
    filtered_entries = [entry for entry in log if entry.response_code == code and 100 <= entry.response_code < 600]
    return filtered_entries

def get_failed_reads(log, merge=False):
    codes_4xx = []
    codes_5xx = []

    for entry in log:
        if 400 <= entry.response_code < 500:
            codes_4xx.append(entry)
        elif 500 <= entry.response_code < 600:
            codes_5xx.append(entry)

    if merge:
        return codes_4xx + codes_5xx
    else:
        return codes_4xx, codes_5xx

def get_entries_by_extension():
    pass

def entry_to_dict():
    pass

def log_to_dict():
    pass

def get_addrs():
    pass

def print_dict_entry_dates():
    pass

def test():
    # zad 1
    _log = read_log()

    # zad 2
    _addr_to_search = "199.120.110.21"
    for _entry in get_entries_by_addr(_log, _addr_to_search):
        print(_entry.original_log, end="")

    # zad 3
    _key = 3
    for _entry in sort_log(_log, _key):
        print(_entry[_key])

    # zad 4
    _code_to_search = 304
    for _entry in get_entries_by_code(_log, _code_to_search):
        print(_entry.original_log, end="")

    # zad 5
    codes_4xx, codes_5xx = get_failed_reads(_log)
    print("--- 4xx codes: ---")
    for _entry in codes_4xx:
        print(_entry.original_log, end="")
    print("--- 5xx codes: ---")
    for _entry in codes_5xx:
        print(_entry.original_log, end="")

    merged_list = get_failed_reads(_log, merge=True)
    print("--- merged list: ---")
    for entry in merged_list:
        print(entry.original_log, end="")

if __name__ == "__main__":
    test()
