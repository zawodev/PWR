#include "Evaluator.hpp"
#include "Optimizer.hpp"
#include "ProblemLoader.hpp"
#include <iostream>

using namespace LcVRPContest;

void StartOptimization(
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
	cout << "final best fitness: " << best_fitness
		<< ", generations: " << max_generations
		<< ", population: " << population_size
		<< ", Pc: " << crossover_probability
		<< ", Pm: " << mutation_probability << endl;
}

int main() {
	const string folder_name = "Vrp-Set-D";
	const string instance_name = "ORTEC-n323-k21";
	const int max_generations = 400;
	const int population_size = 100;
	const bool use_random_permutation = false;

	cout << "Run 1: high crossover, low mutation" << endl;
	StartOptimization(
        folder_name, 
        instance_name, 
        max_generations, 
        population_size,
		0.9, 
        0.01, 
        use_random_permutation
    );

	cout << "\nRun 2: medium crossover, medium mutation" << endl;
	StartOptimization(
		folder_name, 
        instance_name, 
        max_generations, 
        population_size,
		0.7, 
        0.05, 
        use_random_permutation
    );

	cout << "\nRun 3: low crossover, high mutation" << endl;
	StartOptimization(
		folder_name, 
        instance_name, 
        max_generations, 
        population_size,
		0.4, 
        0.15, 
        use_random_permutation
    );

	return 0;
}