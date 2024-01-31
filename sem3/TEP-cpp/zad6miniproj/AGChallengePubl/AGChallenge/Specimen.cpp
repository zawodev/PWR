#include "MyEvaluator.h"
#include "Specimen.h"
#include "Population.h"
#include "Evaluator.h"

using namespace std;

class Population;

Specimen::Specimen() : myEvaluator() {
	population = nullptr;
	myEvaluator = nullptr;
	
	genes.clear();
	fitness = -DBL_MAX;
	
	cout << "Default Specimen created." << endl;
}

Specimen::Specimen(Population& _population) {
	population = &_population;
	myEvaluator = _population.getEvaluator();
	
	genes.resize((*population).maxValues.size());
	for (int i = 0; i < genes.size(); i++) {
		genes.at(i) = lRand((*population).maxValues.at(i));
	}
	fitness = -DBL_MAX;

	//cout << "Population copy Specimen created" << endl;
}

Specimen::Specimen(MyEvaluator& _myEvaluator) {
	population = nullptr;
	myEvaluator = &_myEvaluator;

	genes.resize((*myEvaluator).iGetNumberOfBits());
	for (int i = 0; i < genes.size(); i++) {
		genes.at(i) = lRand((*myEvaluator).iGetNumberOfValues(i));
	}
	fitness = -DBL_MAX;
	//evaluateFitness();
}
Specimen::Specimen(MyEvaluator& _myEvaluator, vector<int>& newGenes) {
	population = nullptr;
	myEvaluator = &_myEvaluator;

	genes.resize((*myEvaluator).iGetNumberOfBits());
	for (int i = 0; i < genes.size(); i++) {
		genes.at(i) = newGenes.at(i);
	}
	fitness = -DBL_MAX;
	//evaluateFitness();
}

Specimen::Specimen(Population& _population, vector<int>& newGenes) {
	population = &_population;
	myEvaluator = _population.getEvaluator();

	genes.resize((*population).maxValues.size());
	for (int i = 0; i < genes.size(); i++) {
		genes.at(i) = newGenes.at(i);
	}
	fitness = -DBL_MAX;
	//evaluateFitness();
}

Specimen::Specimen(const Specimen& other) : myEvaluator(other.myEvaluator), population(other.population) {
	genes = other.genes;
	fitness = other.fitness;
}

vector<int> Specimen::getGenes() {
	return genes;
}
void Specimen::setGenes(vector<int> _genes) {
	genes = _genes;
}
double Specimen::getFitness() {
	return fitness;
}
void Specimen::setFitness(double _fitness) {
	fitness = _fitness;
}

void Specimen::evaluateFitness() {
	fitness = ((*myEvaluator).dEvaluate(&genes));
}
void Specimen::mutate(double mutationAmount) {
	for (int i = 0; i < genes.size(); i++) {
		if (dRand() < mutationAmount) {
			if (population != nullptr) genes.at(i) = lRand((*population).maxValues.at(i));
			else genes.at(i) = lRand((*myEvaluator).iGetNumberOfValues(i));
		}
	}
	//evaluateFitness();
}
vector<int> Specimen::crossover(Specimen& other) { 
	vector<int> newGenes;
	vector<int> otherGenes = other.getGenes();
	if (population != nullptr) newGenes.resize((*population).maxValues.size());
	else newGenes.resize((*myEvaluator).iGetNumberOfBits());

	for (int i = 0; i < genes.size(); i++) {
		if (iRand() % 2 == 0) newGenes.at(i) = genes.at(i);
		else newGenes.at(i) = otherGenes.at(i);
	}
	return newGenes;
}
Specimen& Specimen::operator=(Specimen& other) {
	if (this != &other) {
		genes = other.genes;
		fitness = other.fitness;
	}
	return *this;
}
