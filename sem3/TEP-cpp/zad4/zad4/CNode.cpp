#include "CNode.hpp"
#include <iostream>
#include <vector>
#include <string>

void CNode::add(CNode* child) {
	children.push_back(child);
}

size_t CNode::childrenCount() {
	return children.size();
}

void CNode::print(int level) {
	for (int i = 0; i < level; i++) std::cout << "  ";
	std::cout << val << "\n";
	printChildren(level + 1);
}

void CNode::printChildren(int level) {
	for (auto child : children) {
		child->print(level);
	}
}

void CNode::printChildrenValues(int level) {
	for (auto child : children) {
		for (int i = 0; i < level; i++) std::cout << "  ";
		std::cout << child->val << "\n";
	}
}