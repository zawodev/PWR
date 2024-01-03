#ifndef CNODE_HPP
#define CNODE_HPP
#pragma once
//==================================================
#include <iostream>
#include <vector>

class CNode {
public:
	std::string val;
	std::vector<CNode*> children;

	CNode(const std::string& val) : val(val) {}
	void add(CNode* child);
	size_t childrenCount();

	void print(int level = 0);
	void printChildren(int level = 0);
	void printChildrenValues(int level = 0);
};


//==================================================
#endif