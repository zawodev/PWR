#include "Optimizer.hpp"
#include <iostream>
#include <limits>
#include <iomanip>

using namespace LcVRPContest;

Optimizer::Optimizer(Evaluator& evaluator) 
	: evaluator_(evaluator), 
	  rng_(random_device{}()), 
	  current_best_fitness_(numeric_limits<double>::max()) {}

void Optimizer::Initialize() {
	current_best_.clear();
	current_best_.resize(evaluator_.GetSolutionSize());
	InitRandomIndividual(current_best_);
	current_best_fitness_ = evaluator_.Evaluate(current_best_);
}

void Optimizer::RunIteration() {
	vector<int> new_individual(evaluator_.GetSolutionSize());
	InitRandomIndividual(new_individual);
	double new_fitness = evaluator_.Evaluate(new_individual);
		
	if (new_fitness < current_best_fitness_) {
		current_best_ = new_individual;
		current_best_fitness_ = new_fitness;
	}

	PrintIndivual(new_individual, new_fitness);
}

void Optimizer::InitRandomIndividual(vector<int>& individual) {
	uniform_int_distribution<int> dist(evaluator_.GetLowerBound(), evaluator_.GetUpperBound());
	for (size_t i = 0; i < individual.size(); ++i) {
		individual[i] = dist(rng_);
	}
}

void Optimizer::PrintIndivual(vector<int>& individual, double fitness) const {
	vector<int> group_counts(evaluator_.GetNumGroups(), 0);
	for (int group : individual) {
		group_counts[group]++;
	}

	cout << "current fitness: " << fixed << setprecision(2) << fitness << ", groups: [";
	for (size_t i = 0; i < group_counts.size(); ++i) {
		cout << group_counts[i] << (i < group_counts.size() - 1 ? ", " : "");
	}
	cout << "]" << endl;
}