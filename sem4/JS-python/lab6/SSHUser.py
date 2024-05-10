import re

class SSHUser:
    def __init__(self, username, last_login_date):
        self.username = username
        self.last_login_date = last_login_date

    def validate(self):
        return bool(re.match(r'^[a-z_][a-z0-9_-]{0,31}$', self.username))
