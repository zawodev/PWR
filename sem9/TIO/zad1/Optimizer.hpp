#pragma once

#include "Evaluator.hpp"

#include <vector>
#include <random>

using namespace std;

namespace LcVRPContest {
	class Optimizer {
	public:
		Optimizer(Evaluator& evaluator);
		void Initialize();
		void RunIteration();

		vector<int>* GetCurrentBest() { return &current_best_; }
		double GetCurrentBestFitness() const { return current_best_fitness_; }

	private:
		Evaluator& evaluator_;

		vector<int> current_best_;
		double current_best_fitness_;

		mt19937 rng_;

		void InitRandomIndividual(vector<int>& individual);
		void PrintIndivual(vector<int>& individual, double fitness) const;
	};
}