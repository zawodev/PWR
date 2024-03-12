import data_processing_functions as dpf


def func(log_entry: dpf.LogEntry):
    global counter
    if log_entry.file_extension in ("gif", "png", "jpg", "jpeg", "xbm"):
        counter[0] += 1
    counter[1] += 1


if __name__ == "__main__":
    counter = [0, 0]
    dpf.exec_func_on_all_lines(func)
    print(f"{counter[0] / counter[1] * 100.0}%")
