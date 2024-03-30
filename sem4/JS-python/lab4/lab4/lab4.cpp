#include <iostream>
#include <fstream>
#include <unordered_map>
#include <vector>
#include <algorithm>
#include <cctype>

using namespace std;

pair<char, int> findMostCommonCharacter(const unordered_map<char, int>& charCount) {
    return *max_element(charCount.begin(), charCount.end(),
                        [](const pair<char, int>& a, const pair<char, int>& b) {
                            return a.second < b.second; });
}

pair<string, int> findMostCommonWord(const unordered_map<string, int>& wordCount) {
    return *max_element(wordCount.begin(), wordCount.end(),
                        [](const pair<string, int>& a, const pair<string, int>& b) {
                            return a.second < b.second; });
}

int main() {
    string filePath;
    getline(cin, filePath);

    ifstream file(filePath);
    if (!file.is_open()) {
        cerr << "Nie można otworzyć pliku: " << filePath << endl;
        return 1;
    }

    unordered_map<char, int> charCount;
    unordered_map<string, int> wordCount;
    string word;
    int chars = 0, words = 0, lines = 0;
    char c;

    while (file.get(c)) {
        chars++;
        if (!isspace(c)) {
            word += c;
        }
        if (isspace(c) || file.peek() == EOF) {
            if (!word.empty()) {
                words++;
                transform(word.begin(), word.end(), word.begin(), ::tolower);
                wordCount[word]++;
                word.clear();
            }
        }
        if (c != '\n') {
            charCount[tolower(c)]++;
        } else {
            lines++;
        }
    }
    if (!word.empty()) lines++; // Counting last line if not ended with newline

    auto [mostCommonChar, charFreq] = findMostCommonCharacter(charCount);
    auto [mostCommonWord, wordFreq] = findMostCommonWord(wordCount);

    cout << "{\n"
         << "\"path\": \"" << filePath << "\",\n"
         << "\"characters\": " << chars << ",\n"
         << "\"words\": " << words << ",\n"
         << "\"lines\": " << lines << ",\n"
         << "\"most_common_character\": \"" << mostCommonChar << "\",\n"
         << "\"most_common_word\": \"" << mostCommonWord << "\"\n"
         << "}" << endl;

    return 0;
}
