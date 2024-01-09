#include <iostream>
#include <locale.h>
#include "CMySmartPointer.hpp"
#include "CRefCounter.hpp"
#include "CTree.hpp"

void test_123() { //my smart pointer test
	std::cout << "ZAD 1, 2, 3" << std::endl;
	//ZAD1
	CMySmartPointer<float> pc_pointer1(new float(3.5));
	CMySmartPointer<float> pc_pointer2(pc_pointer1);
	CMySmartPointer<float> pc_pointer3(new float(7.1));
	pc_pointer3 = pc_pointer1; //ZAD2
	std::cout << *pc_pointer1 << std::endl;
	std::cout << *pc_pointer2 << std::endl;
	std::cout << *pc_pointer3 << std::endl << std::endl;
	*pc_pointer1 = 5.5;
	std::cout << *pc_pointer1 << std::endl;
	std::cout << *pc_pointer2 << std::endl;
	std::cout << *pc_pointer3 << std::endl << std::endl;

	CMySmartPointer<int> pc_pointer4(new int(5));
	std::cout << *pc_pointer4 << std::endl << std::endl;

	//ZAD3 => Je�li u�yjemy inteligentnego wska�nika do przechowywania wska�nika na pami�� statyczn�, 
	//		  to przy zniszczeniu obiektu klasy CMySmartPointer, nie nast�pi prawid�owa dealokacja pami�ci.
}
void test_4() {
	std::cout << "ZAD 4" << std::endl;
	//ZAD4
	CTree<int> tree1;
	CTree<int> tree2;
	tree1.enter({ "1" });
	tree2.enter({ "2" });
	tree2 = std::move(tree1);
	//tree1.print(); //nie mozemy wypisac tree1 bo wskazuje na nullptr (zostalo przeniesione)
	tree2.print();

	std::cout << std::endl;
}
void test_5() {

	std::cout << "ZAD 5" << std::endl;
	//ZAD5
	CTree<int> tree1, tree2, tree3, tree4;
	tree1.enter({ "-", "1", "2" });
	tree2.enter({ "+", "2", "3" });
	tree3.enter({ "*", "3", "4" });
	tree4.enter({ "/", "4", "5" });

	CTree<int>::copyCount = 0;
	CTree<int>::moveCount = 0;
	tree2 = tree1;
	//tree1.print();
	//tree2.print();
	std::cout << "liczba kopii: " << CTree<int>::copyCount << std::endl;
	std::cout << "liczba przeniesie�: " << CTree<int>::moveCount << std::endl << std::endl;

	CTree<int>::copyCount = 0;
	CTree<int>::moveCount = 0;
	tree4 = std::move(tree3);
	//tree4.print(); //normalnie wypisywalny
	//tree3.print(); //nie mozemy wypisac tree3 bo wskazuje na nullptr (zostalo przeniesione)
	std::cout << "liczba kopii: " << CTree<int>::copyCount << std::endl;
	std::cout << "liczba przeniesie�: " << CTree<int>::moveCount << std::endl << std::endl;

	//ZAD 5 => liczba kopii spadnie z 6 do 0 w powy�szym przypadku, poniewa� wykonaj� si� 2 kopi� drzewa, 
	//		   raz przy kopiowaniu wszystkiego do roota, (3 kopie, po 1 dla ka�dego noda)
	//		   drugi raz przy wyj�ciu z operatora.
	//		   liczba kopii wzrasta rzecz jasna dla wi�kszych drzew.
	// 
	//         mo�na unikn�� 3 dodatkowych kopii stosuj�c referencje zamiast zwracania przez warto��.
	// 
	// 	       liczba przeniesie� wzro�nie z 0 do 2, poniewa� wykonuje si� tylko przeniesienie 1 wskaznika na roota.
	//         drugie przeniesienie wykonuje si� przy wyj�ciu z operatora.
}

int main() {
	setlocale(LC_CTYPE, "Polish");

	test_123();
	test_4();
	test_5();
}