#ifndef GUI_HPP
#define GUI_HPP
#pragma once
//====================== HPP ======================
#include <iostream>
#include <vector>
#include "CTree.hpp"

enum AfterCommand { CONTINUE, EXIT, INT, DOUBLE, STRING };

class GUIBase {
public:
	virtual AfterCommand readUserInput(std::string input) = 0;
};

template<typename T> class GUI : public GUIBase {
private:
	CTree<T> TREE;
	std::vector<std::string> splitString(const std::string& input);
public:
	virtual AfterCommand readUserInput(std::string input) override;
};

#endif

//====================== CPP ======================

template<typename T> inline std::vector<std::string> GUI<T>::splitString(const std::string& input) {
	std::vector<std::string> result;
	std::string word = "";

	for (char ch : input) {
		if (ch != ' ') {
			word += ch;
		}
		else {
			if (!word.empty()) {
				//std::cout << word;
				result.push_back(word);
				word.clear();
			}
		}
	}

	if (!word.empty()) {
		result.push_back(word);
	}

	return result;
}

template<typename T> inline AfterCommand GUI<T>::readUserInput(std::string input) {
	std::vector<std::string> words = splitString(input);
	std::string msg = "";
	std::string commandListMsg = "Wpisz poprawn¹ komendê z listy:\n>enter\n>vars\n>print\n>comp\n>join\n>exit\n>changemode (int, double, string)\n";
	AfterCommand ac = CONTINUE;
	if (words.size() < 1) {
		msg = "Nie wpisano komendy. " + commandListMsg;
	}
	else {
		std::string command = words[0];

		if (command == "enter") {
			words.erase(words.begin());
			TREE.enter(words);
		}
		else if (command == "vars") {
			TREE.vars();
		}
		else if (command == "print") {
			TREE.print();
		}
		else if (command == "comp") {
			words.erase(words.begin());
			TREE.comp(words);
		}
		else if (command == "join") {
			words.erase(words.begin());
			TREE.join(words);
		}
		else if (command == "exit") {
			msg = "Koñczê dzia³anie programu.";
			ac = EXIT;
		}
		else if (command == "changemode") {
			if (words.size() != 2) {
				msg = "Niepoprawna iloœæ argumentów do komendy changemode. Wymagany jedynie jeden argument (int, string lub double).\n";
			}
			else {
				command = words[1];
				if (command == "int") {
					msg = "Zmieniono na drzewo o typie: INT\n";
					ac = INT;
				}
				else if (command == "double") {
					msg = "Zmieniono na drzewo o typie: DOUBLE\n";
					ac = DOUBLE;
				}
				else if (command == "string") {
					msg = "Zmieniono na drzewo o typie: STRING\n";
					ac = STRING;
				}
				else {
					msg = "Nie ma drzewa o takim typie. Dostêpne typy to: int, double, string.\n";
				}
			}
		}
		else {
			msg = "Komenda niepoprawna. " + commandListMsg;
		}
	}
	std::cout << msg << std::endl;
	return ac;
}
