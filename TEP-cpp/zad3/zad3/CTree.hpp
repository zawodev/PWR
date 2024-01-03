#ifndef CTREE_HPP
#define CTREE_HPP
#pragma once
//==================================================
#include <iostream>
#include <vector>
#include <map>
#include "CNode.hpp"

class CTree {
private:
	CNode* rootNode;
	std::map<std::string, double> variables;

	CNode* parseExpression(const std::vector<std::string>& tokens, int& index);
	double evalNode(CNode* node);

	int countNodes(CNode* node);
	CNode* mergeTrees(CNode* treeA, CNode* treeB);
	CNode* findLeaf(CNode* node);

	void printTree(CNode* node);
	void fixTree(CNode* node);
	bool checkTree(CNode* node);
	CNode* copyTree(const CNode* node) const;
	void deleteTree(CNode* node);
	CNode* createTree(std::vector<std::string> words, CNode* newRootNode);

	bool isOperator(std::string str);
	bool isSinOrCos(std::string str);
	bool isNumber(std::string str);
	bool isVariable(std::string str);
public:
	CTree() : rootNode(nullptr), variables({}) {};
	CTree(const CTree& other);

	CTree operator+(const CTree& other);
	CTree& operator=(const CTree& other);

	void enter(std::vector<std::string> words);
	void vars();
	void print();
	void comp(std::vector<std::string> words);
	void join(std::vector<std::string> words);
};

//==================================================
#endif