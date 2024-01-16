#include "GeneticAlgorithmTwo.h"

#include <cfloat>
#include <iostream>
#include <windows.h>

#include <fstream>
#include <sstream>
#include <algorithm>
#include <vector>
#include <string.h>


using namespace std;


//USTAWIENIA SYMULACJI

//populacja
static int generationAmount = 1; //ilosc generacji
static int currentGenerationSize = 1024;  //aktualna liczba osobnikow w populacji

//vipy
static int vipAmount = 64; //ilosc najlepszych osobnikow ktorych przepisujemy bez zmian
static vector<int> vipAmountStates = { 0, 0, 0, 1, 1, 16, 64 }; //mozliwe wartosci vipAmount

//mutacja
static double mutationChance = .150; //szansa na mutacje w danym osobniku
static vector<double> mutationChanceStates = { .050, .150, .900 }; //mozliwe wartosci mutationChance

static double minMutationAmount = .001; //minimalna wartosc mutacji w lepszym osobniku
static double maxMutationAmount = .004; //maxymalna wartosc mutacji w gorszym osobniku

//krzy¿owanie
static double crossoverPercent = .450; //procent osobnikow ktore krzyzujemy
static vector<double> crossoverPercentStates = { .300, .450, .600, .800, .900 }; //mozliwe wartosci crossoverPercent

//scoutowanie
static double scoutPercent = .000; //procent osobnikow ktore tworzymy losowo
static vector<double> scoutPercentStates = { .000, .001, .010, .100 }; //mozliwe wartosci scoutPercent

//usuwanie osobnikow
static double removeWorstOrRandomChance = 0.0; //[0.0, 1.0] usun najgorsze osobniki [0.0] lub losowe [1.0]
static vector<double> removeWorstOrRandomChanceStates = { 0.0, 0.05, 0.15, 0.35 }; //mozliwe wartosci removeWorstOrRandomChance

//zmiana strategii
bool changeStrategyBool = true; //czy zmienic strategie
int changeStrategyTreshhold = 25; //co ile nieskutecznych iteracji zmienic strategie
int changeStrategyCounter = 0; //licznik do czasu zmiany strategii

//USTAWIENIA SYMULACJI



static bool loadFromFileBool = false; //czy wczytywac populacje z pliku
static double pbTreshhold = 0.00064; //jezeli najlepszy osobnik ma taka wartosc to zapisz populacje do pliku i zakoncz symulacje
static double treshholdChange = 0.00001; //co ile zwiekszac pbTreshhold


vector<pair<double, vector<int>>> generation; //populacja
vector<pair<double, vector<int>>> vips; //najlepsze osobniki z poprzedniej generacji


void GeneticAlgorithmTwo::saveGenerationToFile(const std::vector<std::pair<double, std::vector<int>>>& generation, const std::string& filename) {
	std::ofstream outFile(filename);
	evaluateGeneration(generation); //just to be safe

	if (outFile.is_open()) {
		for (const auto& entry : generation) {
			outFile << entry.first << ' ';

			for (const auto& value : entry.second) {
				outFile << value << ' ';
			}

			outFile << '\n';
		}

		outFile.close();
		std::cout << "Zapisano do pliku: " << filename << std::endl;
	}
	else {
		std::cerr << "B³¹d podczas otwierania pliku do zapisu.\n";
	}
}
std::vector<std::pair<double, std::vector<int>>> GeneticAlgorithmTwo::loadGenerationFromFile(const std::string& filename) {
	std::vector<std::pair<double, std::vector<int>>> loadedGeneration;

	std::ifstream inFile(filename);

	if (inFile.is_open()) {
		std::string line;

		while (std::getline(inFile, line)) {
			std::istringstream iss(line);

			double first;
			if (!(iss >> first)) {
				std::cerr << "B³¹d podczas wczytywania danych z pliku.\n";
				return loadedGeneration;
			}

			std::vector<int> second;
			int value;

			while (iss >> value) {
				second.push_back(value);
			}
			pair<double, vector<int>> specimen;
			specimen.second = second;
			evaluateSpecimen(specimen); //just to be safe calculate again

			loadedGeneration.push_back(specimen);
		}

		inFile.close();
		std::cout << "Wczytano z pliku: " << filename << std::endl;
	}
	else {
		std::cerr << "B³¹d podczas otwierania pliku do odczytu.\n";
	}

	return loadedGeneration;
}

void GeneticAlgorithmTwo::generateRandomGeneration(std::vector<std::pair<double, std::vector<int>>>& generation) {
	generation.clear();
	generation.reserve(currentGenerationSize);

	for (int i = 0; i < currentGenerationSize; ++i) {
		generation.push_back(generateRandomSpecimen());
	}
}
void GeneticAlgorithmTwo::printSpecimenFitness(string pretext, double fitness, int color) {
	SetConsoleTextAttribute(hConsole, color);
	std::cout << pretext << fitness << std::endl;
	SetConsoleTextAttribute(hConsole, 7); //przywroc bia³y kolor
}
void GeneticAlgorithmTwo::updateBestSpecimen(std::vector<std::pair<double, std::vector<int>>>& gen) {
	//sprawdzamy czy najlepsze rozwiazanie z tej generacji jest lepsze od najlepszego z dotychczasowych rozwiazan
	pair<double, vector<int>> bestSpecimen = gen[0];
	if (bestSpecimen.first > globalBestFitness) {
		//changeStrategyCounter = 250; //jesli strategia zadziala potrzymaj ciut dluzej i daj jej cos wymyslic
		changeStrategyCounter = 0;

		globalBestGenes = bestSpecimen.second;
		globalBestFitness = bestSpecimen.first;
		localBestFitness = bestSpecimen.first;

		//ustaw kolor na zielony
		printSpecimenFitness("new global best: ", globalBestFitness, 10);
	}
	else if (bestSpecimen.first > localBestFitness) {
		//changeStrategyCounter = 250; //jesli strategia zadziala potrzymaj ciut dluzej i daj jej cos wymyslic
		changeStrategyCounter = 0;

		localBestFitness = bestSpecimen.first;

		//ustaw kolor na zolty
		printSpecimenFitness("new local best: ", localBestFitness, 14);
	}
	else {
		//ustaw kolor na czerwony
		printSpecimenFitness("no new best: ", gen[1].first, 12);

		changeStrategyCounter++;
		if (changeStrategyBool && changeStrategyCounter >= changeStrategyTreshhold) {
			//changeStrategyCounter = 100; //jesli nowa strategia szybko nie zadziala to zmien strategie
			changeStrategyCounter = 0;
			changeStrategy(gen);
		}
	}
	//ustaw kolor na bialy
	SetConsoleTextAttribute(hConsole, 7);
}
template<typename T> void GeneticAlgorithmTwo::printSettingsVariable(T& variable, vector<T>& states, const string& name) {
	std::cout << name << ": {" << states[0];
	for (int i = 1; i < states.size(); i++) std::cout << ", " << states[i];
	std::cout << "} = " << variable << std::endl;
}
void GeneticAlgorithmTwo::changeStrategy(std::vector<std::pair<double, std::vector<int>>>& gen) {

	//ustaw kolor na niebieski
	SetConsoleTextAttribute(hConsole, 9);
	std::cout << std::endl << "----- new strategy -----" << std::endl;

	if (true) { //strategia 1 - ma³a wariacja na zmiennych kontroluj¹cych populacje
		//szansa na mutacje
		mutationChance = mutationChanceStates[c_rand_engine() % mutationChanceStates.size()];
		printSettingsVariable(mutationChance, mutationChanceStates, "mutationChance");

		//procent krzyzowania
		crossoverPercent = crossoverPercentStates[c_rand_engine() % crossoverPercentStates.size()];
		printSettingsVariable(crossoverPercent, crossoverPercentStates, "crossoverPercent");

		//procent scoutowania
		scoutPercent = scoutPercentStates[c_rand_engine() % scoutPercentStates.size()];
		printSettingsVariable(scoutPercent, scoutPercentStates, "scoutPercent");

		//ilosc najlepszych osobnikow ktore przepisujemy bez zmian
		vipAmount = vipAmountStates[c_rand_engine() % vipAmountStates.size()];
		printSettingsVariable(vipAmount, vipAmountStates, "vipAmount");

		//usun najgorsze osobniki lub losowe
		removeWorstOrRandomChance = removeWorstOrRandomChanceStates[c_rand_engine() % removeWorstOrRandomChanceStates.size()];
		printSettingsVariable(removeWorstOrRandomChance, removeWorstOrRandomChanceStates, "removeWorstOrRandomChance");
	}
	if (false) { //strategia 2 - nowa populacja vipów
		int strategy = c_rand_engine() % 5;
		if (strategy == 0 || vips.size() >= 16) {
			if (vips.size() < 16) vips.push_back(gen[0]);
			else vips[c_rand_engine() % vips.size()] = gen[0];

			copyGeneration(gen, vips);
			resizeGeneration(gen, currentGenerationSize);
			localBestFitness = -DBL_MAX;

			//ustaw kolor na cyan
			//SetConsoleTextAttribute(hConsole, 11);
			// << "started new generation with vips, there are now: " << vips.size() << " vips" << endl;
		}
		else {
			if (vips.size() < 16) vips.push_back(gen[0]);
			else vips[c_rand_engine() % vips.size()] = gen[0];

			generateRandomGeneration(gen);
			localBestFitness = -DBL_MAX;

			//ustaw kolor na cyan
			//SetConsoleTextAttribute(hConsole, 11);
			//std::cout << std::endl << "----- new strategy -----" << std::endl << "started new random generation, there are now: " << vips.size() << " vips" << std::endl;
		}
		saveGenerationToFile(vips, "vips.txt");
	}

	//ustaw kolor na zielony
	printSpecimenFitness("current global best: ", globalBestFitness, 10);
	std::cout << std::endl;

	//ustaw kolor na bialy
	SetConsoleTextAttribute(hConsole, 7);
}
void GeneticAlgorithmTwo::copyGeneration(std::vector<std::pair<double, std::vector<int>>>& outputGeneration, std::vector<std::pair<double, std::vector<int>>>& inputGeneration) {
	outputGeneration.clear();
	outputGeneration.reserve(inputGeneration.size());

	for (int i = 0; i < inputGeneration.size(); ++i) {
		outputGeneration.push_back(inputGeneration[i]);
	}
}
void GeneticAlgorithmTwo::Initialize() {
	//ustawiamy najlepsze rozwiazanie na najgorsze mozliwe
	globalBestFitness = -DBL_MAX;
	globalBestGenes.clear();

	//tworzymy populacje
	if (loadFromFileBool) {
		generation = loadGenerationFromFile("generation.txt");
		resizeGeneration(generation, currentGenerationSize);
	}
	else {
		generateRandomGeneration(generation);
	}

	/*for (int i = 0; i < generationSize; i++) {
		cout << generation[i].first << endl;
	}*/
	std::cout << "-------------------" << std::endl;
}
void GeneticAlgorithmTwo::RunIteration() {
	//sortujemy rozwiazania od najlepszego do najgorszego
	quicksort(generation, 0, generation.size() - 1);

	//sprawdzamy czy najlepsze rozwiazanie z tej generacji jest lepsze od najlepszego z dotychczasowych rozwiazan
	updateBestSpecimen(generation);

	//zapisz wyniki do pliku
	if (globalBestFitness > pbTreshhold) {
		saveGenerationToFile(generation, to_string(generation[0].first) + ".txt"); //or "generation.txt"
		pbTreshhold += treshholdChange;
	}

	CalculateNextGeneration(generation);
}
void GeneticAlgorithmTwo::CalculateNextGeneration(vector<pair<double, vector<int>>>& generation) {

	//usuwanie rozwiazan zeby zrobic miejsce na krzyzowanie i scoutowanie
	int crossoverSize = (int)(currentGenerationSize * crossoverPercent);
	int scoutSize = (int)(currentGenerationSize * scoutPercent);
	int removalSize = crossoverSize + scoutSize;
	currentGenerationSize -= removalSize;

	for (int i = 0; i < removalSize; i++) {
		//usun przypadkowe rozwiazanie
		if (c_rand_engine() % 1000 < removeWorstOrRandomChance * 1000) generation.erase(generation.begin() + (c_rand_engine() % generation.size()));
		//usun najgorsze rozwiazanie
		else generation.pop_back();
	}

	//dodajemy losowych scoutow
	for (int i = 0; i < scoutSize; i++) {
		generation.push_back(generateRandomSpecimen());
	}

	//tworzymy nowe rozwi¹zania krzy¿uj¹c najlepsze z poprzedniej generacji
	for (int i = 0; i < crossoverSize; i++) {
		pair<double, vector<int>> specimen;
		pair<double, vector<int>> parent1 = generation[c_rand_engine() % currentGenerationSize];
		pair<double, vector<int>> parent2 = generation[c_rand_engine() % currentGenerationSize]; //lub generation.size() jesli chcesz zeby dzieci tez sie rozmna¿a³y od razu
		for (int j = 0; j < parent1.second.size(); j++) {
			if (c_rand_engine() % 2 == 0) specimen.second.push_back(parent1.second[j]);
			else specimen.second.push_back(parent2.second[j]);
		}
		evaluateSpecimen(specimen);
		generation.push_back(specimen);
	}

	currentGenerationSize += removalSize;

	//przepuszczamy najlepsze osobniki z poprzedniej generacji bez zmian
	/*
	for (int i = 0; i < vipAmount; i++) {
		generation.pop_back();
	}
	for (int i = 0; i < vipAmount; i++) {
		generation.push_back(generation[i]);
	}
	*/

	//mutujemy wszystkie nowe rozwiazania
	for (int i = vipAmount; i < currentGenerationSize; i++) {
		if (c_rand_engine() % 1000 < mutationChance * 1000) {
			pair<double, vector<int>> specimen = generation[i];
			double specimenMutationAmount = minMutationAmount + ((double(i) / double(currentGenerationSize)) * (maxMutationAmount - minMutationAmount));
			for (int j = 0; j < specimen.second.size(); j++) {
				if (c_rand_engine() % 1000 < specimenMutationAmount * 1000) {
					specimen.second[j] = lRand(c_evaluator.iGetNumberOfValues(j));
				}
			}
			evaluateSpecimen(specimen);
			generation[i] = specimen;
		}
	}
}
void GeneticAlgorithmTwo::evaluateSpecimen(pair<double, vector<int>>& osobnik) {
	osobnik.first = c_evaluator.dEvaluate(&osobnik.second);
}
void GeneticAlgorithmTwo::evaluateGeneration(vector<pair<double, vector<int>>> generation) {
	for (int i = 0; i < generation.size(); i++) {
		evaluateSpecimen(generation[i]);
	}
}

void GeneticAlgorithmTwo::quicksort(vector<pair<double, vector<int>>>& arr, int left, int right) {
	int i = left, j = right;
	pair<double, vector<int>> tmp;
	pair<double, vector<int>> pivot = arr[(left + right) / 2];

	while (i <= j) {
		while (arr[i].first > pivot.first) i++;
		while (arr[j].first < pivot.first) j--;
		if (i <= j) {
			tmp = arr[i];
			arr[i] = arr[j];
			arr[j] = tmp;
			i++;
			j--;
		}
	};

	if (left < j) quicksort(arr, left, j);
	if (i < right) quicksort(arr, i, right);
}
void GeneticAlgorithmTwo::v_fill_randomly(vector<int>& vSolution) {
	vSolution.resize((size_t)c_evaluator.iGetNumberOfBits());
	for (int ii = 0; ii < vSolution.size(); ii++) {
		vSolution.at(ii) = lRand(c_evaluator.iGetNumberOfValues(ii));
	}
}
pair<double, vector<int>> GeneticAlgorithmTwo::generateRandomSpecimen() {
	pair<double, vector<int>> specimen;
	v_fill_randomly(specimen.second);
	evaluateSpecimen(specimen);
	return specimen;
}
void GeneticAlgorithmTwo::resizeGeneration(vector<pair<double, vector<int>>>& gen, int genSize) {
	if (genSize > gen.size()) {
		int diff = genSize - gen.size();
		for (int i = 0; i < diff; i++) {
			gen.push_back(generateRandomSpecimen());
		}
	}
	else {
		gen.resize(genSize);
	}
}