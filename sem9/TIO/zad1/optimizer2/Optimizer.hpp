#pragma once

#include "../Evaluator.hpp"
#include "MyEvaluator.hpp"
#include "Individual.hpp"

#include <vector>
#include <random>
#include <thread>
#include <mutex>
#include <atomic>

using namespace std;

namespace LcVRPContest {
	// size of diversity pool for maintaining diverse solutions
	constexpr int DIVERSITY_POOL_SIZE = 25;

	class Optimizer2 {
	public:
		Optimizer2(Evaluator& evaluator);
		~Optimizer2();

		void Initialize();
		void RunIteration();
		void StopThreads();

		vector<int>* GetCurrentBest() { return &current_best_.genotype; }
		double GetCurrentBestFitness() const { return current_best_.fitness; }

		void SaveIndividualToFile(const Individual& individual, const string& filename);
		void LoadIndividualFromFile(Individual& individual, MyEvaluator& evaluator, const string& filename);

		// diversity pool methods
		Individual GetRandomFromDiversityPool(mt19937& rng);

	private:
		Evaluator& evaluator_;

		Individual current_best_;
		vector<Individual> population_;

		// diversity pool - maintains diverse set of good solutions
		vector<Individual> diversity_pool_;
		mutex diversity_pool_mutex_;

		// thread management
		vector<thread> threads_;
		atomic<bool> stop_flag_{ false };
		mutex best_mutex_;

		const int population_size = 6;

		// thread worker function
		void WorkerThread(int thread_id, MyEvaluator evaluator, unsigned int seed);

		void InitRandomIndividual(Individual& individual, MyEvaluator& evaluator, mt19937& rng);
		void MutateIndividual(Individual& individual, MyEvaluator& evaluator, mt19937& rng);
		void ReassignRouteIndividualOld(Individual& individual, MyEvaluator& evaluator, mt19937& rng);
		void FillEmptyRoute(Individual& individual, MyEvaluator& evaluator, mt19937& rng, int emptyRoute, int heuristicType = 0);
		void RunIndividual(Individual& individual, Individual& local_best, MyEvaluator& evaluator, mt19937& rng);
		bool FihcGeneBased(Individual& individual, MyEvaluator& evaluator, mt19937& rng);
		bool FihcSwapBased(Individual& individual, MyEvaluator& evaluator, mt19937& rng);
		void UpdateBestIndividual(const Individual& individual);
		void UpdateLocalBestIndividual(const Individual& individual, Individual& local_best);
		void EvaluateAndUpdate(Individual& individual, MyEvaluator& evaluator);

		// diversity pool helpers
		int CalculateGenotypeDifference(const vector<int>& genotype1, const vector<int>& genotype2, int numGroups);
		void UpdateDiversityPool(const Individual& individual);
		void PrintIndividual(const Individual& individual) const;
		string FormatIndividual(const Individual& individual) const;
	};
}