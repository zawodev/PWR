#pragma once

#include "Evaluator.hpp"

#include <random>
#include <vector>

using namespace std;

namespace LcVRPContest {
	class Optimizer {
	public:
		Optimizer(
			Evaluator& evaluator,
			int population_size,
			double crossover_probability,
			double mutation_probability);

		void Initialize();
		void RunIteration();

		vector<int>* GetCurrentBest() { return &current_best_; }
		double GetCurrentBestFitness() const { return current_best_fitness_; }

	private:
		Evaluator& evaluator_;
		int population_size_;
		double crossover_probability_;
		double mutation_probability_;

		vector<vector<int>> population_;
		vector<double> population_fitness_;
		vector<int> current_best_;
		double current_best_fitness_;

		mt19937 rng_;

		void InitRandomIndividual(vector<int>& individual);
		double CalculateAdaptation(double fitness) const;
		size_t SelectByRoulette();
		void EvaluatePopulation();
		vector<int> Crossover(
			const vector<int>& first_parent,
			const vector<int>& second_parent);
		void Mutate(vector<int>& individual);
	};
}
