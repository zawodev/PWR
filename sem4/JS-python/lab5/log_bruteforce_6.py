import datetime


def detect_brute_force_attempts(log_file, interval=60, attempts=5, user_detect=False):
    from collections import defaultdict

    if user_detect:
        print("Detecting brute force attempts for many usernames: ")

    attack_attempts = defaultdict(list)
    detected_attacks = []

    for log_line in log_file:
        if log_line['msg_type'] != 'failed password for':
            continue

        ip = log_line['ipv4s'][0] if len(log_line['ipv4s']) > 0 else None
        timestamp = datetime.datetime.strptime(log_line['timestamp'], "%b %d %H:%M:%S")
        failure = log_line['msg_type'] == 'failed password for'
        username = log_line.get('username', None)

        if user_detect and username:
            key = (ip, username)
        else:
            key = ip

        if failure:
            #if attack_attempts[key]:
                #print(len(attack_attempts[key]))
                #print("=", end=" ")
                #print((timestamp - attack_attempts[key][-1][0]).total_seconds())

            if attack_attempts[key] and (attack_attempts[key][0][0] - attack_attempts[key][-1][0]).total_seconds() > interval:
                attack_attempts[key].clear()

            attack_attempts[key].append((timestamp, ip))

            if len(attack_attempts[key]) >= attempts:
                first_attempt = attack_attempts[key][0][0]
                last_attempt = attack_attempts[key][-1][0]
                #print("-", end=" ")
                #print((last_attempt - first_attempt).total_seconds())
                if (last_attempt - first_attempt).total_seconds() <= interval:
                    detected_attacks.append({
                        'timestamp': last_attempt.strftime('%Y-%m-%d %H:%M:%S'),
                        'ip': ip,
                        'attempts': len(attack_attempts[key])
                    })
                    attack_attempts[key].clear()

    return detected_attacks


def print_brute_force_attempts(log_file, interval=60, attempts=5, user_detect=False):
    attacks = detect_brute_force_attempts(log_file, interval, attempts, user_detect)
    for attack in attacks:
        print(f"Detected brute force attack from {attack['ip']} at {attack['timestamp']} with {attack['attempts']} attempts")
