from SSHLogEntry import RejectedPasswordEntry, AcceptedPasswordEntry, ErrorLogEntry, OtherLogEntry

class SSHLogJournal:
    def __init__(self):
        self.log_entries = []

    def __len__(self):
        return len(self.log_entries)

    def __iter__(self):
        return iter(self.log_entries)

    def __contains__(self, item):
        return item in self.log_entries

    def append(self, line: str):
        new_entry = AcceptedPasswordEntry(line)
        if not new_entry.validate():
            new_entry = RejectedPasswordEntry(line)
            if not new_entry.validate():
                new_entry = ErrorLogEntry(line)
                if not new_entry.validate():
                    new_entry = OtherLogEntry(line)

        if new_entry.validate():
            self.log_entries.append(new_entry)
        else:
            print(f"Invalid log entry: {line}, {new_entry}")

    def get_logs_by_criteria(self, criteria):
        filtered_logs = []
        for entry in self.log_entries:
            if criteria(entry):
                filtered_logs.append(entry)
        return filtered_logs

    def __getitem__(self, key):
        if isinstance(key, slice):
            return self.log_entries[key]
        elif isinstance(key, str):
            filtered_logs = [entry for entry in self.log_entries if entry.has_ip and key in entry.ipv4s]
            return filtered_logs
        elif isinstance(key, int):
            return self.log_entries[key]
        else:
            raise TypeError("Unsupported key type")
