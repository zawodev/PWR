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
        cerr << "nie można otworzyć pliku: " << filePath << endl;
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
    if (!word.empty()) lines++; // counting last line if not ended with endl

    auto [mostCommonChar, charFreq] = findMostCommonCharacter(charCount);
    auto [mostCommonWord, wordFreq] = findMostCommonWord(wordCount);

    cout << "{" << endl
         << "\"path\": \"" << filePath << "\"," << endl
         << "\"characters\": " << chars << "," << endl
         << "\"words\": " << words << "," << endl
         << "\"lines\": " << lines << "," << endl
         << "\"most_common_character\": \"" << mostCommonChar << "\"," << endl
         << "\"most_common_word\": \"" << mostCommonWord << "\"," << endl
         << "\"word_frequency\": {" << endl;
    for (auto it = wordCount.begin(); it != wordCount.end(); ++it) {
        cout << "\"" << it->first << "\": " << it->second;
        if (next(it) != wordCount.end()) {
            cout << ",";
        }
        cout << endl;
    }
    cout << "}," << endl
         << "\"char_frequency\": {" << endl;
    for (auto it = charCount.begin(); it != charCount.end(); ++it) {
        cout << "\"" << it->first << "\": " << it->second;
        if (next(it) != charCount.end()) {
            cout << ",";
        }
        cout << endl;
    }
    cout << "}" << endl
         << "}" << endl;

    //test polskiego alfabetu

    return 0;
    //    C:\Users\aliks\Documents\GitHub\PWR\sem4\JS-python\lab4\lab4-files\test2.txt
}
