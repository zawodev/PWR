/*

#include <iostream>

//=== OPERTATORY === (ograniczenia)
   //1) nie mo¿na definiowaæ nowych w³asnych operatorów np:
   // ~-
   //2) nie mozemy zmieniac operatorom priorytetow / kolejnosci dzia³añ / ³¹cznoœci operatorów
   // 2+3+4 == (2+3)+4 != 2+(3+4)
   //3) nie mozna przeci¹¿aæ: 
   // "::", ".", ".*", "?:";
   //4) ograniczenia specyficzne dla operatora
   //
   //==============================================================================
   // <typ zwrotny> operator<symbol operatora>(<lista argumentow>);
   //
   //   
   
// 1) I SPOSÓB:

//table.h
class Table {
public:
    Table(int size);
    Table(const Table& other);
    ~Table();
    Table& operator=(const Table& other); //przypisanie kopiuj¹ce
    Table& operator=(Table other); //przypisanie kopiuj¹ce
private:
    int size;
    int* tab;

friend std::ostream& operator<<(std::ostream& os, const Table& tab);
};
//table.cpp (ifdef pragma co to google)
#include "Table.h";
Table::Table(int size) : size(size), tab(new int[size]()) {

}
Table::Table(const Table& other) : size(other.size), tab(new int[size]) { //kopiujace zawsze z constem
    for (int i = 0; i < size; ++i) {
        tab[i] = other.tab[i];
    }
}
Table::~Table() {
    delete[] tab;
}
Table& Table::operator=(const Table& other) { 
    if (this == &other) return *this; //t=t; zabezpieczenie
    delete[] tab;
    size = other.size;
    tab = new int[size];
    for (int i = 0; i < size; ++i) {
        tab[i] = other.tab[i];
    }
    return *this;
}
Table& Table::operator=(Table other) {
    size = other.size; //lepiej std:swap(size, other.size);
    std::swap(tab, other.tab); //wirtualna funkcja co to sprawdz
    return *this;
}

//2) II SPOSÓB:
//funkcja "globalna" (nie sk³adowa po prostu)

std::cout << "Hello" << name;
std::cout.operator<<("Hello").operator<<(name);

Table tab; ... //niema czegos takiego
std::cout << tab;
std::cout.operator<<(tab);

//=======================

std::ostream& operator<<(std::ostream& os, const Table& tab) { //friend of Table class
    os << "[";
    if (tab.size > 0) {
        os << tab.tab[0];
        for (int i = 1; i < tab.size; i++) {
            os << "," << tab.tab[i];
        }
    }
    return os << "]";
}

//FUNKCJE GLOBALNE

class Table
{//                             ||
public: //                      ||
    //...       (dotyczy *this) \/ [const;]
    int operator[](int index) const; //LUB: const int& operator[](int index);
    const int& operator[](int index);//LUB: (koñcówka) const;

private:
    //...
    int& operator[](int index);
};

*/