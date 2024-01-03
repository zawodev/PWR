#include <iostream>
#include "zad1.hpp"
#include "zad2.hpp"
#include "zad3.hpp"
#include "zad4.hpp"
#include "zad_mod.hpp"
using namespace std;

int main() {
    int iSize = 3;
    exercise_1(iSize);

    int** pi_table;
    int iSizeX = 5;
    int iSizeY = 3;
    exercise_2(&pi_table, iSizeX, iSizeY); //allocate
    exercise_3(&pi_table, iSizeX, iSizeY); //deallocate

    exercise_4();

    exercise_mod();
}