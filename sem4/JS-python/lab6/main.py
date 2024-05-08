import re
from ipaddress import IPv4Address
from abc import ABC, abstractmethod

class SSHLogEntry(ABC):
    LOG_PATTERN = r'^(?P<timestamp>\w{3}\s+\d+\s+\d+:\d+:\d+)\s+(?P<hostname>\S+)\s+sshd\[(?P<pid>\d+)\]:\s+(?P<event>.+)$'
    IPV4_PATTERN = r'\b(?:\d{1,3}\.){3}\d{1,3}\b'
    USER_PATTERNS = [r'user\s+(\S+)', r'user=(\S+)']
    PHRASES = ["accepted password for", "failed password for", "connection closed by", "invalid user", "authentication failure", "possible break-in attempt", "error"]

    def __init__(self, line: str):
        self._raw_line = line.strip()
        self.timestamp = None
        self.hostname = None
        self.pid = None
        self.event = None
        self.ipv4s = None
        self.username = None
        self.msg_type = None
        self.parse_line()

    def __repr__(self):
        return self.__str__()

    def __eq__(self, other):
        if isinstance(other, SSHLogEntry):
            return self.timestamp == other.timestamp
        return NotImplemented

    def __lt__(self, other):
        if isinstance(other, SSHLogEntry):
            return self.timestamp < other.timestamp
        return NotImplemented

    def __gt__(self, other):
        if isinstance(other, SSHLogEntry):
            return self.timestamp > other.timestamp
        return NotImplemented

    @abstractmethod
    def validate(self):
        """ Checks if the raw content of the entry is consistent with the extracted attributes."""
        pass

    @property
    def has_ip(self):
        """ Read-only property, returns True if the entry contains an IP address, otherwise False """
        return self.ipv4s is not None

    def get_ipv4(self):
        return self.ipv4s[0] if self.ipv4s else None

    def parse_line(self):
        match = re.match(self.LOG_PATTERN, self._raw_line)
        if match:
            log_dict = match.groupdict()
            self.timestamp = log_dict['timestamp']
            self.hostname = log_dict['hostname']
            self.pid = log_dict['pid']
            self.event = log_dict['event']
            self.ipv4s = self.get_ipv4s_from_event()
            self.username = self.get_user_from_event()
            self.msg_type = self.get_message_type()

    def get_ipv4s_from_event(self):
        matches = re.findall(self.IPV4_PATTERN, self.event)
        return [IPv4Address(ip) for ip in matches] if matches else None

    def get_user_from_event(self):
        for pattern in self.USER_PATTERNS:
            match = re.search(pattern, self.event)
            if match:
                return match.group(1)
        return None

    def get_message_type(self):
        event = self.event.lower()
        for phrase in self.PHRASES:
            if phrase in event:
                return phrase
        return "other"

    def __str__(self):
        return f"SSHLogEntry(timestamp={self.timestamp}, username={self.username}, pid={self.pid}, event={self.event[:30]}...)"









class RejectedPasswordEntry(SSHLogEntry):
    def __init__(self, line: str):
        super().__init__(line)

    def validate(self):
        return self.msg_type == "failed password for"

    def __str__(self):
        return f"RejectedPasswordEntry(username: {self.username}, timestamp: {self.timestamp})"

class AcceptedPasswordEntry(SSHLogEntry):
    def __init__(self, line: str):
        super().__init__(line)

    def validate(self):
        return self.msg_type == "accepted password for"

    def __str__(self):
        return f"AcceptedPasswordEntry(username: {self.username}, timestamp: {self.timestamp})"

class ErrorLogEntry(SSHLogEntry):
    def __init__(self, line: str):
        super().__init__(line)

    def validate(self):
        return self.msg_type in ["invalid user", "authentication failure", "error"]

    def __str__(self):
        return f"ErrorLogEntry(username: {self.username}, message type: {self.msg_type}, timestamp: {self.timestamp})"

class OtherLogEntry(SSHLogEntry):
    def __init__(self, line: str):
        super().__init__(line)

    def validate(self):
        return True

    def __str__(self):
        return f"OtherLogEntry(username: {self.username}, timestamp: {self.timestamp})"




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
        line_lower = line.lower()
        if "accepted password for" in line_lower:
            new_entry = AcceptedPasswordEntry(line)
        elif "failed password for" in line_lower:
            new_entry = RejectedPasswordEntry(line)
        elif "error" in line_lower or "authentication failure" in line_lower or "invalid user" in line_lower:
            new_entry = ErrorLogEntry(line)
        else:
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
            return self.log_entries[key.start:key.stop:key.step]
        elif isinstance(key, str):
            filtered_logs = [entry for entry in self.log_entries if entry.has_ip and key in entry.ipv4s]
            return filtered_logs
        elif isinstance(key, int):
            return self.log_entries[key]
        else:
            raise TypeError("Unsupported key type")







class SSHUser:
    def __init__(self, username, last_login_date):
        self.username = username
        self.last_login_date = last_login_date

    def validate(self):
        if re.match(r'^[a-z_][a-z0-9_-]{0,31}$', self.username):
            return True
        else:
            return False



if __name__ == "__main__":

    journal = SSHLogJournal()
    with open("SSH2.log", 'r') as file:
        for _line in file:
            journal.append(_line)

    users = [
        SSHUser("user1", "2021-03-01"),
        SSHUser("user2", "2021-03-02"),
        SSHUser("0user", "2021-03-03"),
    ]

    mixed_objects = users + journal.log_entries

    for obj in mixed_objects:
        print(obj.validate(), end="; ")
        print(obj)
