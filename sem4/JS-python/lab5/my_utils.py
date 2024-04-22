import re


def get_ipv4s_from_log(log): # 2b
    ipv4_pattern = r'\b(?:\d{1,3}\.){3}\d{1,3}\b'
    return re.findall(ipv4_pattern, log['event'])


def get_user_from_log(log_event: str): # 2c
    user_patterns = [
        r'user\s+(\S+)',
        r'user=(\S+)'
    ]
    for pattern in user_patterns:
        match = re.search(pattern, log_event)
        if match:
            return match.group(1)
    return None


def get_message_type(log_event: str): # 2d
    log_event = log_event.lower()
    phrases = ["accepted password for",
               "failed password for",
               "connection closed by",
               "invalid user",
               "authentication failure",
               "possible break-in attempt"]
    for phrase in phrases:
        if phrase in log_event:
            return phrase
    return "other"
