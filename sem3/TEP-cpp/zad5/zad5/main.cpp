#include <iostream>
#include <locale.h>
#include "CMySmartPointer.hpp"
#include "CRefCounter.hpp"
#include "CTree.hpp"

void test_mysmartpointer() {
	//ZAD1
	CMySmartPointer<float> pc_pointer1(new float(3.5));
	CMySmartPointer<float> pc_pointer2(pc_pointer1);
	CMySmartPointer<float> pc_pointer3(new float(7.1));
	pc_pointer3 = pc_pointer1; //ZAD2
	std::cout << *pc_pointer1 << std::endl;
	std::cout << *pc_pointer2 << std::endl;
	std::cout << *pc_pointer3 << std::endl;
	*pc_pointer1 = 5.5;
	std::cout << *pc_pointer1 << std::endl;
	std::cout << *pc_pointer2 << std::endl;
	std::cout << *pc_pointer3 << std::endl;

	CMySmartPointer<int> pc_pointer4(new int(5));
	std::cout << *pc_pointer4 << std::endl << std::endl;

	//ZAD3 => Jeœli u¿yjemy inteligentnego wskaŸnika do przechowywania wskaŸnika na pamiêæ statyczn¹, 
	//		  to przy zniszczeniu obiektu klasy CMySmartPointer, nie nast¹pi prawid³owa dealokacja pamiêci.
}
void test_ctree() {
	//ZAD4
	CTree<int> tree1;
	CTree<int> tree2;
	tree1.enter({"1"});
	tree2.enter({"2"});
	tree2 = std::move(tree1);
	tree2.print();

	CTree<int> tree3;
	tree3.enter({"3"});
	CTree<int> tree4(std::move(tree3));
	tree4.print();
	std::cout << std::endl;
}
void test5() {
	//ZAD5
	CTree<int> tree1;
	tree1.enter({"+", "1", "2"});

	CTree<int>::copyCount = 0;
	CTree<int>::moveCount = 0;
	CTree<int> tree2 = tree1;
	std::cout << "liczba kopii: " << CTree<int>::copyCount << std::endl;
	std::cout << "liczba przeniesieñ: " << CTree<int>::moveCount << std::endl << std::endl;
	
	CTree<int>::copyCount = 0;
	CTree<int>::moveCount = 0;
	CTree<int> tree3 = std::move(tree1);
	std::cout << "liczba kopii: " << CTree<int>::copyCount << std::endl;
	std::cout << "liczba przeniesieñ: " << CTree<int>::moveCount << std::endl << std::endl;
}

int main() {
	setlocale(LC_CTYPE, "Polish");

	test_mysmartpointer();
	test_ctree();
	test5();
}