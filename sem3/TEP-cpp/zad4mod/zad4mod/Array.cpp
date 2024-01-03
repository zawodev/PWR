#include <iostream>
#include "Array.hpp"


//napisz funkcjê, która zwraca sumê elementów tablicy

int sum(int* tab, int size) {
	int sum = 0;
	for (int i = 0; i < size; i++) {
		sum += tab[i];
	}
	return sum;
}

