#include "Specimen.h"

using namespace std;

Specimen::Specimen(CLFLnetEvaluator& evaluator, mt19937& randEngine) : c_evaluator(evaluator), c_rand_engine(randEngine) {
	genes.resize(c_evaluator.iGetNumberOfBits());
	for (int i = 0; i < genes.size(); i++) {
		genes.at(i) = lRand(c_evaluator.iGetNumberOfValues(i));
	}
	fitness = -DBL_MAX;
	//evaluateFitness();
}
Specimen::Specimen(const Specimen& other) : c_evaluator(other.c_evaluator), c_rand_engine(other.c_rand_engine) {
	genes = other.genes;
	fitness = other.fitness;
}

vector<int> Specimen::getGenes() const {
	return genes;
}
void Specimen::setGenes(vector<int> _genes) {
	genes = _genes;
}
double Specimen::getFitness() const {
	return fitness;
}
void Specimen::setFitness(double _fitness) {
	fitness = _fitness;
}

void Specimen::evaluateFitness() {
	fitness = (c_evaluator.dEvaluate(&genes));
}
void Specimen::mutate(double mutationAmount) {
	for (int i = 0; i < genes.size(); i++) {
		if (c_rand_engine() % 1000 < mutationAmount * 1000) {
			genes.at(i) = lRand(c_evaluator.iGetNumberOfValues(i));
		}
	}
	//evaluateFitness();
}
vector<int> Specimen::crossover(const Specimen& other) {
	vector<int> newGenes; 
	vector<int> otherGenes = other.getGenes();
	newGenes.resize(c_evaluator.iGetNumberOfBits());

	for (int i = 0; i < genes.size(); i++) {
		if (c_rand_engine() % 2 == 0) newGenes.at(i) = genes.at(i);
		else newGenes.at(i) = otherGenes.at(i);
	}
	return newGenes;
}
Specimen& Specimen::operator=(const Specimen& other) {
	if (this != &other) {
		genes = other.genes;
		fitness = other.fitness;
	}
	return *this;
}
