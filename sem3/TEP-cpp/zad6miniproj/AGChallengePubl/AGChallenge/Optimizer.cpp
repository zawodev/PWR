#include "Optimizer.h"

#include <cfloat>
#include <iostream>
#include <windows.h>

using namespace std;

COptimizer::COptimizer(CLFLnetEvaluator& cEvaluator) : myEvaluator(cEvaluator), GA(myEvaluator) {
	//random_device c_seed_generator;
	//c_rand_engine.seed(c_seed_generator());
}

void COptimizer::vInitialize() {
	GA.Initialize();
}

void COptimizer::vRunIteration() {
	GA.RunIteration();
}