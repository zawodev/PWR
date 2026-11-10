#include "Evaluator.hpp"
#include "ProblemLoader.hpp"
#include "optimizer1/Optimizer.hpp"
#include "optimizer2/Optimizer.hpp"
#include "optimizer3/Optimizer3.hpp"

#include <chrono>
#include <fstream>
#include <iomanip>
#include <iostream>

using namespace LcVRPContest;

constexpr double RUN_TIME_SECONDS = 20.0;
const string FOLDER_NAME = "Vrp-Set-A";
const string INSTANCE_NAME = "A-n80-k10";

template <typename OptimizerType>
double RunForTime(OptimizerType& optimizer, double seconds) {
	const auto deadline = chrono::steady_clock::now() + chrono::duration<double>(seconds);
	while (chrono::steady_clock::now() < deadline) {
		optimizer.RunIteration();
	}
	return optimizer.GetCurrentBestFitness();
}

double RunOptimizer1(int population_size, double crossover_probability, double mutation_probability) {
	ProblemLoader loader(FOLDER_NAME, INSTANCE_NAME, true);
	ProblemData data = loader.LoadProblem();
	Evaluator evaluator(data, data.GetNumGroups());
	Optimizer1 optimizer(evaluator, population_size, crossover_probability, mutation_probability);
	optimizer.Initialize();
	return RunForTime(optimizer, RUN_TIME_SECONDS);
}

double RunOptimizer2() {
	ProblemLoader loader(FOLDER_NAME, INSTANCE_NAME, true);
	ProblemData data = loader.LoadProblem();
	Evaluator evaluator(data, data.GetNumGroups());
	Optimizer2 optimizer(evaluator);
	optimizer.Initialize();
	double result = RunForTime(optimizer, RUN_TIME_SECONDS * 3);
	optimizer.StopThreads();
	return result;
}

double RunOptimizer3(double evaporation, double distance_weight) {
	ProblemLoader loader(FOLDER_NAME, INSTANCE_NAME, true);
	ProblemData data = loader.LoadProblem();
	Evaluator evaluator(data, data.GetNumGroups());
	const int ant_count = 20;
	Optimizer3 optimizer(evaluator, ant_count, evaporation, distance_weight);
	optimizer.Initialize();
	return RunForTime(optimizer, RUN_TIME_SECONDS);
}

int main() {
	const int population_size = 100;
	const double crossover_probabilities[] = {0.1, 0.3, 0.5, 0.7, 0.8, 0.9, 1.0};
	const double mutation_probabilities[] = {0.001, 0.005, 0.01, 0.03, 0.075, 0.2, 0.5};
	const double evaporation_rates[] = {0.01, 0.03, 0.1, 0.2, 0.4, 0.7, 0.95};
	const double distance_weights[] = {0.0, 0.25, 0.5, 1.0, 2.0, 4.0, 8.0};

	ofstream results_file("results.txt");
	if (!results_file) {
		cerr << "Nie można otworzyć results.txt\n";
		return 1;
	}
	results_file << "optimizer parameter1 parameter2 run fitness\n";
	results_file << fixed << setprecision(6);

	int run = 0;
	for (double crossover : crossover_probabilities) {
		for (double mutation : mutation_probabilities) {
			++run;
			double fitness = RunOptimizer1(population_size, crossover, mutation);
			results_file << "optimizer1 " << crossover << ' ' << mutation << ' ' << run << ' ' << fitness << '\n';
			cout << "optimizer1 run " << run << ": " << fitness << '\n';
		}
	}

	for (run = 1; run <= 1; ++run) {
		double fitness = RunOptimizer2();
		results_file << "optimizer2 0 0 " << run << ' ' << fitness << '\n';
		cout << "optimizer2 run " << run << ": " << fitness << '\n';
	}

	run = 0;
	for (double evaporation : evaporation_rates) {
		for (double distance_weight : distance_weights) {
			++run;
			double fitness = RunOptimizer3(evaporation, distance_weight);
			results_file << "optimizer3 " << evaporation << ' ' << distance_weight << ' ' << run << ' ' << fitness << '\n';
			cout << "optimizer3 run " << run << ": " << fitness << '\n';
		}
	}

	return 0;
}
