#include "Evaluator.hpp"
#include "Optimizer.hpp"
#include "ProblemLoader.hpp"
#include <fstream>
#include <iomanip>
#include <iostream>

using namespace LcVRPContest;

double StartOptimization(
	const string& folder_name,
	const string& instance_name,
	int max_generations,
	int population_size,
	double crossover_probability,
	double mutation_probability,
	bool use_random_permutation = true) {
	ProblemLoader problem_loader(folder_name, instance_name, use_random_permutation);
	ProblemData problem_data = problem_loader.LoadProblem();

	int num_groups = problem_data.GetNumGroups();
	Evaluator evaluator(problem_data, num_groups);
	Optimizer optimizer(
		evaluator,
		population_size,
		crossover_probability,
		mutation_probability);

	optimizer.Initialize();

	for (int i = 0; i < max_generations; ++i) {
		optimizer.RunIteration();
	}

	vector<int>* best_solution = optimizer.GetCurrentBest();
	double best_fitness = evaluator.Evaluate(*best_solution);
	return best_fitness;
}

int main() {
	const string folder_name = "Vrp-Set-D";
	const string instance_name = "ORTEC-n323-k21";
	const int max_generations = 400;
	const int population_size = 100;
	const bool use_random_permutation = true;
	const double crossover_probabilities[] = {0.9, 0.7, 0.4};
	const double mutation_probabilities[] = {0.01, 0.05, 0.15};

	ofstream results_file("results.txt");
	results_file << "Pc Pm fitness\n";
	results_file << fixed << setprecision(6);

	for (double crossover_probability : crossover_probabilities) {
		for (double mutation_probability : mutation_probabilities) {
			double best_fitness = StartOptimization(
				folder_name,
				instance_name,
				max_generations,
				population_size,
				crossover_probability,
				mutation_probability,
				use_random_permutation);

			results_file << crossover_probability << ' '
				<< mutation_probability << ' '
				<< best_fitness << '\n';
			cout << "Pc: " << crossover_probability
				<< ", Pm: " << mutation_probability
				<< ", best fitness: " << best_fitness << endl;
		}
	}

	return 0;
}