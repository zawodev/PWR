import data_processing_functions as dpf


counter = 0
# logs = []


def func(log_entry: dpf.LogEntry, code: str):
    global counter
    if log_entry.response_code == code:
        counter += 1
        # logs.append(log_entry.og_log)


def main(code: str):
    global counter
    dpf.exec_func_on_all_lines(func, code=code)
    print(counter)
    # for log in logs:
    # print(log)
