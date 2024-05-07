import re
from ipaddress import IPv4Address

class SSHLogEntry:
    LOG_PATTERN = r'^(?P<timestamp>\w{3}\s+\d+\s+\d+:\d+:\d+)\s+(?P<hostname>\S+)\s+sshd\[(?P<pid>\d+)\]:\s+(?P<event>.+)$'
    IPV4_PATTERN = r'\b(?:\d{1,3}\.){3}\d{1,3}\b'
    USER_PATTERNS = [r'user\s+(\S+)', r'user=(\S+)']
    PHRASES = ["accepted password for", "failed password for", "connection closed by", "invalid user", "authentication failure", "possible break-in attempt"]

    def __init__(self, line: str):
        self.line = line.strip()
        self.timestamp = None
        self.hostname = None
        self.pid = None
        self.event = None
        self.ipv4s = None
        self.username = None
        self.msg_type = None
        self.parse_line()

    def parse_line(self):
        match = re.match(self.LOG_PATTERN, self.line)
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
        return f"SSHLogEntry(timestamp={self.timestamp}, hostname={self.hostname}, pid={self.pid}, event={self.event[:30]}...)"  # skrót treści dla lepszej czytelności

    def get_ipv4(self):
        return self.ipv4s[0] if self.ipv4s else None







class RejectedPasswordEntry(SSHLogEntry):
    def __init__(self, line: str):
        super().__init__(line)
        if self.msg_type != "failed password for":
            raise ValueError("This entry does not represent a password rejection.")

    def __str__(self):
        return f"RejectedPasswordEntry(User: {self.username}, Host: {self.hostname}, Time: {self.timestamp})"

class AcceptedPasswordEntry(SSHLogEntry):
    def __init__(self, line: str):
        super().__init__(line)
        if self.msg_type != "accepted password for":
            raise ValueError("This entry does not represent a password acceptance.")

    def __str__(self):
        return f"AcceptedPasswordEntry(User: {self.username}, Host: {self.hostname}, Time: {self.timestamp})"

class ErrorLogEntry(SSHLogEntry):
    def __init__(self, line: str):
        super().__init__(line)
        if self.msg_type not in ["invalid user", "authentication failure", "possible break-in attempt"]:
            raise ValueError("This entry does not represent an error.")

    def __str__(self):
        return f"ErrorLogEntry(Type: {self.msg_type}, Host: {self.hostname}, Time: {self.timestamp})"

class OtherLogEntry(SSHLogEntry):
    def __init__(self, line: str):
        super().__init__(line)
        if self.msg_type == "other":
            self.detail = self.event  # Można tutaj wprowadzić dodatkowe przetwarzanie specyficzne dla kategorii 'other'
        else:
            raise ValueError("This entry is not classified as 'other'.")

    def __str__(self):
        return f"OtherLogEntry(Detail: {self.detail[:50]}, Time: {self.timestamp})"
