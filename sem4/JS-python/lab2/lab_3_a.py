import data_processing_functions as dpf

counter = 0

def count_requests(log_entry: dpf.LogEntry, code: str):
    global counter
    if log_entry.response_code == code:
        counter += 1

def print_request_count(code: str):
    global counter
    dpf.exec_func_on_all_lines(count_requests, code=code)
    print(counter)
