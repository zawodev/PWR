import data_processing_functions as dpf

def is_response_code_200(log_entry: dpf.LogEntry):
    if log_entry.response_code == "200":
        print(log_entry.original_log)

if __name__ == "__main__":
    dpf.exec_func_on_all_lines(is_response_code_200)
