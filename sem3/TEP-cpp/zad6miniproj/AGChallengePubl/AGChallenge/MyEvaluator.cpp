#include "MyEvaluator.h"

using namespace std;

MyEvaluator::MyEvaluator(CLFLnetEvaluator& cEvaluator) : evaluator(cEvaluator) {
	random_device c_seed_generator;
	c_rand_engine.seed(c_seed_generator());

	cout << "MyEvaluator created" << endl;
}
