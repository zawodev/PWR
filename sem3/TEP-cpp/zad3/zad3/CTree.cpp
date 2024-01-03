#include "CTree.hpp"
#include <iostream>
#include <vector>
#include <string>
#include <map>

CNode* CTree::parseExpression(const std::vector<std::string>& words, int& index) {
	if (index >= words.size()) {
		std::cout << "Error: Unexpected end of expression." << std::endl;
		return nullptr;
	}

	CNode* newNode = new CNode(words[index]);
	if (isVariable(newNode->val)) variables[newNode->val] = 1;

	while (index + 1 < words.size()) {
		if (isNumber(newNode->val)) { //sta³a numeryczna 0 dzieci
			return newNode;
		}
		else if (isVariable(newNode->val)) { //zmiennna ma rozmiar 1 i 0 dzieci
			return newNode;
		}
		else if (isSinOrCos(newNode->val)) { //sin cos 1 dziecko
			if (newNode->childrenCount() < 1) {
				index++;
				newNode->add(parseExpression(words, index));
			}
			else {
				return newNode;
			}
		}
		else if (isOperator(newNode->val)) { //operator 2 dzieci
			if (newNode->childrenCount() < 2) {
				index++;
				newNode->add(parseExpression(words, index));
			}
			else {
				return newNode;
			}
		}
		else {
			std::cout << "Error: Unsuported variable name. Program will change it to number '1' instead.\n";
			newNode = new CNode("1");
			return newNode;
		}
	}

	return newNode;
}


double CTree::evalNode(CNode* node) {
	if (isNumber(node->val)) {
		return std::stod(node->val);
	}
	else if (isVariable(node->val)) {
		return variables.at(node->val);
	}
	else if (node->val == "sin") {
		return std::sin(evalNode(node->children[0]));
	}
	else if (node->val == "cos") {
		return std::cos(evalNode(node->children[0]));
	}
	else if (node->val == "+") {
		double result = 0;
		for (auto child : node->children)
			result += evalNode(child);
		return result;
	}
	else if (node->val == "*") {
		double result = 1;
		for (auto child : node->children)
			result *= evalNode(child);
		return result;
	}
	else if (node->val == "/") {
		if (node->childrenCount() == 2) {
			double var1 = evalNode(node->children[0]);
			double var2 = evalNode(node->children[1]);
			if (var2 == 0) {
				std::cout << "Error: Cant devide by 0! Returning first variable (dividend) instead.\n";
				return var1;
			}
			else {
				return var1 / var2;
			}
		}
		else {
			std::cout << "Incorrect devision arguments: required{2}, received{" << node->childrenCount() << "}. Returning one instead.\n";
			return 1;
		}
	}
	else if (node->val == "-") {
		if (node->childrenCount() == 2) {
			return evalNode(node->children[0]) - evalNode(node->children[1]);
		}
		else {
			std::cout << "Incorrect subtract arguments: required{2}, received{" << node->childrenCount() << "}. Returning one instead.\n";
			return 1;
		}
	}

	std::cout << "Something went terribly wrong. Returning one, because we have no better option. Parsed character was not: sin, cos, +, /, -, *, var, nor num\n";
	return 1;
}
void CTree::printTree(CNode* node) {
	if (node != nullptr) {
		std::cout << node->val << " ";
		for (auto child : node->children) {
			printTree(child);
		}
	}
}
void CTree::fixTree(CNode* node) {
	if (node != nullptr) {
		while ((isOperator(node->val) && node->childrenCount() < 2) || (isSinOrCos(node->val) && node->childrenCount() < 1)) {
			node->add(new CNode("1"));
		}
		for (auto child : node->children) {
			fixTree(child);
		}
	}
}

bool CTree::checkTree(CNode* node) {
	if (node != nullptr) {
		if ((isOperator(node->val) && node->childrenCount() < 2) || (isSinOrCos(node->val) && node->childrenCount() < 1)) {
			return false;
		}
		for (auto child : node->children) {
			return checkTree(child);
		}
	}
	return true;
}

int CTree::countNodes(CNode* node) {
	if (node == nullptr) return 0;
	int count = 1;
	for (auto child : node->children) {
		count += countNodes(child);
	}
	return count;
}

CNode* CTree::mergeTrees(CNode* treeA, CNode* treeB) {
	if (treeA == nullptr && treeB == nullptr) return nullptr;
	if (treeA == nullptr) return copyTree(treeB);
	if (treeB == nullptr) return copyTree(treeA);

	CNode* treeC = copyTree(treeA);
	CNode* leafC = findLeaf(treeC);

	leafC->val = treeB->val;
	for (auto a : treeB->children) {
		leafC->add(a);
	}

	return treeC;
}

CNode* CTree::findLeaf(CNode* node) {
	if (node->childrenCount() == 0) {
		return node;
	}
	return findLeaf(node->children.front());
}

CNode* CTree::copyTree(const CNode* node) const {
	if (!node) {
		return nullptr;
	}
	CNode* newNode = new CNode(node->val);
	for (const auto& child : node->children) {
		newNode->add(copyTree(child));
	}
	return newNode;
}

void CTree::deleteTree(CNode* node) {
	if (!node) {
		return;
	}
	for (auto& child : node->children) {
		deleteTree(child);
	}
	delete node;
}
CNode* CTree::createTree(std::vector<std::string> words, CNode* newRootNode) {
	variables = {};
	int index = 0;
	newRootNode = parseExpression(words, index);

	int nodesCount = countNodes(newRootNode);

	if (newRootNode == nullptr) {
		std::cout << "Error: Unable to parse expression.\n";
	}
	else if (!checkTree(newRootNode)) {
		std::cout << "Expression parsed incorrectly. Too few arguments. Correcting it to:\n";
		fixTree(newRootNode);
		printTree(newRootNode);
		std::cout << std::endl;
	}
	else if (nodesCount != words.size()) {
		std::cout << "Expression parsed incorrectly. Too many arguments. Correcting it to:\n";
		printTree(newRootNode);
		std::cout << std::endl;
	}
	else {
		std::cout << "Expression parsed successfully.\n";
	}

	return newRootNode;
}

bool CTree::isOperator(std::string str) {
	if (str == "+" || str == "*" || str == "/" || str == "-") return true;
	else return false;
}

bool CTree::isSinOrCos(std::string str) {
	if (str == "sin" || str == "cos") return true;
	else return false;
}

bool CTree::isNumber(std::string str) {
	if (std::isdigit(str[0]) || (str[0] == '-' && std::isdigit(str[1]))) return true;
	else return false;
}

bool CTree::isVariable(std::string str) {
	if (std::isalpha(str[0]) && !isSinOrCos(str)) return true;
	else return false;
}

CTree::CTree(const CTree& other) {
	rootNode = copyTree(other.rootNode);
}

CTree CTree::operator+(const CTree& other) {
	CTree result;
	result.rootNode = mergeTrees(rootNode, other.rootNode);
	return result;
}

CTree& CTree::operator=(const CTree& other) {
	if (this != &other) {
		deleteTree(rootNode);
		rootNode = copyTree(other.rootNode);
	}
	return *this;
}

void CTree::enter(std::vector<std::string> words) { //* + + 1 1 2 sin
	rootNode = createTree(words, rootNode);
}

void CTree::vars() {
	std::string result = "vars: ";
	if (!variables.empty()) {
		for (auto a : variables) {
			result += (a.first);
			result += ", ";
		}
		result.pop_back();
		result.pop_back();
	}
	std::cout << result << "\n";
}

void CTree::print() {
	printTree(rootNode);
	std::cout << std::endl;
}

void CTree::comp(std::vector<std::string> words) {
	int varsCount = variables.empty() ? 0 : variables.size();
	int wordsCount = words.size();
	if (varsCount != wordsCount) {
		std::cout << "Error: variables count does not equal inputed count. Inputed: {" << wordsCount << "}, Required: {" << varsCount << "}. Please try again." << std::endl;
		return;
	}
	else if (rootNode == nullptr) {
		std::cout << "Error: tree does not exist (rootNode == nullptr)" << std::endl;
		return;
	}

	std::map<std::string, double>::iterator it = variables.begin();
	int i = 0;

	while (it != variables.end()) {
		if (!isNumber(words[i])) {
			std::cout << "Error: Comp command requires to give number values, not whatever you just gave.\n";
			return;
		}
		variables[it->first] = stoi(words[i]);
		std::cout << it->first << " " << it->second << std::endl;
		it++;
		i++;
	}

	std::cout << "Evaluation: " << evalNode(rootNode) << std::endl;
}

void CTree::join(std::vector<std::string> words) {
	CNode* newTreeRoot = createTree(words, rootNode);
	rootNode = mergeTrees(rootNode, newTreeRoot);
	std::cout << "Trees joining completed successfully. Final tree looking like this:\n";
	print();
}