#include "CNode.hpp"
#include <iostream>
#include <vector>
#include <string>

void CNode::add(CNode* child) {
	children.push_back(child);
}

int CNode::childrenCount() {
	return children.size();
}
