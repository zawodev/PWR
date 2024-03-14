import data_processing_functions as dpf

def find_biggest_file(log_entry: dpf.LogEntry):
    global biggest_file
    if log_entry.bytes_sent not in ("-", ""):
        try:
            if int(log_entry.bytes_sent) > biggest_file[1]:
                biggest_file = [log_entry.path, int(log_entry.bytes_sent)]
        except ValueError:
            pass


if __name__ == "__main__":
    biggest_file = ["", 0]
    dpf.exec_func_on_all_lines(find_biggest_file)
    print(f"{biggest_file[0]} {round(biggest_file[1] / 1024, 2)} KB")
