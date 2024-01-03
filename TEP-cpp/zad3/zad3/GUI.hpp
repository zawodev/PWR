#ifndef GUI_HPP
#define GUI_HPP
#pragma once
//==================================================
#include <iostream>
#include <vector>
#include "CTree.hpp"

class GUI {
private:
	void enter(std::vector<std::string> words);
	void vars();
	void print();
	void comp(std::vector<std::string> words);
	void join(std::vector<std::string> words);
	void exit();
	void none();

	std::vector<std::string> splitString(const std::string& input);
public:
	CTree TREE;
	bool readUserInput(std::string val);
};

#endif