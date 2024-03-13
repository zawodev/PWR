import data_processing_functions as dpf


def func(log_entry: dpf.LogEntry):
    if log_entry.response_code == "200":
        print(log_entry.og_log)


if __name__ == "__main__":
    dpf.exec_func_on_all_lines(func)

