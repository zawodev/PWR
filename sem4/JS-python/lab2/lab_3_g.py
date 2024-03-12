import data_processing_functions as dpf
from datetime import datetime


def func(log_entry: dpf.LogEntry):
    date = datetime.strptime(log_entry.date, "%d/%b/%Y:%H:%M:%S %z")
    if date.weekday() == 4:
        print(log_entry.og_log)


if __name__ == "__main__":
    dpf.exec_func_on_all_lines(func)

