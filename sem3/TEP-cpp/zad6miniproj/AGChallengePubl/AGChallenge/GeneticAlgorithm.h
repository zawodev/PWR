#pragma once

#include "MyEvaluator.h"	
#include "Evaluator.h"
#include "Specimen.h"
#include "Population.h"

#include <iostream>
#include <random>
#include <vector>
#include <fstream>
#include <sstream>
#include <string.h>

#include <thread>
#include <mutex>

using namespace std;

class GeneticAlgorithm {
public:
	GeneticAlgorithm(MyEvaluator& _myEvaluator);

	void Initialize();
	void RunIteration();

	Specimen GetBestSpecimen() { return globalBestSpecimen; }
private:
	MyEvaluator& myEvaluator; //dont change
	HANDLE hConsole;

	//best specimen ----------------------------------

	Specimen globalBestSpecimen; //najlepszy osobnik z calej symulacji

	//moje zmienne ----------------------------------

	const int numThreads = 1; //liczba watkow

	//vector<future<void>> futures;

	vector<Population> populations; //populacje

	//zmiana strategii
	bool isStrategyChanged = true; //czy zmienic strategie
	int mixPopulationTreshhold = 20; //co ile nieskutecznych iteracji miesza populacje

	int noNewGlobalBestCounter = 0; //licznik iteracji bez znalezienia nowego global besta
	int iterationCounter = 0; //licznik iteracji

	//zapisywanie do pliku (w celu testow)
	bool isLoadedFromFile = false; //czy wczytywac populacje z pliku
	double pbThreshold = 0.1; //0.00064; //jezeli najlepszy osobnik ma taka wartosc to zapisz populacje do pliku i zakoncz symulacje
	double pbThresholdChange = 0.00001; //co ile zwiekszac pbThreshold

	//moje metody ----------------------------------

	void SaveBestSpecimen(); //zapisuje najlepszy osobnik z obecnej populacji
	void MixTwoPopulations(Population& population1, Population& population2);
	void SwapSpecimens(Specimen& specimen1, Specimen& specimen2); //zamienia dwa osobniki miejscami)

	//void UpdateStrategy(); //aktualizuje strategie

	void SavePopulationToFile(Population& population, const std::string& populationName);
	void SaveSpecimenToFile(Specimen& specimen, const std::string& filename);
	void LoadPopulationFromFile(Population& population, const std::string& filename); //wczytuje populacje z pliku

	void PrintSpecimenFitness(string pretext, double fitness, int color); //wypisuje fitness osobnika
	void PrintTextInColor(string text, int color); //wypisuje tekst w kolorze
	void PrintLocalBestFitnesses(int globalColor, int localColor, int globalBestIndex); //wypisuje fitness najlepszego osobnika z kazdej populacji
	template<typename T> void PrintSettingsVariable(T& variable, vector<T>& states, const string& name); //wypisuje zmienna i jej mozliwe wartosci
};