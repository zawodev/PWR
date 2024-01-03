#include <iostream>
#include <string>
#include "zad_mod.hpp"
using namespace std;

void printArray2D(int** table, int* sizeArray, int iSizeX) {
    for (int i = 0; i < iSizeX; i++) {
        for (int j = 0; j < sizeArray[i]; j++) {
            cout << (table)[i][j] << ' ';
        }
        cout << '\n';
    }
}
void exercise_mod() {
    cout << "\nZAD MOD\n";
    const int iSizeX = 3;

    int* sizeArray = new int[iSizeX] {6, 4, 2};

    int** array2D = allocateIrregularArray2D(sizeArray, iSizeX);

    array2D[0][4] = 0;
    printArray2D(array2D, sizeArray, iSizeX);

    cout << "Zwalnianie pamieci zakonczone " << (deallocateIrregularArray2D(array2D, iSizeX) ? "sukcesem" : "niepowodzeniem");
}
int** allocateIrregularArray2D(int* sizeArray, int iSizeX) {
    if (iSizeX < 0 || sizeArray == nullptr) return nullptr;

    int** table = new int* [iSizeX];
    for (int i = 0; i < iSizeX; i++) {
        if (sizeArray[i] < 0) return nullptr;
    }
    for (int i = 0; i < iSizeX; i++) {
        table[i] = new int[sizeArray[i]];
    }

    return table;
}
bool deallocateIrregularArray2D(int** array2D, int iSizeX) {
    if (iSizeX < 0 || array2D == nullptr) return false;

    for (int i = 0; i < iSizeX; i++) {
        delete[] array2D[i];
    }
    delete[] array2D;
    return true;
}