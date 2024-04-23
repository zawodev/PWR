import re


def parse_log_file(file):
    log_dicts = []
    for line in file:
        parsed_line = parse_log_line(line.strip())
        if parsed_line:
            log_dicts.append(parsed_line)
    return log_dicts


def parse_log_line(line: str):
    log_pattern = r'^(?P<timestamp>\w{3}\s+\d+\s+\d+:\d+:\d+)\s+(?P<hostname>\S+)\s+sshd\[(?P<pid>\d+)\]:\s+(?P<event>.+)$'
    match = re.match(log_pattern, line)
    if match:
        log_dict = match.groupdict()
        log_dict['ipv4s'] = get_ipv4s_from_log(log_dict)
        log_dict['username'] = get_user_from_log(log_dict['event'])
        log_dict['msg_type'] = get_message_type(log_dict['event'])
        log_dict['line'] = line
        return log_dict
    else:
        return None


def get_ipv4s_from_log(log): # 2b
    ipv4_pattern = r'\b(?:\d{1,3}\.){3}\d{1,3}\b'
    return re.findall(ipv4_pattern, log['event'])


def get_user_from_log(log_event: str): # 2c
    user_patterns = [
        r'user\s+(\S+)',
        r'user=(\S+)'
        # r'for\s+(\S+)'
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
