import subprocess
import os
import sys
import json

def process_directory(directory):
    files_stats = {
        "files": 0,
        "total_characters": 0,
        "total_words": 0,
        "total_lines": 0,
        "common_char": "N/A",
        "common_word": "N/A"
    }
    common_chars = {}
    common_words = {}

    for root, dirs, files in os.walk(directory):
        for filename in files:
            filepath = os.path.abspath(os.path.join(root, filename)).replace('\\', '/')
            result = subprocess.run(["lab4-cpp/cmake-build-debug/lab4_cpp.exe"], input=filepath, text=True, capture_output=True)
            if result.returncode == 0 and result.stdout:
                data = json.loads(result.stdout)

                files_stats["files"] += 1
                files_stats["total_characters"] += data["characters"]
                files_stats["total_words"] += data["words"]
                files_stats["total_lines"] += data["lines"]

                for word, frequency in data["word_frequency"].items():
                    common_words[word] = common_words.get(word, 0) + frequency

                for char, frequency in data["char_frequency"].items():
                    common_chars[char] = common_chars.get(char, 0) + frequency
            else:
                print(f"error: {result.returncode}")

    # znajduje najwiekszy element z danego dicta
    files_stats["common_char"] = max(common_chars, key=common_chars.get, default="N/A")
    files_stats["common_word"] = max(common_words, key=common_words.get, default="N/A")

    return files_stats

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("usage: python lab4.py [path-to-files-dir]")
        sys.exit(1)

    _directory = sys.argv[1]
    _files_stats = process_directory(_directory)
    print(json.dumps(_files_stats, indent=4)) # indent = ilość wcięć
