#include "Optimizer.hpp"

#include <algorithm>
#include <cmath>
#include <iostream>
#include <limits>
#include <utility>

using namespace LcVRPContest;

Optimizer::Optimizer(
	Evaluator& evaluator,
	int population_size,
	double crossover_probability,
	double mutation_probability)
	: evaluator_(evaluator),
	  population_size_(max(2, population_size)),
	  crossover_probability_(clamp(crossover_probability, 0.0, 1.0)),
	  mutation_probability_(clamp(mutation_probability, 0.0, 1.0)),
	  current_best_fitness_(numeric_limits<double>::max()),
	  rng_(random_device{}()) {}

void Optimizer::Initialize() {
	population_.clear();
	population_.resize(population_size_);
	population_fitness_.resize(population_size_);

	for (vector<int>& individual : population_) {
		individual.resize(evaluator_.GetSolutionSize());
		InitRandomIndividual(individual);
	}

	current_best_.clear();
	current_best_fitness_ = numeric_limits<double>::max();
	EvaluatePopulation();
}

void Optimizer::RunIteration() {
	vector<vector<int>> next_population;
	next_population.reserve(population_size_);

	// Elityzm zachowuje najlepszy znaleziony chromosom.
	next_population.push_back(current_best_);

	while (static_cast<int>(next_population.size()) < population_size_) {
		size_t first_parent_index = SelectByRoulette();
		size_t second_parent_index = SelectByRoulette();

		vector<int> child = Crossover(
			population_[first_parent_index],
			population_[second_parent_index]);
		Mutate(child);
		next_population.push_back(move(child));
	}

	population_ = move(next_population);
	EvaluatePopulation();
}

void Optimizer::InitRandomIndividual(vector<int>& individual) {
	uniform_int_distribution<int> group_distribution(
		evaluator_.GetLowerBound(),
		evaluator_.GetUpperBound());

	for (int& gene : individual) {
		gene = group_distribution(rng_);
	}
}

double Optimizer::CalculateAdaptation(double fitness) const {
	if (fitness < 0.0 || !isfinite(fitness)) {
		return 0.0;
	}

	// minimalizacja kosztu -> maksymalizacja przystosowania
	return 1.0 / (1.0 + fitness);
}

size_t Optimizer::SelectByRoulette() {
	double total_adaptation = 0.0;
	for (double fitness : population_fitness_) {
		total_adaptation += CalculateAdaptation(fitness);
	}

	if (total_adaptation <= 0.0) {
		uniform_int_distribution<size_t> distribution(0, population_.size() - 1);
		return distribution(rng_);
	}

	uniform_real_distribution<double> distribution(0.0, total_adaptation);
	double selected_value = distribution(rng_);
	double accumulated_adaptation = 0.0;

	for (size_t i = 0; i < population_fitness_.size(); ++i) {
		accumulated_adaptation += CalculateAdaptation(population_fitness_[i]);
		if (selected_value <= accumulated_adaptation) {
			return i;
		}
	}

	return population_.size() - 1;
}

void Optimizer::EvaluatePopulation() {
	for (size_t i = 0; i < population_.size(); ++i) {
		population_fitness_[i] = evaluator_.Evaluate(population_[i]);
		if (population_fitness_[i] < current_best_fitness_) {
			current_best_ = population_[i];
			current_best_fitness_ = population_fitness_[i];
		}
	}
}

vector<int> Optimizer::Crossover(
	const vector<int>& first_parent,
	const vector<int>& second_parent) {
	vector<int> child = first_parent;
	uniform_real_distribution<double> probability(0.0, 1.0);

	if (first_parent.size() > 1 &&
		probability(rng_) < crossover_probability_) {
		uniform_int_distribution<size_t> point_distribution(1, first_parent.size() - 1);
		size_t crossover_point = point_distribution(rng_);
		copy(
			second_parent.begin() + crossover_point,
			second_parent.end(),
			child.begin() + crossover_point);
	}

	return child;
}

void Optimizer::Mutate(vector<int>& individual) {
	uniform_real_distribution<double> probability(0.0, 1.0);
	uniform_int_distribution<int> group_distribution(
		evaluator_.GetLowerBound(),
		evaluator_.GetUpperBound());

	for (int& gene : individual) {
		if (probability(rng_) < mutation_probability_) {
			gene = group_distribution(rng_);
		}
	}
}
