import data_processing_functions as dpf


def func(log_entry: dpf.LogEntry):
    global biggest_file
    if log_entry.bytes_sent != "-" and int(log_entry.bytes_sent) > biggest_file[1]:
        biggest_file = (log_entry.path, int(log_entry.bytes_sent))


if __name__ == "__main__":
    biggest_file = ("", 0)
    dpf.exec_func_on_all_lines(func)
    print(biggest_file)
