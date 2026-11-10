#include "Optimizer3.hpp"

#include <algorithm>
#include <cmath>
#include <limits>

using namespace LcVRPContest;

Optimizer3::Optimizer3(
	Evaluator& evaluator,
	int ant_count,
	double evaporation,
	double distance_weight)
	: evaluator_(evaluator),
	  ant_count_(std::max(1, ant_count)),
	  evaporation_(std::clamp(evaporation, 0.01, 0.99)),
	  distance_weight_(std::max(0.0, distance_weight)),
	  current_best_fitness_(std::numeric_limits<double>::max()),
	  reference_cost_(0.0),
	  rng_(std::random_device{}()) {}

void Optimizer3::Initialize() {
	int dimension = evaluator_.GetProblemData().GetDimension(); //liczba klientów 
	pheromone_.assign(dimension, std::vector<double>(dimension, 1.0));
	current_best_.clear();
	current_best_fitness_ = std::numeric_limits<double>::max();
	reference_cost_ = 0.0;
}

std::vector<int> Optimizer3::BuildSolution() {
	const ProblemData& data = evaluator_.GetProblemData();
	const std::vector<int>& permutation = data.GetPermutation();
	const std::vector<std::vector<double>>& distances = data.GetEdgeWeights();
	int depot = data.GetDepot() - 1;
	int group_count = evaluator_.GetNumGroups();
	std::vector<int> solution(evaluator_.GetSolutionSize());
	std::vector<int> route_tail(group_count, depot); // dla każdego pojazdu jest to ostatni dodany klient

	// mrówka przechodzi przez wszystkich klientów po kolei i wybiera ruletką najlepszy pojazd do obsługi siebie
	for (int customer_id : permutation) {
		int customer = customer_id - 1;
		int solution_index = customer_id - 2;
		std::vector<int> groups;
		std::vector<double> weights;
		std::vector<int> empty_groups;

		for (int group = evaluator_.GetLowerBound(); group <= evaluator_.GetUpperBound(); ++group) {
			if (route_tail[group] == depot) { //pojazd obecnie pusty jeszcze nie wyruszył
				empty_groups.push_back(group);
				continue;
			}
			int last = route_tail[group];
			double distance = std::max(distances[last][customer], 1e-9);
			groups.push_back(group);
            //normalnie jest tak że alpha dla wpływu pheromone i beta dla odległości, ale w tym przypadku zawsze alpha=1 
            //a beta=distance_weight
            //więc: a=1, b=1 to po równe proporcje
			weights.push_back(
				pheromone_[last][customer] * 
				std::pow(1.0 / distance, distance_weight_));
		}

		// puste pojazdy jest każdy taki sam wsm więc dodajemy je tylko raz bo nie ma znaczenia który
		if (!empty_groups.empty()) {
			double distance = std::max(distances[depot][customer], 1e-9);
			groups.push_back(empty_groups.front());
			weights.push_back(
				pheromone_[depot][customer] *
				std::pow(1.0 / distance, distance_weight_));
		}

        // ruletka
		double total_weight = 0.0;
		for (double weight : weights) {
			total_weight += weight;
		}
		std::uniform_real_distribution<double> choice(0.0, total_weight);
		double selected = choice(rng_);
		int selected_group = groups.back();
		double accumulated = 0.0;
		for (size_t option = 0; option < groups.size(); ++option) {
			accumulated += weights[option];
			if (selected <= accumulated) {
				selected_group = groups[option];
				break;
			}
		}

		if (route_tail[selected_group] == depot &&
			empty_groups.size() > 1) {
			std::uniform_int_distribution<size_t> empty_choice(0, empty_groups.size() - 1);
			selected_group = empty_groups[empty_choice(rng_)];
		}
		solution[solution_index] = selected_group;
		route_tail[selected_group] = customer;
	}
	return solution;
}

void Optimizer3::RunIteration() {
	const ProblemData& data = evaluator_.GetProblemData();
	int depot = data.GetDepot() - 1;
	std::vector<std::pair<double, std::vector<int>>> ants;

	for (int ant = 0; ant < ant_count_; ++ant) {
		std::vector<int> solution = BuildSolution();
		double fitness = evaluator_.Evaluate(solution);
		if (fitness < 0.0) {
			continue;
		}
		if (fitness < current_best_fitness_) {
			current_best_ = solution;
			current_best_fitness_ = fitness;
		}
		ants.push_back({fitness, solution});
	}
	if (ants.empty()) {
		return;
	}
	if (reference_cost_ == 0.0) { // skala depozytu ustawiana tylko raz
		reference_cost_ = ants.front().first;
	}

	// evaporation ogranicza wpływ starych rozwiązań
	for (auto& row : pheromone_) {
		for (double& value : row) {
			value = std::max(0.01, value * (1.0 - evaporation_));
		}
	}

	// depozyt, czyli każda mrówka zostawia ślad na krawędziach swojego rozwiązania,
	// im lepszy fitness miała mrówka, tym mocniejszy ślad
	for (const auto& [fitness, solution] : ants) {
		double deposit = reference_cost_ / fitness / ant_count_;
		std::vector<int> route_tail(evaluator_.GetNumGroups(), depot);
		for (int customer_id : data.GetPermutation()) {
			int customer = customer_id - 1;
			int group = solution[customer_id - 2];
			pheromone_[route_tail[group]][customer] += deposit;
			route_tail[group] = customer;
		}
	}

	for (auto& row : pheromone_) {
		for (double& value : row) {
			value = std::clamp(value, 0.01, 10.0);
		}
	}
}
