#include <iostream>
#include "Array.hpp"


//napisz funkcj�, kt�ra zwraca sum� element�w tablicy

int sum(int* tab, int size) {
	int sum = 0;
	for (int i = 0; i < size; i++) {
		sum += tab[i];
	}
	return sum;
}

