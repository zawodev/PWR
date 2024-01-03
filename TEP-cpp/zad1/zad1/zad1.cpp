#include <iostream>
#include <string>
#include "zad1.hpp"
using namespace std;

void v_alloc_table_fill_34(int iSize) {
    int* tab;
    tab = new int[iSize];

    for (int i = 0; i < iSize; i++) {
        tab[i] = 34;
        cout << tab[i] << ' ';
    }
    cout << endl;
    delete[] tab;
}

void exercise_1(int iSize) {
    cout << "ZAD 1\n";

    if (iSize >= 0) {
        cout << "Poprawna wartosc parametru iSize\n";
        v_alloc_table_fill_34(iSize);
    }
    else {
        cout << "Niepoprawna wartosc parametru iSize\n";
    }
}