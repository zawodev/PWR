#pragma once

#include "Evaluator.h"
#include "GeneticAlgorithm.h"
//#include "GeneticAlgorithmTwo.h"

#include <random>
#include <vector>

using namespace std;

class COptimizer {
public:
	COptimizer(CLFLnetEvaluator& cEvaluator);

	void vInitialize();
	void vRunIteration();

	vector<int>* pvGetCurrentBest() { return GA.GetGlobalBestGenes(); }

private:
	CLFLnetEvaluator& c_evaluator;
	mt19937 c_rand_engine;

	GeneticAlgorithm GA;
};