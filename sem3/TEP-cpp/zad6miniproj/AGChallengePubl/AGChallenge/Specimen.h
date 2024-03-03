#pragma once

#include "MyEvaluator.h"
#include "Evaluator.h"

#include <iostream>
#include <random>
#include <random>
#include <vector>
#include <cfloat>
#include <windows.h>

using namespace std;

class Population;
class Specimen {
public:
	//konstruktor
	Specimen();
	Specimen(Population& _population);
	Specimen(MyEvaluator& _myEvaluator);
	Specimen(MyEvaluator& _myEvaluator, vector<int>& newGenes);
	Specimen(MyEvaluator& _myEvaluator, vector<int>& newGenes, double newFitness);
	Specimen(Population& _population, vector<int>& newGenes);
	Specimen(const Specimen& other);

	//geny
	vector<int> getGenes();
	void setGenes(vector<int> genes);

	//fitness
	double getFitness();
	void setFitness(double fitness);
	void evaluateFitness();

	//mutate and crossover
	void mutate(double mutationAmount);
	vector<int> crossover(Specimen& other);

	//operatory
	Specimen& operator= (Specimen& other);

private:
	MyEvaluator* myEvaluator; //dont change
	Population* population;

	vector<int> genes;
	double fitness;
};;