from collections import namedtuple
import sys

LogEntry = namedtuple("LogEntry", [
    "original_log",
    "host_domain",
    "date",
    "path",
    "file_extension",
    "response_code",
    "bytes_sent"
])

def exec_func_on_all_lines(func, **kwargs):
    for line in sys.stdin:
        if line not in ["\n", ""]:
            log_entry = parse_line(line)
            func(log_entry, **kwargs)

def parse_line(line):  # 199.72.81.55 - - [01/Jul/1995:00:00:01 -0400] "GET /history/apollo/ HTTP/1.0" 200 6245
    try:
        parts = line.split(" ")
        cmd = line[line.find('"') + 1:line.rfind('"')]
        path = "".join(cmd.split(" ")[1:-1])
        fwe = path.split("/")[-1]
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
