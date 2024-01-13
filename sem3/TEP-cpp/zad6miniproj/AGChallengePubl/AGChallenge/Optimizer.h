#pragma once

#include "Evaluator.h"

#include <random>
#include <vector>

using namespace std;

class COptimizer {
public:
	COptimizer(CLFLnetEvaluator& cEvaluator) : c_evaluator(cEvaluator) {
		random_device c_seed_generator;
		c_rand_engine.seed(c_seed_generator());
		d_current_best_fitness = 0;
	}

	void vInitialize();
	void vRunIteration();

	vector<int> *pvGetCurrentBest() { return &v_current_best; }

private:
	CLFLnetEvaluator& c_evaluator; //dont change
	vector<int> v_current_best; //dont change

	void v_fill_randomly(vector<int> &vSolution);
	double d_current_best_fitness;
	mt19937 c_rand_engine;

	//moje metody

	void quicksort(vector<pair<double, vector<int>>>& generation, int left, int right);
	void COptimizer::evaluateOsobnik(pair<double, vector<int>>& osobnik);
};