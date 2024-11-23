#pragma once

#include "Evaluator.h"
#include <mutex>
#include <random>

using namespace std;

class MyEvaluator {
public:
	MyEvaluator(CLFLnetEvaluator& cEvaluator);
	MyEvaluator(const MyEvaluator& other) : evaluator(other.evaluator), c_rand_engine(other.c_rand_engine) {}

	int iGetNumberOfBits() { 
		//lock_guard<mutex> lock(myMutex);
		return evaluator.iGetNumberOfBits(); 
	}
	double dEvaluate(vector<int>* vGenotype) {
		//lock_guard<mutex> lock(myMutex);
		return evaluator.dEvaluate(vGenotype); 
	}
	int iGetNumberOfValues(int i) {
		//lock_guard<mutex> lock(myMutex);
		return evaluator.iGetNumberOfValues(i);
	}
private:
	CLFLnetEvaluator& evaluator;
	mt19937 c_rand_engine;

	mutex myMutex;
};