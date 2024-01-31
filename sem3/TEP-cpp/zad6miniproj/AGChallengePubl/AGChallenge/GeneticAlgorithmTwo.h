#pragma once

#include "MyEvaluator.h"
#include "Evaluator.h"

#include <random>
#include <vector>

using namespace std;

class GeneticAlgorithmTwo {
public:
	GeneticAlgorithmTwo(MyEvaluator& _myEvaluator) : myEvaluator(_myEvaluator) {
		localBestFitness = -DBL_MAX;
		globalBestFitness = -DBL_MAX;
		globalBestGenes.clear();

		hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
	}

	void Initialize();
	void RunIteration();
	void CalculateNextGeneration(vector<pair<double, vector<int>>>& generation);

	vector<int>* GetGlobalBestGenes() { return &globalBestGenes; }

private:
	MyEvaluator& myEvaluator;
	HANDLE hConsole;

	//best specimen ----------------------------------

	vector<int> globalBestGenes; //najlepszy osobnik w calej symulacji
	double globalBestFitness; //najlepszy osobnik w calej symulacji
	//vector<int> localBestGenes; //najlepszy osobnik w obecnej populacji
	double localBestFitness; //najlepszy osobnik w obecnej populacji

	//moje zmienne ----------------------------------

	pair<double, vector<int>> generateRandomSpecimen();

	void quicksort(vector<pair<double, vector<int>>>& generation, int left, int right);
	void evaluateSpecimen(pair<double, vector<int>>& osobnik);
	void evaluateGeneration(vector<pair<double, vector<int>>> generation);

	void resizeGeneration(vector<pair<double, vector<int>>>& gen, int genSize);

	void saveGenerationToFile(const std::vector<std::pair<double, std::vector<int>>>& generation, const std::string& filename);
	std::vector<std::pair<double, std::vector<int>>> loadGenerationFromFile(const std::string& filename);

	void generateRandomGeneration(std::vector<std::pair<double, std::vector<int>>>& generation);
	void updateBestSpecimen(std::vector<std::pair<double, std::vector<int>>>& generation);
	void changeStrategy(std::vector<std::pair<double, std::vector<int>>>& generation);

	void copyGeneration(std::vector<std::pair<double, std::vector<int>>>& outputGeneration, std::vector<std::pair<double, std::vector<int>>>& inputGeneration);
	void printSpecimenFitness(string pretext, double fitness, int color);

	void v_fill_randomly(vector<int>& vSolution);
	template<typename T> void printSettingsVariable(T& variable, vector<T>& states, const string& name);
};