from SSHJournal import SSHLogJournal
from SSHUser import SSHUser

def test_functionalities():
    # ex 5 test
    print("\n--- Test 5: Has Ip? ---")
    print(f"{journal[1].has_ip}; {journal[1].event}")
    print(f"{journal[3].has_ip}; {journal[3].event}")

    # ex 6 test
    print("\n--- Test 6: less then, greater then, equal ---")
    print(f"0: {journal[0].timestamp}\n1: {journal[1].timestamp}\n8: {journal[8].timestamp}")
    print(f"[1]<[8] -> {journal[1] < journal[8]}")
    print(f"[1]>[8] -> {journal[1] > journal[8]}")
    print(f"[1]==[0] -> {journal[1] == journal[0]}")
    print(f"[1]==[8] -> {journal[1] == journal[8]}")

    # ex 7 test
    print("\n--- Test 7: get logs by criteria, iter through journal ---")
    for log in journal.get_logs_by_criteria(lambda x: not x.has_ip):
        print(log)

    # ex 7a test
    print("\n--- Test 7a: get item ---")
    print(journal[0:4:2])

def test_duck_typing():
    print("\n--- Test 8: duck typing ---")
    for obj in mixed_objects:
        print(obj.validate(), end="; ")
        print(obj)

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

    # TESTING
    test_functionalities()
    test_duck_typing()
