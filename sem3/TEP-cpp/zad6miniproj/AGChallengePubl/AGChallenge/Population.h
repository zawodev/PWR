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
	void RunIteration();

	vector<Specimen>& getPopulation();

	void ResizePopulation();

	Specimen& getLocalBestSpecimen();

	MyEvaluator* getEvaluator() { return &myEvaluator; }
	//mt19937& getRandEngine() { return c_rand_engine; }

	vector<int> maxValues;

	int getPopulationSize() { return populationSize; }

private:
	MyEvaluator& myEvaluator; //dont change

	//best specimen ----------------------------------

	Specimen localBestSpecimen; //najlepszy osobnik w obecnej populacji
	int populationSize; //ilosc osobnikow w populacji
	bool searchForMax; //czy szukamy maksimum czy minimum

	//moje zmienne ----------------------------------

	//bool isLocalBestSpecimenBetter = false; //czy najlepszy osobnik z obecnej populacji jest lepszy od najlepszego osobnika z poprzedniej populacji

	vector<Specimen> population; //populacja

	int vipAmount = 64; //ilosc najlepszych osobnikow ktorych przepisujemy bez zmian
	vector<int> vipAmountStates = { 0, 0, 0, 1, 1, 16, 64 }; //mozliwe wartosci vipAmount

	double mutationChance = .15; //szansa na mutacje w danym osobniku
	vector<double> mutationChanceStates = { .05, .15, .9 }; //mozliwe wartosci mutationChance

	double minMutationAmount = .001; //minimalna wartosc mutacji w lepszym osobniku
	double maxMutationAmount = .004; //maxymalna wartosc mutacji w gorszym osobniku

	double crossoverPercent = .45; //procent osobnikow ktore krzyzujemy
	vector<double> crossoverPercentStates = { .3, .45, .6, .8, .9 }; //mozliwe wartosci crossoverPercent

	double idiotPercent = 0; //procent osobnikow ktore szuka minimum zamiast maksimum
	vector<double> idiotPercentStates = { 0, .001, .01, .1 }; //mozliwe wartosci idiotPercent

	//moje metody ----------------------------------

	void CalculateNextGeneration(); // oblicza nastepna generacje
	void Quicksort(int left, int right); //sortuje populacje od najlepszego osobnika do najgorszego
};