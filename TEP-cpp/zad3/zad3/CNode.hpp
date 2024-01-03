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
	int childrenCount();
};


//==================================================
#endif