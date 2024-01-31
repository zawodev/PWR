#pragma once

#include "MyEvaluator.h"
#include "Evaluator.h"
#include "GeneticAlgorithm.h"
#include "GeneticAlgorithmTwo.h"

#include <random>
#include <vector>

using namespace std;

class COptimizer {
public:
	COptimizer(CLFLnetEvaluator& cEvaluator);

	void vInitialize();
	void vRunIteration();

	vector<int>* pvGetCurrentBest() { 
		//return &GA.GetBestSpecimen().getGenes(); 
		return GA.GetGlobalBestGenes();
	}

private:
	GeneticAlgorithmTwo GA;
	MyEvaluator myEvaluator;
};