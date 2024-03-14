import data_processing_functions as dpf

def sum_all_bytes(log_entry: dpf.LogEntry):
    global bytes_sum
    if log_entry.bytes_sent not in ("-", ""):
        try:
            bytes_sum += int(log_entry.bytes_sent)
        except ValueError:
            pass

if __name__ == "__main__":
    bytes_sum = 0
    dpf.exec_func_on_all_lines(sum_all_bytes)
    print(f"{round(bytes_sum / 1073741824, 2)} GB")
