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
	cout << "Before GA Init" << endl;
	GA.Initialize();
	cout << "After GA Init" << endl;
}

void COptimizer::vRunIteration() {
	cout << "Before GA Iter" << endl;
	GA.RunIteration();
	cout << "After GA Iter" << endl;
}