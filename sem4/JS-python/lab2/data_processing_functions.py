from collections import namedtuple
import sys

LogEntry = namedtuple("LogEntry",
                      ["og_log", "host", "host_domain", "date", "http_method", "path", "file_name_with_extension",
                       "file_name", "file_extension", "http_protocol", "response_code", "bytes_sent"])


def exec_func_on_all_lines(func, **kwargs):
    for line in sys.stdin:
        log_entry = parse_line(line)
        func(log_entry, **kwargs)


def parse_line(line):  # 199.72.81.55 - - [01/Jul/1995:00:00:01 -0400] "GET /history/apollo/ HTTP/1.0" 200 6245
    try:
        parts = line.split()
        cmd = line[line.find('"') + 1:line.rfind('"')]
        return LogEntry(
            og_log=line,
            host=parts[0],
            host_domain=parts[0].split(".")[-1] if "." in parts[0] else "",
            date=(parts[3] + " " + parts[4])[1:-1],

            http_method=parts[5][1:],
            path="".join(cmd.split(" ")[1:-1]),
            file_name=cmd.split("/")[-1].split(".")[0],
            file_extension=cmd.split("/")[-1].split(".")[1],

            response_code=parts[-2],
            bytes_sent=parts[-1]
        )
    except IndexError:
        return LogEntry(
            og_log=line,
            host="",
            host_domain="",
            date="",
            http_method="",
            path="",
            file_name_with_extension="",
            file_name="",
            file_extension="",
            http_protocol="",
            response_code="",
            bytes_sent=""
        )

