#include "Specimen.h"
#include "Population.h"
#include "Evaluator.h"

using namespace std;

Population::Population(MyEvaluator& _myEvaluator, int _populationSize, bool _searchForMax) : myEvaluator(_myEvaluator), localBestSpecimen(Specimen()) {
	searchForMax = _searchForMax;
	populationSize = _populationSize;

	population.clear();

	maxValues.resize(myEvaluator.iGetNumberOfBits());
	for (int i = 0; i < maxValues.size(); i++) { maxValues.at(i) = myEvaluator.iGetNumberOfValues(i); }

	//CString gowno = evaluator.sGetNetName();
	//c_evaluator.bConfigure("104b00");

	//eval_conf = evalConf;
	//c_evaluator.bConfigure("104b00");
}
void Population::GenerateRandomGeneration() {
	population.clear();
	population.reserve(populationSize);

	for (int i = 0; i < populationSize; ++i) {
		Specimen specimen(myEvaluator);
		//Specimen specimen(*this);
		specimen.evaluateFitness();
		population.push_back(specimen);
	}
	localBestSpecimen = population[0];
}
void Population::RunIteration() {
	//tworzymy nowa generacje

	//c_evaluator = CLFLnetEvaluator();
	//c_evaluator.bConfigure(configurationString);

	CalculateNextGeneration();

	//sortujemy rozwiazania od najlepszego do najgorszego
	Quicksort(0, population.size() - 1);
	if (!searchForMax) reverse(population.begin(), population.end());

	//jesli najlepsze rozwiazanie z tej generacji jest lepsze od najlepszego rozwiazania z poprzedniej generacji to zapisujemy je jako najlepsze rozwiazanie
	if ((searchForMax && population[0].getFitness() > localBestSpecimen.getFitness()) || (!searchForMax && population[0].getFitness() < localBestSpecimen.getFitness())) {
		localBestSpecimen = population[0];
	}
}

vector<Specimen>& Population::getPopulation() {
	return population;
}

void Population::ResizePopulation() { //po³¹cz z generateRandomGeneration
	if (populationSize > population.size()) {
		int diff = populationSize - population.size();
		for (int i = 0; i < diff; i++) {
			Specimen specimen(myEvaluator);
			//Specimen specimen(*this);
			specimen.evaluateFitness();
			population.push_back(specimen);
		}
	}
	else {
		population.erase(population.begin() + populationSize, population.end());
	}
}

Specimen& Population::getLocalBestSpecimen() {
	return localBestSpecimen;
}

void Population::CalculateNextGeneration() {
	//usuwanie rozwiazan zeby zrobic miejsce na krzyzowanie i scoutowanie
	int crossoverSize = (int)(populationSize * crossoverPercent);
	int removalSize = crossoverSize;
	int tempPopulationSize = populationSize - removalSize;

	//START OF TEMP POPULATION SIZE -----------------------------------

	for (int i = 0; i < removalSize; i++) {
		//usun przypadkowe rozwiazanie
		//if (dRand() < removeWorstOrRandomChance) population.erase(population.begin() + (iRand() % population.size()));
		//usun najgorsze rozwiazanie
		population.pop_back();
	}

	//tworzymy nowe rozwi¹zania krzy¿uj¹c najlepsze z poprzedniej generacji
	for (int i = 0; i < crossoverSize; i++) {
		//lub generation.size() jesli chcesz zeby dzieci tez sie rozmna¿a³y od razu
		Specimen& parent1 = population.at(iRand() % tempPopulationSize);
		Specimen& parent2 = population.at(iRand() % tempPopulationSize);
		Specimen child(myEvaluator, parent1.crossover(parent2));
		//Specimen child(*this, parent1.crossover(parent2));
		child.evaluateFitness();
		population.push_back(child);
	}

	//END OF TEMP POPULATION SIZE -----------------------------------

	//mutujemy wszystkie nowe rozwiazania
	for (int i = vipAmount; i < populationSize; i++) {
		if (dRand() < mutationChance) {
			double specimenMutationAmount = minMutationAmount + ((double(i) / double(populationSize)) * (maxMutationAmount - minMutationAmount));
			population[i].mutate(specimenMutationAmount);
			population[i].evaluateFitness();
		}
	}
}

void Population::Quicksort(int left, int right) {
	int i = left, j = right;
	double pivot = population[(left + right) / 2].getFitness();

	while (i <= j) {
		while (population[i].getFitness() > pivot) i++; //> malejaco, < rosnaco
		while (population[j].getFitness() < pivot) j--; //< malejaco, > rosnaco
		if (i <= j) {
			swap(population[i], population[j]);
			i++;
			j--;
		}
	};

	if (left < j) Quicksort(left, j);
	if (i < right) Quicksort(i, right);
}

