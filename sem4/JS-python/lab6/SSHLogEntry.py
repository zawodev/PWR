import re
from abc import ABC, abstractmethod
from ipaddress import IPv4Address

class SSHLogEntry(ABC):
    LOG_PATTERN = r'^(?P<timestamp>\w{3}\s+\d+\s+\d+:\d+:\d+)\s+(?P<hostname>\S+)\s+sshd\[(?P<pid>\d+)\]:\s+(?P<event>.+)$'
    IPV4_PATTERN = r'\b(?:\d{1,3}\.){3}\d{1,3}\b'
    USER_PATTERNS = [r'user\s+(\S+)', r'user=(\S+)']

    def __init__(self, line: str):
        self._raw_line = line.strip() # '_' means protected attribute
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
        if "accepted password for" in event:
            return "password accepted"
        elif "failed password for" in event:
            return "password failed"

        for phrase in ["did not receive identification", "invalid user", "authentication failure", "fatal", "error"]:
            if phrase in event:
                return "error"
        return "other"

    def __str__(self):
        return f"SSHLogEntry(timestamp={self.timestamp}, username={self.username}, pid={self.pid}, event={self.event[:30]}...)"

class RejectedPasswordEntry(SSHLogEntry):
    def __init__(self, line: str):
        super().__init__(line)

    def validate(self):
        return self.msg_type == "password failed"

    def __str__(self):
        return f"RejectedPasswordEntry(username: {self.username}, timestamp: {self.timestamp})"

class AcceptedPasswordEntry(SSHLogEntry):
    def __init__(self, line: str):
        super().__init__(line)

    def validate(self):
        return self.msg_type == "password accepted"

    def __str__(self):
        return f"AcceptedPasswordEntry(username: {self.username}, timestamp: {self.timestamp})"

class ErrorLogEntry(SSHLogEntry):
    def __init__(self, line: str):
        super().__init__(line)

    def validate(self):
        return self.msg_type == "error"

    def __str__(self):
        return f"ErrorLogEntry(username: {self.username}, message type: {self.msg_type}, timestamp: {self.timestamp})"

class OtherLogEntry(SSHLogEntry):
    def __init__(self, line: str):
        super().__init__(line)

    def validate(self):
        return True

    def __str__(self):
        return f"OtherLogEntry(username: {self.username}, timestamp: {self.timestamp})"
