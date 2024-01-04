#ifndef CTREE_HPP
#define CTREE_HPP
#pragma once
//====================== HPP ======================
#include <iostream>
#include <vector>
#include <string>
#include <map>
#include "CNode.hpp"

//template <typename T> class CTree;
template <typename T> class CTree {
private:
	//------------ variables ------------

	CNode* rootNode;
	std::map<std::string, T> variables;

	static std::string defaultNodeVal;
	static std::string typeName;

	//------------ functions ------------

	T evalNode(CNode* node); //specjalizacja
	CNode* parseExpression(const std::vector<std::string>& words, int& index);

	CNode* findLeaf(CNode* node);
	CNode* mergeTrees(CNode* treeA, CNode* treeB);
	CNode* createTree(std::vector<std::string> words, CNode* newRootNode);

	void printTree(CNode* node);
	bool checkTree(CNode* node);
	void fixTree(CNode* node);
	CNode* copyTree(const CNode* node) const;
	void deleteTree(CNode* node);

	int countNodes(CNode* node);
	T stot(std::string str); //specjalizacja
	std::string correctString(std::string str);

	bool isOperator(std::string str);
	bool isSinOrCos(std::string str);
	bool isVariable(std::string str);
	bool isIntNumber(std::string str);
	bool isDoubleNumber(std::string str);
	bool isString(std::string str);
	bool isTypeT(std::string str); //specjalizacja
public:
	//------------ variables ------------

	static int copyCount;
	static int moveCount;

	//------------ functions ------------

	CTree() : rootNode(nullptr), variables({}) {};
	CTree(const CTree& other) : rootNode(copyTree(other.rootNode)), variables({}) { copyCount++; };
	CTree(CTree&& other) : rootNode(other.rootNode), variables({}) { moveCount++; other.rootNode = nullptr; }; //regu³a 5

	CTree<T> operator+(const CTree<T>& other);

	//CTree<T>& operator=(const CTree<T>& other);
	CTree<T> operator=(const CTree<T>& other);
	//CTree<T>& operator=(CTree<T>&& other);
	CTree<T> operator=(CTree<T>&& other); //regu³a 5

	void enter(std::vector<std::string> words);
	void vars();
	void print();
	void comp(std::vector<std::string> words);
	void join(std::vector<std::string> words);
};

//---------------- INT ----------------
template<>std::string CTree<int>::defaultNodeVal = "1";
template<>std::string CTree<int>::typeName = "INT";

//--------------- DOUBLE ---------------
template<>std::string CTree<double>::defaultNodeVal = "3.14159265358979";
template<>std::string CTree<double>::typeName = "DOUBLE";

//--------------- STRING ---------------
template<>std::string CTree<std::string>::defaultNodeVal = "\"1\"";
template<>std::string CTree<std::string>::typeName = "STRING";

#endif
//====================== TPP ======================

template <typename T> int CTree<T>::copyCount = 0;
template <typename T> int CTree<T>::moveCount = 0;

template<typename T> inline CNode* CTree<T>::parseExpression(const std::vector<std::string>& words, int& index) {
	if (index >= words.size()) {
		std::cout << "Error: Unexpected end of expression." << std::endl;
		return nullptr;
	}

	CNode* newNode = new CNode(words[index]);

	while (index < words.size()) {
		if (isTypeT(newNode->val)) { //sta³a typu T ma 0 dzieci
			return newNode;
		}
		else if (isVariable(newNode->val) || (isSinOrCos(newNode->val) && typeName == "STRING")) { //zmiennna ma rozmiar 1 i 0 dzieci
			return newNode;
		}
		else if (isSinOrCos(newNode->val) && typeName != "STRING") { //sin cos 1 dziecko
			if (newNode->childrenCount() < 1 && index + 1 < words.size()) {
				index++;
				newNode->add(parseExpression(words, index));
			}
			else {
				return newNode;
			}
		}
		else if (isOperator(newNode->val)) { //operator 2 dzieci
			while (newNode->childrenCount() < 2 && index + 1 < words.size()) {
				index++;
				newNode->add(parseExpression(words, index));
			}
			return newNode;
		}
		else {
			std::cout << "Error: Unsuported variable name. Program will change it to: " << defaultNodeVal << " instead.\n";
			newNode = new CNode(defaultNodeVal);
			return newNode;
		}
	}

	return newNode;
}

template<typename T> inline CNode* CTree<T>::findLeaf(CNode* node) {
	if (node->childrenCount() == 0) {
		return node;
	}
	return findLeaf(node->children.front());
}

template<typename T> inline CNode* CTree<T>::mergeTrees(CNode* treeA, CNode* treeB) {
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

template<typename T> inline CNode* CTree<T>::createTree(std::vector<std::string> words, CNode* newRootNode) {
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

template<typename T> inline void CTree<T>::printTree(CNode* node) {
	if (node != nullptr) {
		std::cout << node->val << " ";
		for (auto child : node->children) {
			printTree(child);
		}
	}
}

template<typename T> inline bool CTree<T>::checkTree(CNode* node) {
	if (node != nullptr) {
		if ((isOperator(node->val) && node->childrenCount() < 2) || (isSinOrCos(node->val) && node->childrenCount() < 1 && typeName != "STRING")) {
			return false;
		}
		for (auto child : node->children) {
			return checkTree(child);
		}
	}
	return true;
}

template<typename T> inline void CTree<T>::fixTree(CNode* node) {
	if (node != nullptr) {
		if (isVariable(node->val) || (isSinOrCos(node->val) && typeName == "STRING")) variables[node->val] = stot(defaultNodeVal);
		while ((isOperator(node->val) && node->childrenCount() < 2) || (isSinOrCos(node->val) && node->childrenCount() < 1 && typeName != "STRING")) {
			node->add(new CNode(defaultNodeVal));
		}
		for (auto child : node->children) {
			fixTree(child);
		}
	}
}

template<typename T> inline CNode* CTree<T>::copyTree(const CNode* node) const {
	if (!node) return nullptr;

	CNode* newNode = new CNode(node->val);
	for (const auto& child : node->children) {
		newNode->add(copyTree(child));
	}
	return newNode;
}

template<typename T> inline void CTree<T>::deleteTree(CNode* node) {
	if (!node) return;

	for (auto& child : node->children) {
		deleteTree(child);
	}
	delete node;
}

template<typename T> inline int CTree<T>::countNodes(CNode* node) {
	if (node == nullptr) return 0;
	int count = 1;
	for (auto child : node->children) {
		count += countNodes(child);
	}
	return count;
}

template<typename T> inline std::string CTree<T>::correctString(std::string str) {
	return str.substr(1, str.size() - 2);
}

template<typename T> inline bool CTree<T>::isOperator(std::string str) {
	if (str == "+" || str == "*" || str == "/" || str == "-") return true;
	else return false;
}

template<typename T> inline bool CTree<T>::isSinOrCos(std::string str) {
	if (str == "sin" || str == "cos") return true;
	else return false;
}

template<typename T> inline bool CTree<T>::isVariable(std::string str) {
	if (std::isalpha(str[0]) && !isSinOrCos(str)) return true;
	else return false;
}

template<typename T> inline bool CTree<T>::isIntNumber(std::string str) {
	if (str.size() == 0) return false;
	if (std::count(str.begin(), str.end(), '.') > 0) return false;
	if (!std::isdigit(str[0]) && str[0] != '-') return false;

	for (int i = 1; i < str.size(); i++) {
		if (!std::isdigit(str[i])) return false;
	}
	return true;
}

template<typename T> inline bool CTree<T>::isDoubleNumber(std::string str) {
	if (str.size() == 0) return false;
	if (str.size() == 1 && str[0] == '.') return false;
	if (std::count(str.begin(), str.end(), '.') > 1) return false;
	if (!std::isdigit(str[0]) && str[0] != '-' && str[0] != '.') return false;

	for (int i = 1; i < str.size(); i++) {
		if (!std::isdigit(str[i]) && str[i] != '.') return false;
	}
	return true;
}

template<typename T>inline bool CTree<T>::isString(std::string str) {
	if ((str[0] == '"' && str[str.size() - 1] == '"' && str.size() > 1)) return true;
	else return false;
}

//========================= PUBLIC =========================

template<typename T> inline CTree<T> CTree<T>::operator+(const CTree& other) {
	CTree result;
	result.rootNode = mergeTrees(rootNode, other.rootNode);
	return result;
}

/*
template<typename T> inline CTree<T>& CTree<T>::operator=(const CTree<T>& other) {
	if (this != &other) {
		deleteTree(rootNode);
		rootNode = copyTree(other.rootNode);
	}
	return *this;
}

template<typename T> inline CTree<T>& CTree<T>::operator=(CTree<T>&& other) {
	if (this != &other) {
		deleteTree(rootNode);
		rootNode = other.rootNode; //rootNode = std::exchange(other.rootNode, nullptr);
		other.rootNode = nullptr;
	}
	return *this;
}
*/

template<typename T> inline CTree<T> CTree<T>::operator=(const CTree<T>& other) {
	if (this != &other) {
		deleteTree(rootNode);
		rootNode = copyTree(other.rootNode);
	}
	return *this;
}

template<typename T> inline CTree<T> CTree<T>::operator=(CTree<T>&& other) {
	if (this != &other) {
		deleteTree(rootNode);
		rootNode = std::exchange(other.rootNode, nullptr);
	}
	return *this;
}


template<typename T> inline void CTree<T>::enter(std::vector<std::string> words) {
	variables = {};
	rootNode = createTree(words, rootNode);
	fixTree(rootNode);
}

template<typename T> inline void CTree<T>::vars() {
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

template<typename T> inline void CTree<T>::print() {
	printTree(rootNode);
	std::cout << std::endl;
}

template<typename T> inline void CTree<T>::comp(std::vector<std::string> words) {
	size_t varsCount = variables.empty() ? 0 : variables.size();
	size_t wordsCount = words.size();
	if (varsCount != wordsCount) {
		std::cout << "Error: variables count does not equal inputed count. Inputed: {" << wordsCount << "}, Required: {" << varsCount << "}. Please try again." << std::endl;
		return;
	}
	else if (rootNode == nullptr) {
		std::cout << "Error: tree does not exist (rootNode == nullptr)" << std::endl;
		return;
	}

	typename std::map<std::string, T>::iterator it = variables.begin();
	int i = 0;

	while (it != variables.end()) {
		if (!isTypeT(words[i])) {
			std::cout << "Error: This comp command requires to be type: " << typeName << ", not whatever you just gave.\n";
			return;
		}
		variables[it->first] = stot(words[i]);
		std::cout << it->first << " " << it->second << std::endl;
		it++;
		i++;
	}

	std::cout << "Evaluation: " << evalNode(rootNode) << std::endl;
}

template<typename T> inline void CTree<T>::join(std::vector<std::string> words) {
	variables = {};
	CNode* newTreeRoot = createTree(words, rootNode);
	rootNode = mergeTrees(rootNode, newTreeRoot);
	fixTree(rootNode);
	std::cout << "Trees joining completed successfully. Final tree looking like this:\n";
	print();
}