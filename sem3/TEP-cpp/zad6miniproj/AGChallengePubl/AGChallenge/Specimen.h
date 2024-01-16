#pragma once

#include "Evaluator.h"

#include <iostream>
#include <random>
#include <vector>

using namespace std;

class Specimen {
public:
	//konstruktor
	Specimen(CLFLnetEvaluator& evaluator, mt19937& randEngine);
	Specimen(const Specimen& other);

	//geny
	vector<int> getGenes() const;
	void setGenes(vector<int> genes);

	//fitness
	double getFitness() const;
	void setFitness(double fitness);
	void evaluateFitness();

	//mutate and crossover
	void mutate(double mutationAmount);
	vector<int> crossover(const Specimen& other);

	//operatory
	Specimen& operator= (const Specimen& other);

private:
	CLFLnetEvaluator& c_evaluator; //dont change
	mt19937& c_rand_engine; //dont change

	vector<int> genes;
	double fitness;
};;