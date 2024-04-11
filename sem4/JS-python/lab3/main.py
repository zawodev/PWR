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
                    bytes_sent=int(parts[-1]) if parts[-1].isdigit() else 0
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
    entry: LogEntry
    filtered_entries = [entry for entry in log if entry.host_addr == addr and 100 <= entry.response_code < 600]
    return filtered_entries


def get_entries_by_code(log, code):
    entry: LogEntry
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


def get_entries_by_extension(log, extension):
    entry: LogEntry
    filtered_entries = [entry for entry in log if entry.file_extension == extension]
    return filtered_entries


def print_entries(entries):
    for entry in entries:
        print(entry.original_log, end="")


def entry_to_dict(entry: LogEntry):
    return {
        "original_log": entry.original_log,
        "host_addr": entry.host_addr,
        "host_domain": entry.host_domain,
        "date": entry.date,
        "path": entry.path,
        "file_extension": entry.file_extension,
        "response_code": entry.response_code,
        "bytes_sent": entry.bytes_sent
    }


def log_to_dict(log): # dict, w którym kluczem jest host_addr, a wartości to lista słowników z danymi
    log_dict = {}
    for entry in log:
        if entry.host_addr in log_dict:
            log_dict[entry.host_addr].append(entry_to_dict(entry))
        else:
            log_dict[entry.host_addr] = [entry_to_dict(entry)]
    return log_dict


def get_addrs(log_dict):
    return log_dict.keys()


def print_dict_entry_dates(log_dict):
    for addr, entries in log_dict.items():
        print(f"--- {addr} ---")
        print(f"Number of requests: {len(entries)}")
        print(f"First request date: {entries[0]['date']}")
        print(f"Last request date: {entries[-1]['date']}")
        print(f"200 response code ratio: {len([entry for entry in entries if entry['response_code'] == 200]) / len(entries)}")


def test_all_func():
    # zad 1
    _log = read_log()
    print("--- Original log: ---")
    print_entries(_log)

    # zad 2
    _addr_to_search = "199.120.110.21"
    print(f"\n--- Entries for addr: {_addr_to_search} ---")
    print_entries(get_entries_by_addr(_log, _addr_to_search))

    # zad 3
    _key = 3
    print(f"\n--- Sorted log by: {LogEntry._fields[_key]} ---")
    print_entries(sort_log(_log, _key))

    # zad 4
    _code_to_search = 304
    print(f"\n--- Entries for code: {_code_to_search} ---")
    print_entries(get_entries_by_code(_log, _code_to_search))

    # zad 5
    codes_4xx, codes_5xx = get_failed_reads(_log)
    print("\n--- 4xx codes: ---")
    print_entries(codes_4xx)

    print("--- 5xx codes: ---")
    print_entries(codes_5xx)

    merged_list = get_failed_reads(_log, merge=True)
    print("--- Merged list: ---")
    print_entries(merged_list)

    # zad 6
    _extension_to_search = "gif"
    print(f"\n--- Entries for extension: {_extension_to_search} ---")
    print_entries(get_entries_by_extension(_log, _extension_to_search))

    # zad 7
    _log_dict = log_to_dict(_log)
    print("\n--- Log dict: ---")
    print(get_addrs(_log_dict))

    # zad 8
    print("\n--- Entries dates: ---")
    print_dict_entry_dates(_log_dict)

def test_last_func():
    _log_dict = log_to_dict(get_entries_by_addr(read_log(), "199.120.110.21"))
    print("--- Entries dates: ---")
    print_dict_entry_dates(_log_dict)


if __name__ == "__main__":
    test_all_func()
    # test_last_func()
