#include "Optimizer3.hpp"

#include <algorithm>
#include <cmath>
#include <limits>

using namespace LcVRPContest;

Optimizer3::Optimizer3(Evaluator& evaluator, int ant_count, double evaporation, double alpha)
	: evaluator_(evaluator),
	  ant_count_(std::max(1, ant_count)),
	  evaporation_(std::clamp(evaporation, 0.01, 0.99)),
	  alpha_(std::max(0.1, alpha)),
	  current_best_fitness_(std::numeric_limits<double>::max()),
	  rng_(std::random_device{}()) {}

void Optimizer3::Initialize() {
	pheromone_.assign(
		evaluator_.GetSolutionSize(),
		std::vector<double>(evaluator_.GetNumGroups(), 1.0));
	current_best_.clear();
	current_best_fitness_ = std::numeric_limits<double>::max();
}

std::vector<int> Optimizer3::BuildSolution() {
	std::vector<int> solution(evaluator_.GetSolutionSize());
	for (size_t customer = 0; customer < solution.size(); ++customer) {
		double total = 0.0;
		for (double value : pheromone_[customer]) {
			total += std::pow(value, alpha_);
		}

		std::uniform_real_distribution<double> choice(0.0, total);
		double selected = choice(rng_);
		double accumulated = 0.0;
		for (int group = evaluator_.GetLowerBound();
			group <= evaluator_.GetUpperBound(); ++group) {
			accumulated += std::pow(pheromone_[customer][group], alpha_);
			if (selected <= accumulated) {
				solution[customer] = group;
				break;
			}
		}
	}
	return solution;
}

void Optimizer3::RunIteration() {
	std::vector<int> iteration_best;
	double iteration_best_fitness = std::numeric_limits<double>::max();

	for (int ant = 0; ant < ant_count_; ++ant) {
		std::vector<int> solution = BuildSolution();
		double fitness = evaluator_.Evaluate(solution);
		if (fitness >= 0.0 && fitness < iteration_best_fitness) {
			iteration_best = solution;
			iteration_best_fitness = fitness;
		}
		if (fitness >= 0.0 && fitness < current_best_fitness_) {
			current_best_ = solution;
			current_best_fitness_ = fitness;
		}
	}

	for (auto& row : pheromone_) {
		for (double& value : row) {
			value = std::max(0.01, value * (1.0 - evaporation_));
		}
	}

	if (iteration_best.empty()) {
		return;
	}

	double deposit = 1.0 / (1.0 + iteration_best_fitness);
	for (size_t customer = 0; customer < iteration_best.size(); ++customer) {
		pheromone_[customer][iteration_best[customer]] += deposit;
	}
}
