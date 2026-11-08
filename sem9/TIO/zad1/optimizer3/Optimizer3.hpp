#pragma once

#include "../Evaluator.hpp"
#include <random>
#include <vector>

namespace LcVRPContest {
	class Optimizer3 {
	public:
		Optimizer3(Evaluator& evaluator, int ant_count, double evaporation, double alpha);

		void Initialize();
		void RunIteration();

		std::vector<int>* GetCurrentBest() { return &current_best_; }
		double GetCurrentBestFitness() const { return current_best_fitness_; }

	private:
		Evaluator& evaluator_;
		int ant_count_;
		double evaporation_;
		double alpha_;
		std::vector<std::vector<double>> pheromone_;
		std::vector<int> current_best_;
		double current_best_fitness_;
		std::mt19937 rng_;

		std::vector<int> BuildSolution();
	};
}
