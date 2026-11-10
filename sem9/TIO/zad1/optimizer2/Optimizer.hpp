#pragma once

#include "../Evaluator.hpp"
#include <random>
#include <vector>

namespace LcVRPContest {
	enum class SelectionMethod { Roulette, Tournament, Rank };
	enum class CrossoverMethod { OnePoint, Uniform };
	enum class MutationMethod { RandomReset, Swap };

	class Optimizer2 {
	public:
		Optimizer2(
			Evaluator& evaluator,
			int population_size,
			double crossover_probability,
			double mutation_probability,
			SelectionMethod selection_method,
			CrossoverMethod crossover_method,
			MutationMethod mutation_method,
			bool use_inversion,
			bool use_elitism);

		void Initialize();
		void RunIteration();

		std::vector<int>* GetCurrentBest() { return &current_best_; }
		double GetCurrentBestFitness() const { return current_best_fitness_; }

	private:
		Evaluator& evaluator_;
		int population_size_;
		double crossover_probability_;
		double mutation_probability_;
		SelectionMethod selection_method_;
		CrossoverMethod crossover_method_;
		MutationMethod mutation_method_;
		bool use_inversion_;
		bool use_elitism_;
		std::vector<std::vector<int>> population_;
		std::vector<double> population_fitness_;
		std::vector<int> current_best_;
		double current_best_fitness_;
		std::mt19937 rng_;

		void InitRandomIndividual(std::vector<int>& individual);
		void EvaluatePopulation();
		size_t SelectParent();
		size_t SelectRoulette();
		size_t SelectTournament();
		size_t SelectRank();
		std::vector<int> Crossover(
			const std::vector<int>& first_parent,
			const std::vector<int>& second_parent);
		void Mutate(std::vector<int>& individual);
		void Invert(std::vector<int>& individual);
		double Adaptation(double fitness) const;
	};
}
