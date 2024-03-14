import data_processing_functions as dpf

def is_send_from_poland(log_entry: dpf.LogEntry):
    if log_entry.host_domain == "pl":
        print(log_entry.original_log)

if __name__ == "__main__":
    dpf.exec_func_on_all_lines(is_send_from_poland)
