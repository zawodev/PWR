from collections import namedtuple
import sys


LogEntry = namedtuple("LogEntry", [
    "original_log", # 199.72.81.55 - - [01/Jul/1995:00:01:43 -0400] "GET /img/temp.gif HTTP/1.0" 200 7074
    "host_domain", # 55
    "date", # 1995-07-01 00:01:43-04:00
    "path", # /img/temp.gif
    "file_extension", # gif
    "response_code", # 200
    "bytes_sent" # 7074
])


def parse_line(line):
    try:
        parts = line.split(" ") # split by space
        cmd = line[line.find('"') + 1:line.rfind('"')] # command within quotes ""
        path = "".join(cmd.split(" ")[1:-1]) # path without GET/POST and HTTP/1.0/1.1
        fwe = path.split("/")[-1] # file with extension
        return LogEntry(
            original_log=line,
            host_domain=parts[0].split(".")[-1] if "." in parts[0] else "",
            date=(parts[3] + " " + parts[4])[1:-1],

            path=path,
            file_extension=fwe.split(".")[1] if "." in fwe else "",

            response_code=parts[-2],
            bytes_sent=parts[-1]
        )
    except IndexError:
        print(f"Line parsing Error! look in: {line}")
        sys.exit(1)


def exec_func_on_all_lines(func, **kwargs):
    for line in sys.stdin:
        if line not in ["\n", ""]:
            log_entry = parse_line(line)
            func(log_entry, **kwargs)
