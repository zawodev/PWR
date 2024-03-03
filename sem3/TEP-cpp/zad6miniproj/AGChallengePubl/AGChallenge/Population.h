#pragma once

#include "MyEvaluator.h"
#include "Evaluator.h"

#include <iostream>
#include <random>
#include <vector>
#include <fstream>
#include <sstream>
#include <string.h>

#include <thread>

using namespace std;

class Specimen;
class Population {
public:
	Population(MyEvaluator& _myEvaluator, int populationSize, bool searchForMax);

	void GenerateRandomGeneration(); //tworzy losowa populacje
	void GenerateGenerationFromOther(Population& other); //kopiuje populacje z innej populacji

	void RunIteration();
	
	vector<Specimen>& getPopulation(); //zwraca populacje

	void ResizePopulation();

	Specimen& getLocalBestSpecimen();

	MyEvaluator* getEvaluator() { return &myEvaluator; }
	//mt19937& getRandEngine() { return c_rand_engine; }

	vector<int> maxValues;

	int getPopulationSize() { return populationSize; }
	bool getNoNewLocalBestTreshholdReached() { return noNewLocalBestTreshholdReached; }
	void setNoNewLocalBestTreshholdReached(bool value) { noNewLocalBestTreshholdReached = value; }

private:
	MyEvaluator& myEvaluator; //dont change

	//best specimen ----------------------------------

	Specimen localBestSpecimen; //najlepszy osobnik w obecnej populacji
	int populationSize; //ilosc osobnikow w populacji

	const bool isMainPopulation; //czy to glowna populacja
	bool isSearchingForMax; //czy szukamy maksimum czy minimum

	//moje zmienne ----------------------------------

	int noNewLocalBestCounter = 0;
	const int noNewLocalBestTreshhold = 30;
	bool noNewLocalBestTreshholdReached = false;

	vector<Specimen> population; //populacja

	int vipAmount = 64; //ilosc najlepszych osobnikow ktorych przepisujemy bez zmian
	vector<int> vipAmountStates = { 1, 1, 4, 16 }; //mozliwe wartosci vipAmount

	double mutationChance = .15; //szansa na mutacje w danym osobniku
	vector<double> mutationChanceStates = { .05, .10, .15, .9 }; //mozliwe wartosci mutationChance

	double minMutationAmount = .001; //minimalna wartosc mutacji w lepszym osobniku
	double maxMutationAmount = .004; //maxymalna wartosc mutacji w gorszym osobniku

	double crossoverPercent = .45; //procent osobnikow ktore krzyzujemy
	vector<double> crossoverPercentStates = { .3, .45, .6, .8, .9 }; //mozliwe wartosci crossoverPercent

	//moje metody ----------------------------------

	void SaveBestSpecimen(); //zapisuje najlepszy osobnik z obecnej populacji
	void OnNoNewBestSpecimen(); //wywolywane gdy nie znaleziono nowego najlepszego osobnika

	bool IsNewLocalBestSpecimen(bool isSearchingForMax); //sprawdza czy znaleziono nowego najlepszego osobnika

	void CalculateNextGeneration(); // oblicza nastepna generacje
	void Quicksort(int left, int right); //sortuje populacje od najlepszego osobnika do najgorszego
};