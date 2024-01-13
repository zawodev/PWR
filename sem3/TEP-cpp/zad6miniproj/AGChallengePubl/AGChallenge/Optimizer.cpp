#include "Optimizer.h"

#include <cfloat>
#include <iostream>
#include <windows.h>

using namespace std;

static int generationSize = 1000; //liczba osobnikow w populacji
static double mutationChance = .1; //szansa na mutacje w danym osobniku
static double mutationAmount = .9; //srednia wartosc mutacji w danym osobniku
static double removalPercent = .9; //usuwamy % najgorszych osobnikow

vector<pair<double, vector<int>>> generation;

void COptimizer::vInitialize() {
	//ustawiamy najlepsze rozwiazanie na najgorsze mozliwe
	d_current_best_fitness = -DBL_MAX;
	v_current_best.clear();

	//tworzymy losowe rozwiazania
	for (int i = 0; i < generationSize; i++) {
		vector<int> candidate;
		v_fill_randomly(candidate);
		generation.push_back({0, candidate});
	}
}

void COptimizer::vRunIteration() {
	//sortujemy rozwiazania od najlepszego do najgorszego
	quicksort(generation, 0, generationSize - 1);
	reverse(generation.begin(), generation.end());

	//sprawdzamy czy najlepsze rozwiazanie z tej generacji jest lepsze od najlepszego z dotychczasowych rozwiazan
	pair<double, vector<int>> candidate = generation[0];
	evaluateOsobnik(candidate);
	if (candidate.first > d_current_best_fitness) {
		v_current_best = candidate.second;
		d_current_best_fitness = candidate.first;
		cout << d_current_best_fitness << endl;
	}

	//usuwanie najgorszych rozwi¹zañ
	int removalSize = (int)(generationSize * removalPercent);
	for (int i = 0; i < removalSize; i++) {
		generation.pop_back();
	}
	generationSize -= removalSize;

	//tworzymy nowe rozwi¹zania krzy¿uj¹c najlepsze z poprzedniej generacji
	for (int i = 0; i < removalSize; i++) {
		pair<double, vector<int>> candidate;
		pair<double, vector<int>> parent1 = generation[c_rand_engine() % generationSize];
		pair<double, vector<int>> parent2 = generation[c_rand_engine() % generationSize];
		for (int j = 0; j < parent1.second.size(); j++) {
			if (c_rand_engine() % 2 == 0) candidate.second.push_back(parent1.second[j]);
			else candidate.second.push_back(parent2.second[j]);
		}
		generation.push_back(candidate);
	}
	generationSize += removalSize;

	//mutujemy tylko niektore z nowych rozwiazan
	for (int i = 0; i < generationSize; i++) {
		if (c_rand_engine() % 100 < mutationChance * 100) {
			pair<double, vector<int>> candidate = generation[i];
			for (int j = 0; j < candidate.second.size(); j++) {
				if (c_rand_engine() % 100 < mutationAmount * 100) {
					candidate.second[j] = lRand(c_evaluator.iGetNumberOfValues(j));
				}
			}
			generation[i] = candidate;
		}
	}
}
void COptimizer::evaluateOsobnik(pair<double, vector<int>>& osobnik) {
	osobnik.first = c_evaluator.dEvaluate(&osobnik.second);
}

void COptimizer::quicksort(vector<pair<double, vector<int>>>& generation, int left, int right) {
	int i = left, j = right;
	pair<double, vector<int>> tmp;
	double pivot = generation[(left + right) / 2].first;

	while (i <= j) {
		while (generation[i].first < pivot) i++;
		while (generation[j].first > pivot) j--;
		if (i <= j) {
			tmp = generation[i];
			generation[i] = generation[j];
			generation[j] = tmp;
			i++;
			j--;
		}
	};

	if (left < j) quicksort(generation, left, j);
	if (i < right) quicksort(generation, i, right);
}
void COptimizer::v_fill_randomly(vector<int> &vSolution) { //mod
	vSolution.resize((size_t)c_evaluator.iGetNumberOfBits());
	for (int ii = 0; ii < vSolution.size(); ii++) {
		vSolution.at(ii) = lRand(c_evaluator.iGetNumberOfValues(ii));
	}
}
