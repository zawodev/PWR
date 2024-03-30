import subprocess
import os
import sys
import json

def process_directory(directory):
    stats = {
        "files": 0,
        "total_characters": 0,
        "total_words": 0,
        "total_lines": 0,
        "common_char": {},
        "common_word": {}
    }

    for root, dirs, files in os.walk(directory):
        for filename in files:
            filepath = os.path.join(root, filename)
            result = subprocess.run(["./a.out"], input=filepath, text=True, capture_output=True)
            if result.returncode == 0 and result.stdout:
                data = json.loads(result.stdout)
                stats["files"] += 1
                stats["total_characters"] += data["characters"]
                stats["total_words"] += data["words"]
                stats["total_lines"] += data["lines"]
                char = data["most_common_character"]
                word = data["most_common_word"]
                stats["common_char"][char] = stats["common_char"].get(char, 0) + 1
                stats["common_word"][word] = stats["common_word"].get(word, 0) + 1

    # Finding overall most common
    common_char = max(stats["common_char"], key=stats["common_char"].get, default="N/A")
    common_word = max(stats["common_word"], key=stats["common_word"].get, default="N/A")

    return {
        "read_files": stats["files"],
        "total_characters": stats["total_characters"],
        "total_words": stats["total_words"],
        "total_lines": stats["total_lines"],
        "most_common_character": common_char,
        "most_common_word": common_word
    }

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <directory_path>")
        sys.exit(1)

    directory = sys.argv[1]
    stats = process_directory(directory)
    print(json.dumps(stats, indent=4))
