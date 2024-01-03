#include <iostream>
#include <string>
#include <locale.h>
#include "CNode.hpp"
#include "CTree.hpp"
#include "GUI.hpp"

void test() {
	CTree a, b, c, d;
	a.enter({ "+", "a", "1" });
	b.enter({ "*", "2", "b" });
	c = a + b;
	d = b + a;
	a.print();
	b.print();
	c.print();
	d.print();
}
int main() {
	setlocale(LC_CTYPE, "Polish");
	//test();

	GUI gui;
	bool notExit = true;
	std::string s = "";

	do {
		std::cout << "cmd>";
		std::getline(std::cin, s);
		notExit = gui.readUserInput(s);
	} while (notExit);
}