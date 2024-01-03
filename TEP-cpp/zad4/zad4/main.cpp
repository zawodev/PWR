#include <iostream>
#include <string>
#include <locale.h>
#include "CNode.hpp"
#include "CTree.hpp"
#include "GUI.hpp"

void printHelp() {
	std::cout << "Available commands:\n";
	std::cout << "int - change type of tree to int\n";
	std::cout << "double - change type of tree to double\n";
	std::cout << "string - change type of tree to string\n";
	std::cout << "exit - exit program\n";
	std::cout << "help - print this help\n";
}

int main() {
	setlocale(LC_CTYPE, "Polish");

	GUI<int> guiInt;
	GUI<double> guiDouble;
	GUI<std::string> guiString;

	GUIBase* gui = &guiInt; //stuff after "=" not important, something must be there
	AfterCommand ac = INT; //default type of tree

	std::string input = "";
	std::string currentTypeName = "none";

	while (true) {
		switch (ac) {
		case CONTINUE:
			std::cout << "cmd("<< currentTypeName << ")>";
			std::getline(std::cin, input);
			ac = gui->readUserInput(input);
			break;
		case INT:
			gui = &guiInt;
			currentTypeName = "int";
			ac = CONTINUE;
			break;
		case DOUBLE:
			gui = &guiDouble;
			currentTypeName = "double";
			ac = CONTINUE;
			break;
		case STRING:
			gui = &guiString;
			currentTypeName = "string";
			ac = CONTINUE;
			break;
		case EXIT:
			return 0;
		default:
			std::cout << "Something went wrong. Try again.\n";
			ac = CONTINUE;
			break;
		}
	}
}