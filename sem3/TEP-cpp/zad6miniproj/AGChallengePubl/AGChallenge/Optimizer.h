#pragma once

#include "MyEvaluator.h"
#include "Evaluator.h"
#include "GeneticAlgorithm.h"
#include "GeneticAlgorithmTwo.h"
#include "GeneticAlgorithm3.h"

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
		//return GA.GetGlobalBestGenes();
		return GA.GetGlobalBestGenes();
	}

private:
	//GeneticAlgorithm GA;
	//GeneticAlgorithmTwo GA;
	GeneticAlgorithm3 GA;
	MyEvaluator myEvaluator;
};