#include <iostream>
#include <string>
#include "zad3.hpp"
using namespace std;

bool b_dealloc_table_2_dim(int** pi_table, int iSizeX, int iSizeY) {
    if (iSizeX < 0 || iSizeY < 0) return false;

    //wypisz tablice
    /*
    for (int i = 0; i < iSizeX; i++) {
        for (int j = 0; j < iSizeY; j++) {
            cout << (pi_table)[i][j] << ' ';
        }
        cout << '\n';
    }
    */

    //deallokacja
	for (int i = 0; i < iSizeX; i++) {
		delete[] pi_table[i];
	}
	delete[] pi_table;
    return true;
}
void exercise_3(int*** pi_table, int iSizeX, int iSizeY) {
    cout << "\nZAD 3\n";

    if (b_dealloc_table_2_dim(*pi_table, iSizeX, iSizeY)) {
        cout << "Dealokacja pamieci udana\n";
    }
    else {
        cout << "Dealokacja pamieci nieudana\n";
    }
}