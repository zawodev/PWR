#pragma once

#include "MyEvaluator.h"
#include "Evaluator.h"

#include <random>
#include <vector>

using namespace std;

class CAlikIndividual;

class GeneticAlgorithm3 {

	friend class CAlikIndividual;

public:

	bool newBest = false;

	int iterationNumber = 0;
	vector<CAlikIndividual*> v_pop;

	GeneticAlgorithm3(MyEvaluator& _myEvaluator) : myEvaluator(_myEvaluator) {
		localBestFitness = -DBL_MAX;
		globalBestFitness = -DBL_MAX;
		globalBestGenes.clear();
		i_genotype_length = 0;

		hConsole = GetStdHandle(STD_OUTPUT_HANDLE);

		cout << "GeneticAlgorithm3 alive" << endl;
	}

	void Initialize();
	void RunIteration();

	vector<int>* GetGlobalBestGenes() { return &globalBestGenes; }

private:

	void vRunIteration(int iIterationNumber);
	void vInitPop();
	void PrintSpecimenFitness(string pretext, double fitness, int color);

	void vSelection();
	void vCrossoverAndMutate();
	void vComputeDistanceMatrix();
	void vComputeDiversityValue();
	void vSortPopulation();
	void vTransplantGenes();
	int i_hamming_distance(vector<int>& v1, vector<int>& v2);
	double d_cluster_distance(vector<int>* v1, vector<int>* v2, vector<vector<int>>* v_distance_matrix);
	void v_compute_genotype_distance_matrix(vector<vector<int>>* v_genotype_distance_matrix);
	void v_sort_by_absolute_value(vector<pair<double, int>>* v);
	vector<pair<double, int>> v_compute_average_sorted_genes(vector<int>* v_cluster);
	vector<vector<pair<int, int>>> v_find_best_transplants_for_clusters(vector<vector<pair<int, int>>>* v_common_genotype, vector<vector<int>>* v_clusters);
	vector<pair<int, int>> v_convert_pdi_to_pii(vector<pair<double, int>>* v_input);
	vector<int> v_convert_pii_to_i(vector<pair<int, int>>* v_input);
	vector<vector<int>> v_build_clusters(vector<vector<int>>* v_distance_matrix, int i_clusters_number);
	vector<vector<pair<int, int>>> v_find_common_genotype(vector<vector<int>>* v_clusters, double d_threshold, int i_max_genes);

	int zawo_population_size = 256;
	float zawo_crossover_percentage = 0.45;
	float zawo_mutation_probability = 0.55;
	float zawo_mutation_amount = 0.002;
	int zawo_iteration_num_in_iteration = 100;
	int zawo_cluster_number = 32;
	float zawo_common_genotype_threshold = 0.5; //to change
	int zawo_common_genotype_max_genes = 20;
	float zawo_diversity_reward_scaler = 0.005; //to change
	int zawo_rule_transplant_genes = 1;

	int i_genotype_length;
	vector<vector<int>> v_genotype_distance_matrix;

	MyEvaluator& myEvaluator;
	HANDLE hConsole;

	//best specimen ----------------------------------

	vector<int> globalBestGenes; //najlepszy osobnik w calej symulacji
	double globalBestFitness; //najlepszy osobnik w calej symulacji
	//vector<int> localBestGenes; //najlepszy osobnik w obecnej populacji
	double localBestFitness; //najlepszy osobnik w obecnej populacji

	//moje zmienne ----------------------------------
};






class CAlikIndividual {
public:
	CAlikIndividual(GeneticAlgorithm3* pcParent);
	CAlikIndividual(const CAlikIndividual& pcOther);
	CAlikIndividual& operator=(const CAlikIndividual& pcOther);
	virtual ~CAlikIndividual();


private:
	GeneticAlgorithm3* pc_parent;

	double d_fitness;
	double d_diversity_fitness;
	double d_diversity_value;

public:
	vector<int>    v_genotype;     // items in knapsack - binary

	vector<double>  v_objectives;    //measure values

	int i_type;						//0 or 1

public:
	void vInitRandom();
	void vFIHC(); //first improvement hill climbing
	vector<pair<int, int>> vGetBestTransplantByFullFIHC(vector<int>* v_genes); //index of genes to F_FIHC
	vector<pair<int, int>> vGetGoodTransplantByPartialRandomFIHC(vector<int>* v_genes, int i_attempts); //index of genes to PR_FIHC

	bool bIsTransplantPossible(vector<pair<int, int>>* v_transplant); //check if transplant is possible
	bool bApplyGeneTransplant(vector<pair<int, int>>* v_transplant); //-1 no change, 0/1 - change

	void vMutate(const float fMutationProbability, const float fMutationAmount);
	void vCrossover(CAlikIndividual* pcParent1, CAlikIndividual* pcParent2);
	void vComputeObjectives();          // function computing

	double dGetFitness();
	double dGetDiversityFitness();

	void vShow();

	void vSetDiversityValue(double dDiversity) { d_diversity_value = dDiversity; };
	void vSetType(int iType) { i_type = iType; };

};//class CIndividual