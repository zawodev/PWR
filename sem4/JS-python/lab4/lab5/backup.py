import sys
import os
import subprocess
from datetime import datetime
from utils import get_backup_dir, ensure_dir_exists, log_backup_entry

def create_backup(source_dir):
    backup_dir = get_backup_dir()
    ensure_dir_exists(backup_dir)
    timestamp = datetime.now().strftime('%Y%m%d-%H%M%S')
    dirname = os.path.basename(os.path.normpath(source_dir))
    archive_name = f"{timestamp}-{dirname}.zip"
    archive_path = os.path.join(backup_dir, archive_name)

    subprocess.run(['powershell.exe', 'Compress-Archive', '-Path', source_dir, '-DestinationPath', archive_path], check=True)

    log_backup_entry(backup_dir, source_dir, archive_name)

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Użycie: backup.py [ścieżka_do_katalogu]")
        sys.exit(1)

    _source_dir = sys.argv[1]
    create_backup(_source_dir)
