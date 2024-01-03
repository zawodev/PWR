#include "GUI.hpp"
#include <iostream>
#include <vector>


void GUI::enter(std::vector<std::string> words) {
	TREE.enter(words);
}
void GUI::vars() {
	TREE.vars();
}
void GUI::print() {
	TREE.print();
}
void GUI::comp(std::vector<std::string> words) {
	TREE.comp(words);
}
void GUI::join(std::vector<std::string> words) {
	TREE.join(words);
}
void GUI::exit() {
	std::string s = "Koñczê dzia³anie programu.";
	std::cout << s << std::endl;
}
void GUI::none() {
	std::string s = "Komenda niepoprawna. Wpisz poprawn¹ komendê z listy:\n>enter\n>vars\n>print\n>comp\n>join\n>exit\n";
	std::cout << s << std::endl;
}



std::vector<std::string> GUI::splitString(const std::string& input) {
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
bool GUI::readUserInput(std::string input) {
	
	std::vector<std::string> words = splitString(input);
	if (words.size() < 1) {
		none();
		return true;
	}
	std::string command = words[0];

	if (command == "enter") {
		words.erase(words.begin());
		enter(words);
	}
	else if (command == "vars") {
		vars();
	}
	else if (command == "print") {
		print();
	}
	else if (command == "comp") {
		words.erase(words.begin());
		comp(words);
	}
	else if (command == "join") {
		words.erase(words.begin());
		join(words);
	}
	else if (command == "exit") {
		exit();
		return false;
	}
	else {
		none();
	}
	return true;
}
