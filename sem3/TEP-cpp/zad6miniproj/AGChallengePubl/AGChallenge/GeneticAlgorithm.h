#pragma once

#include "Evaluator.h"
#include "Specimen.h"

#include <iostream>
#include <random>
#include <vector>
#include <fstream>
#include <sstream>
#include <string.h>

using namespace std;

class GeneticAlgorithm {
public:
	GeneticAlgorithm(CLFLnetEvaluator& evaluator, mt19937& randEngine);

	void Initialize();
	void RunIteration();

	vector<int>* GetGlobalBestGenes() { return &globalBestGenes; }
private:
	CLFLnetEvaluator& c_evaluator; //dont change
	mt19937& c_rand_engine; //dont change
	HANDLE hConsole;

	//best specimen ----------------------------------

	vector<int> globalBestGenes; //najlepszy osobnik w calej symulacji
	double globalBestFitness; //najlepszy osobnik w calej symulacji
	//vector<int> localBestGenes; //najlepszy osobnik w obecnej populacji
	double localBestFitness; //najlepszy osobnik w obecnej populacji

	//moje zmienne ----------------------------------

	//populacja
	vector<Specimen> generation; //populacja
	int currentGenerationSize = 1024; //aktualna liczba osobnikow w populacji

	//vipy
	int vipAmount = 1; //ilosc najlepszych osobnikow ktorych przepisujemy bez zmian
	vector<int> vipAmountStates = { 0, 0, 0, 1, 1, 16, 64 }; //mozliwe wartosci vipAmount

	//mutacja
	double mutationChance = .150; //szansa na mutacje w danym osobniku
	vector<double> mutationChanceStates = { .050, .150, .900 }; //mozliwe wartosci mutationChance

	double minMutationAmount = .001; //minimalna wartosc mutacji w lepszym osobniku
	double maxMutationAmount = .004; //maxymalna wartosc mutacji w gorszym osobniku

	//krzy¿owanie
	double crossoverPercent = .450; //procent osobnikow ktore krzyzujemy
	vector<double> crossoverPercentStates = { .300, .450, .600, .800, .900 }; //mozliwe wartosci crossoverPercent

	//scoutowanie (kiepsko siê sprawdza chyba)
	double scoutPercent = .000; //procent osobnikow ktore tworzymy losowo
	vector<double> scoutPercentStates = { .000, .001, .010, .100 }; //mozliwe wartosci scoutPercent

	//usuwanie osobniko (kiepsko siê sprawdza chyba)
	double removeWorstOrRandomChance = 0.00; //[0.0, 1.0] usun najgorsze osobniki [0.0] lub losowe [1.0]
	vector<double> removeWorstOrRandomChanceStates = { 0.0, 0.05, 0.15, 0.35 }; //mozliwe wartosci removeWorstOrRandomChance

	//zmiana strategii
	bool isStrategyChanged = true; //czy zmienic strategie
	int changeStrategyThreshold = 25; //co ile nieskutecznych iteracji zmienic strategie
	int changeStrategyCounter = 0; //licznik do czasu zmiany strategii

	//zapisywanie do pliku
	bool isLoadedFromFile = false; //czy wczytywac populacje z pliku
	double pbThreshold = 0.00064; //jezeli najlepszy osobnik ma taka wartosc to zapisz populacje do pliku i zakoncz symulacje
	double pbThresholdChange = 0.00001; //co ile zwiekszac pbThreshold

	//moje metody ----------------------------------

	void CalculateNextGeneration(); // oblicza nastepna generacje

	void Quicksort(int left, int right); //sortuje populacje od najlepszego osobnika do najgorszego
	void EvaluateGeneration(); //ocenia wszystkie osobniki w populacji

	void GenerateRandomGeneration(); //tworzy losowa populacje
	void ResizeGeneration(int genSize); //zmienia rozmiar populacji

	void SaveBestSpecimen(); //zapisuje najlepszy osobnik z obecnej populacji
	void UpdateStrategy(); //aktualizuje strategie

	void SavePersonalBestGenerationToFile(); //sprawdza czy rekord zosta³ pobity i zapisuje populacje do pliku
	void SaveGenerationToFile(const std::string& filename); //zapisuje populacje do pliku
	void LoadGenerationFromFile(const std::string& filename); //wczytuje populacje z pliku

	void PrintSpecimenFitness(string pretext, double fitness, int color); //wypisuje fitness osobnika
	template<typename T> void PrintSettingsVariable(T& variable, vector<T>& states, const string& name); //wypisuje zmienna i jej mozliwe wartosci
};