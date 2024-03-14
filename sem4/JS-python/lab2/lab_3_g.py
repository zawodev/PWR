import data_processing_functions as dpf
from datetime import datetime

def is_send_on_friday(log_entry: dpf.LogEntry):
    try:
        date = datetime.strptime(log_entry.date, "%d/%b/%Y:%H:%M:%S %z")
        if date.weekday() == 4:
            print(log_entry.original_log)
    except ValueError:
        pass

if __name__ == "__main__":
    dpf.exec_func_on_all_lines(is_send_on_friday)
