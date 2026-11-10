#include "Evaluator.hpp"
#include "ProblemLoader.hpp"
#include "optimizer0/Optimizer.hpp"
#include "optimizer1/Optimizer.hpp"
#include "optimizer2/Optimizer.hpp"
#include "optimizer3/Optimizer3.hpp"

#include <chrono>
#include <fstream>
#include <iomanip>
#include <iostream>

using namespace LcVRPContest;

constexpr double RUN_TIME_SECONDS = 2.0;
const string FOLDER_NAME = "Vrp-Set-D";
const string INSTANCE_NAME = "ORTEC-n323-k21";

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

double RunOptimizer0() {
	ProblemLoader loader(FOLDER_NAME, INSTANCE_NAME, true);
	ProblemData data = loader.LoadProblem();
	Evaluator evaluator(data, data.GetNumGroups());
	Optimizer0 optimizer(evaluator);
	optimizer.Initialize();
	double result = RunForTime(optimizer, RUN_TIME_SECONDS * 3);
	optimizer.StopThreads();
	return result;
}

double RunOptimizer2(
	SelectionMethod selection,
	CrossoverMethod crossover,
	MutationMethod mutation,
	bool use_inversion,
	bool use_elitism) {
	ProblemLoader loader(FOLDER_NAME, INSTANCE_NAME, true);
	ProblemData data = loader.LoadProblem();
	Evaluator evaluator(data, data.GetNumGroups());
    //cross: 80% (0.8), mutacja: 1% (0.01)
	Optimizer2 optimizer(evaluator, 100, 0.8, 0.01, selection, crossover, mutation, use_inversion, use_elitism);
	optimizer.Initialize();
	return RunForTime(optimizer, RUN_TIME_SECONDS);
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
		cerr << "nie udało się otworzyć pliku pewnie zajęty albo co\n";
		return 1;
	}
	results_file << "optimizer parameter1 parameter2 run fitness\n";
	results_file << fixed << setprecision(6);

	int run = 0;
	double fitness = RunOptimizer0();
	results_file << "optimizer0 0 0 1 " << fitness << '\n';
	cout << "optimizer0 run 1: " << fitness << '\n';

	for (double crossover : crossover_probabilities) {
		for (double mutation : mutation_probabilities) {
			++run;
			fitness = RunOptimizer1(population_size, crossover, mutation);
			results_file << "optimizer1 " << crossover << ' ' << mutation << ' ' << run << ' ' << fitness << '\n';
			cout << "optimizer1 run " << run << ": " << fitness << '\n';
		}
	}

	const SelectionMethod selections[] = {SelectionMethod::Roulette, SelectionMethod::Tournament, SelectionMethod::Rank};
	const CrossoverMethod crossovers[] = {CrossoverMethod::OnePoint, CrossoverMethod::Uniform};
	const MutationMethod mutations[] = {MutationMethod::RandomReset, MutationMethod::Swap};
	run = 0;
	for (SelectionMethod selection : selections) {
		for (bool elitism : {false, true}) {
			for (CrossoverMethod crossover : crossovers) {
				for (MutationMethod mutation : mutations) {
					for (bool inversion : {false, true}) {
						++run;
						fitness = RunOptimizer2(selection, crossover, mutation, inversion, elitism);

						results_file << "optimizer2 "
							<< static_cast<int>(selection) * 2 
                            + static_cast<int>(elitism)
							<< ' ' << static_cast<int>(crossover) * 4
							+ static_cast<int>(mutation) * 2
							+ static_cast<int>(inversion)
							<< ' ' << run << ' ' << fitness << '\n';

						cout << "optimizer2 run " << run << ": " << fitness << '\n';
					}
				}
			}
		}
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
