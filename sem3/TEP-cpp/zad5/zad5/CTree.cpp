#include "CTree.hpp"
#include <iostream>
#include <vector>
#include <string>
#include <map>

//---------------- INT ----------------

template<> bool CTree<int>::isTypeT(std::string str) {
	return isIntNumber(str);
}
template<> int CTree<int>::stot(std::string str) {
	return std::stoi(str);
}
template<> int CTree<int>::evalNode(CNode* node) {
	if (isIntNumber(node->val)) {
		return std::stoi(node->val);
	}
	else if (isVariable(node->val)) {
		return variables.at(node->val);
	}
	else if (node->val == "sin") {
		return int(std::sin(evalNode(node->children[0])));
	}
	else if (node->val == "cos") {
		return int(std::cos(evalNode(node->children[0])));
	}
	else if (node->val == "+") {
		int result = 0;
		for (auto child : node->children)
			result += evalNode(child);
		return result;
	}
	else if (node->val == "*") {
		int result = 1;
		for (auto child : node->children)
			result *= evalNode(child);
		return result;
	}
	else if (node->val == "/") {
		if (node->childrenCount() == 2) {
			int var1 = evalNode(node->children[0]);
			int var2 = evalNode(node->children[1]);
			if (var2 != 0) return var1 / var2;
			else {
				std::cout << "Error: Cant devide by 0! Returning first variable (dividend) instead.\n";
				return var1;
			}
		}
		else {
			std::cout << "Incorrect devision arguments: required{2}, received{" << node->childrenCount() << "}. Returning: " << defaultNodeVal << " instead.\n";
			return std::stoi(defaultNodeVal);
		}
	}
	else if (node->val == "-") {
		if (node->childrenCount() == 2) {
			return evalNode(node->children[0]) - evalNode(node->children[1]);
		}
		else {
			std::cout << "Incorrect subtract arguments: required{2}, received{" << node->childrenCount() << "}. Returning: " << defaultNodeVal << " instead.\n";
			return std::stoi(defaultNodeVal);
		}
	}

	std::cout << "Something went terribly wrong. Returning: " << defaultNodeVal << ", because no better option. Parsed character was not: sin, cos, +, /, -, *, var, nor num\n";
	return std::stoi(defaultNodeVal);
}

//--------------- DOUBLE ---------------

template<> bool CTree<double>::isTypeT(std::string str) {
	return isDoubleNumber(str);
}
template<> double CTree<double>::stot(std::string str) {
	return std::stod(str);
}
template<> double CTree<double>::evalNode(CNode* node) {
	if (isDoubleNumber(node->val)) {
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
			if (var2 != 0) return var1 / var2;
			else {
				std::cout << "Error: Cant devide by 0! Returning first variable (dividend) instead.\n";
				return var1;
			}
		}
		else {
			std::cout << "Incorrect devision arguments: required{2}, received{" << node->childrenCount() << "}. Returning: " << defaultNodeVal << " instead.\n";
			return std::stod(defaultNodeVal);
		}
	}
	else if (node->val == "-") {
		if (node->childrenCount() == 2) {
			return evalNode(node->children[0]) - evalNode(node->children[1]);
		}
		else {
			std::cout << "Incorrect subtract arguments: required{2}, received{" << node->childrenCount() << "}. Returning: " << defaultNodeVal << " instead.\n";
			return std::stod(defaultNodeVal);
		}
	}

	std::cout << "Something went terribly wrong. Returning: " << defaultNodeVal << ", because we have no better option. Parsed character was not: sin, cos, +, /, -, *, var, nor num\n";
	return std::stod(defaultNodeVal);
}

//--------------- STRING ---------------

template<> bool CTree<std::string>::isTypeT(std::string str) {
	return isString(str);
}
template<> std::string CTree<std::string>::stot(std::string str) {
	return str;
}
template<> std::string CTree<std::string>::evalNode(CNode* node) {
	if (isString(node->val)) {
		return node->val;
	}
	else if (isVariable(node->val) || isSinOrCos(node->val)) {
		return variables.at(node->val);
	}
	else if (node->val == "+") { //n parametrowy potencjalnie
		std::string result = "";
		for (auto child : node->children) {
			result += correctString(evalNode(child));
		}

		return "\"" + result + "\"";
	}
	else if (node->val == "*") { //2 parametrowy koniecznie
		std::string child1 = correctString(evalNode(node->children[0]));
		std::string child2 = correctString(evalNode(node->children[1]));

		std::string result = "";
		for (auto chr : child1) {
			if (child2[0] == chr) result += child2;
			else result += chr;
		}

		return "\"" + result + "\"";
	}
	else if (node->val == "/") { //2 parametrowy koniecznie
		/* // implementacja oryginalna
		std::string child1 = correctString(evalNode(node->children[0]));
		std::string child2 = correctString(evalNode(node->children[1]));
		std::string result = child1;

		if (child2.size() > 0) {
			int pos = 0;
			while ((pos = result.find(child2, pos)) != std::string::npos) {
				if (pos + child2.length() < result.length()) result.replace(pos + 1, child2.length() - 1, "");
				else break;
			}
		}

		return "\"" + result + "\"";
		*/
		/*//implementacja 2
		std::string child1 = correctString(evalNode(node->children[0]));
		std::string child2 = correctString(evalNode(node->children[1]));

		size_t pos = child1.rfind(child2);
		while (pos != std::string::npos) {
			child1 = child1.substr(0, pos) + child1.substr(pos + child2.size());
			pos = child1.rfind(child2);
		}

		return "\"" + child1 + "\"";
		*/
		std::string child1 = correctString(evalNode(node->children[0]));
		std::string child2 = correctString(evalNode(node->children[1]));
		if (child2 == "" || child1.size() < child2.size()) return "\"" + child1 + "\"";

		std::string result = "";

		size_t i = 0;
		while (i < child1.size()) {
			std::string temp = child1.substr(i, child2.size());
			result += temp[0];

			if (temp.find(child2) == std::string::npos) i++;
			else i += child2.size();
			//std::cout << temp << " : " << result << " : " << pos << " : " << i << std::endl;
		}

		return "\"" + result + "\"";
	}
	else if (node->val == "-") { //2 parametrowy koniecznie
		/*
		int diff = child1.size() - child2.size();
		if (diff < 0) return child1;

		for (int i = 0; i < child2.size(); i++) {
			if (child1[i + diff] != child2[i]) {
				return "\"" + child1 + "\"";
			}
		}

		std::string result = "";
		for (int i = 0; i < diff; i++) {
			result += child1[i];
		}
		*/
		std::string child1 = correctString(evalNode(node->children[0]));
		std::string child2 = correctString(evalNode(node->children[1]));
		std::string result = child1;

		size_t pos = child1.rfind(child2);
		if (pos != std::string::npos) result = child1.replace(pos, child2.size(), ""); //substr(0, pos) + child1.substr(pos + child2.size());

		return "\"" + result + "\"";
	}

	std::cout << "Something went terribly wrong. Returning: " << defaultNodeVal << ", because we have no better option. Parsed character was not: sin, cos, +, /, -, *, var, nor num\n";
	return defaultNodeVal;
}