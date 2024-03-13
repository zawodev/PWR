import data_processing_functions as dpf


def func(log_entry: dpf.LogEntry):
    global bytes_sum
    try:
        bytes_sum += int(log_entry.bytes_sent)
    except ValueError:
        print(log_entry.og_log)


if __name__ == "__main__":
    bytes_sum = 0
    dpf.exec_func_on_all_lines(func)
    print(f"{round(bytes_sum / (1024 * 1024), 2)} GB")
