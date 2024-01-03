#include <iostream>
#include <string>
#include "zad2.hpp"
using namespace std;

bool b_alloc_table_2_dim(int*** pi_table, int iSizeX, int iSizeY) {
    if (iSizeX < 0 || iSizeY < 0) return false;

    *pi_table = new int* [iSizeX];
    for (int i = 0; i < iSizeX; i++) {
        (*pi_table)[i] = new int[iSizeY];
        //dziwny if
        /*
        if (tab[i] == nullptr) {
            //alokacja nieudana, zwalniamy pamiec (nie wiem czy ten wypadek moze wystapic w ogole)
            cout << '.';
            for (int j = 0; j < i; j++) {
                delete[] tab[j];
            }
            delete[] tab;
            return false;
        }
        */
    }

    //reset tablicy dwuwymiarowej
    /*
    for (int i = 0; i < iSizeX; i++) {
        for (int j = 0; j < iSizeY; j++) {
            tab[i][j] = 0;
        }
    }
    */
    //*pi_table = tab;
    return true;
}
void exercise_2(int*** pi_table, int iSizeX, int iSizeY) {
    cout << "\nZAD 2\n";

    if (b_alloc_table_2_dim(pi_table, iSizeX, iSizeY)) {
        cout << "Alokacja pamieci udana\n";

        //wypisz tablice
        ///*
        for (int i = 0; i < iSizeX; i++) {
            for (int j = 0; j < iSizeY; j++) {
                cout << (*pi_table)[i][j] << ' ';
            }
            cout << '\n';
        }
        //*/

        //dealokacja
        /*
        for (int i = 0; i < iSizeX; i++) {
            delete[] *pi_table[i];
        }
        delete[] *pi_table;
        */
    }
    else {
        cout << "Alokacja pamieci nieudana\n";
    }
}

