#include "Optimizer.hpp"

#include <algorithm>
#include <cmath>
#include <limits>
#include <utility>

using namespace LcVRPContest;

Optimizer2::Optimizer2(
	Evaluator& evaluator,
	int population_size,
	double crossover_probability,
	double mutation_probability,
	SelectionMethod selection_method,
	CrossoverMethod crossover_method,
	MutationMethod mutation_method,
	bool use_inversion)
	: evaluator_(evaluator),
	  population_size_(std::max(2, population_size)),
	  crossover_probability_(std::clamp(crossover_probability, 0.0, 1.0)),
	  mutation_probability_(std::clamp(mutation_probability, 0.0, 1.0)),
	  selection_method_(selection_method),
	  crossover_method_(crossover_method),
	  mutation_method_(mutation_method),
	  use_inversion_(use_inversion),
	  current_best_fitness_(std::numeric_limits<double>::max()),
	  rng_(std::random_device{}()) {}

void Optimizer2::Initialize() {
	population_.assign(population_size_, {});
	population_fitness_.resize(population_size_);
	for (auto& individual : population_) {
		individual.resize(evaluator_.GetSolutionSize());
		InitRandomIndividual(individual);
	}
	current_best_.clear();
	current_best_fitness_ = std::numeric_limits<double>::max();
	EvaluatePopulation();
}

void Optimizer2::RunIteration() {
	std::vector<std::vector<int>> next_population;
	next_population.reserve(population_size_);
	//next_population.push_back(current_best_); // elityzm

	while (static_cast<int>(next_population.size()) < population_size_) {
		std::vector<int> child = Crossover(population_[SelectParent()], population_[SelectParent()]);
		Mutate(child);
		if (use_inversion_) {
			Invert(child);
		}
		next_population.push_back(std::move(child));
	}

	population_ = std::move(next_population);
	EvaluatePopulation();
}

void Optimizer2::InitRandomIndividual(std::vector<int>& individual) {
	std::uniform_int_distribution<int> group(evaluator_.GetLowerBound(), evaluator_.GetUpperBound());
	for (int& gene : individual) {
		gene = group(rng_);
	}
}

double Optimizer2::Adaptation(double fitness) const {
	return fitness >= 0.0 && std::isfinite(fitness) ? 1.0 / (1.0 + fitness) : 0.0;
}

size_t Optimizer2::SelectParent() {
	switch (selection_method_) {
        case SelectionMethod::Tournament:
            return SelectTournament();
        case SelectionMethod::Rank:
            return SelectRank();
        default:
            return SelectRoulette();
	}
}

size_t Optimizer2::SelectRoulette() {
	double total = 0.0;
	for (double fitness : population_fitness_) {
		total += Adaptation(fitness);
	}
	if (total <= 0.0) {
		std::uniform_int_distribution<size_t> random(0, population_.size() - 1);
		return random(rng_);
	}
	std::uniform_real_distribution<double> choice(0.0, total);
	double selected = choice(rng_);
	for (size_t i = 0; i < population_.size(); ++i) {
		selected -= Adaptation(population_fitness_[i]);
		if (selected <= 0.0) {
			return i;
		}
	}
	return population_.size() - 1;
}

size_t Optimizer2::SelectTournament() {
	std::uniform_int_distribution<size_t> random(0, population_.size() - 1);
	size_t best = random(rng_);
	for (int i = 1; i < 3; ++i) { //tu akurat turniej z trzech
		size_t candidate = random(rng_);
		if (population_fitness_[candidate] < population_fitness_[best]) {
			best = candidate;
		}
	}
	return best;
}

size_t Optimizer2::SelectRank() {
	std::vector<size_t> order(population_.size());
	for (size_t i = 0; i < order.size(); ++i) {
		order[i] = i;
	}
	std::sort(order.begin(), order.end(), [this](size_t first, size_t second) {
		return population_fitness_[first] < population_fitness_[second];
	});
	std::uniform_int_distribution<int> rank(1, population_.size() * (population_.size() + 1) / 2);
	int selected = rank(rng_);
	for (size_t position = 0; position < order.size(); ++position) {
		selected -= static_cast<int>(order.size() - position);
		if (selected <= 0) {
			return order[position];
		}
	}
	return order.back();
}

void Optimizer2::EvaluatePopulation() {
	for (size_t i = 0; i < population_.size(); ++i) {
		population_fitness_[i] = evaluator_.Evaluate(population_[i]);
		if (population_fitness_[i] < current_best_fitness_) {
			current_best_ = population_[i];
			current_best_fitness_ = population_fitness_[i];
		}
	}
}

std::vector<int> Optimizer2::Crossover(const std::vector<int>& first_parent, const std::vector<int>& second_parent) {
	std::vector<int> child = first_parent;
	std::uniform_real_distribution<double> probability(0.0, 1.0);
	if (first_parent.size() < 2 || probability(rng_) >= crossover_probability_) {
		return child;
	}

    //onepoint
	if (crossover_method_ == CrossoverMethod::OnePoint) {
		std::uniform_int_distribution<size_t> point(1, child.size() - 1);
		size_t crossover_point = point(rng_);
		std::copy(second_parent.begin() + crossover_point, second_parent.end(), child.begin() + crossover_point);
		return child;
	}

    //uniform
	for (size_t i = 0; i < child.size(); ++i) {
		if (probability(rng_) < 0.5) {
			child[i] = second_parent[i];
		}
	}
	return child;
}

void Optimizer2::Mutate(std::vector<int>& individual) {
	std::uniform_real_distribution<double> probability(0.0, 1.0);
    //rand gene
	if (mutation_method_ == MutationMethod::RandomReset) {
		std::uniform_int_distribution<int> group(evaluator_.GetLowerBound(), evaluator_.GetUpperBound());
		for (int& gene : individual) {
			if (probability(rng_) < mutation_probability_) {
				gene = group(rng_);
			}
		}
		return;
	}

    //swap
	if (individual.size() > 1 && probability(rng_) < mutation_probability_) {
		std::uniform_int_distribution<size_t> position(0, individual.size() - 1);
		size_t first = position(rng_);
		size_t second = position(rng_);
		std::swap(individual[first], individual[second]);
	}
}

void Optimizer2::Invert(std::vector<int>& individual) {
	if (individual.size() < 2) {
		return;
	}
	std::uniform_real_distribution<double> probability(0.0, 1.0);
	if (probability(rng_) >= mutation_probability_) {
		return;
	}
	std::uniform_int_distribution<size_t> position(0, individual.size() - 1);
	size_t first = position(rng_);
	size_t second = position(rng_);
	if (first > second) {
		std::swap(first, second);
	}
	std::reverse(individual.begin() + first, individual.begin() + second + 1);
}
