#include "GeneticAlgorithm.h"

using namespace std;

GeneticAlgorithm::GeneticAlgorithm(CLFLnetEvaluator& evaluator, mt19937& randEngine) : c_evaluator(evaluator), c_rand_engine(randEngine){
	localBestFitness = -DBL_MAX;
	globalBestFitness = -DBL_MAX;
	globalBestGenes.clear();

	hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
}
void GeneticAlgorithm::Initialize() {
	//ustawiamy najlepsze rozwiazanie na najgorsze mozliwe
	localBestFitness = -DBL_MAX;
	globalBestFitness = -DBL_MAX;
	globalBestGenes.clear();

	//tworzymy populacje
	if (isLoadedFromFile) {
		LoadGenerationFromFile("generation.txt");
		ResizeGeneration(currentGenerationSize);
	}
	else {
		GenerateRandomGeneration();
	}

	/*for (int i = 0; i < currentGenerationSize; i++) {
		cout << generation[i].getFitness() << endl;
	}*/
	std::cout << "-------------------" << std::endl;
}

void GeneticAlgorithm::RunIteration() {
	//sortujemy rozwiazania od najlepszego do najgorszego
	Quicksort(0, generation.size() - 1);

	//sprawdzamy czy najlepszy specimen jest lepszy od dotychczasowego najlepszego (globalny i lokalny)
	SaveBestSpecimen();

	//zapisz najlepsza generacje do pliku jesli jest lepsza od poprzedniej
	SavePersonalBestGenerationToFile();

	//tworzymy nowa generacje
	CalculateNextGeneration();
}

void GeneticAlgorithm::CalculateNextGeneration() {
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
		Specimen specimen(c_evaluator, c_rand_engine);
		specimen.evaluateFitness();
		generation.push_back(specimen);
	}
	
	//tworzymy nowe rozwi¹zania krzy¿uj¹c najlepsze z poprzedniej generacji
	for (int i = 0; i < crossoverSize; i++) {
		Specimen child(c_evaluator, c_rand_engine); //lub generation.size() jesli chcesz zeby dzieci tez sie rozmna¿a³y od razu
		child.setGenes(generation[c_rand_engine() % currentGenerationSize].crossover(generation[c_rand_engine() % currentGenerationSize]));
		child.evaluateFitness();
		generation.push_back(child);
	}

	currentGenerationSize += removalSize;

	//przepuszczamy najlepsze osobniki z poprzedniej generacji bez zmian
	/*
	for (int i = 0; i < vipAmount; i++) {
		generation.pop_back();
	}
	for (int i = 0; i < vipAmount; i++) {
		generation.push_back(Specimen(c_evaluator, c_rand_engine));
	}
	*/
	
	//mutujemy wszystkie nowe rozwiazania
	for (int i = vipAmount; i < currentGenerationSize; i++) {
		if (c_rand_engine() % 1000 < mutationChance * 1000) {
			double specimenMutationAmount = minMutationAmount + ((double(i) / double(currentGenerationSize)) * (maxMutationAmount - minMutationAmount));
			generation[i].mutate(specimenMutationAmount);
			generation[i].evaluateFitness();
		}
	}
}

void GeneticAlgorithm::Quicksort(int left, int right) {
	int i = left, j = right;
	double pivot = generation[(left + right) / 2].getFitness();

	while (i <= j) {
		while (generation[i].getFitness() > pivot) i++; //> malejaco, < rosnaco
		while (generation[j].getFitness() < pivot) j--; //< malejaco, > rosnaco
		if (i <= j) {
			swap(generation[i], generation[j]);
			i++;
			j--;
		}
	};

	if (left < j) Quicksort(left, j);
	if (i < right) Quicksort(i, right);
}

void GeneticAlgorithm::EvaluateGeneration() {
	for (int i = 0; i < generation.size(); i++) {
		generation[i].evaluateFitness();
	}
}

void GeneticAlgorithm::GenerateRandomGeneration() {
	generation.clear();
	generation.reserve(currentGenerationSize);

	for (int i = 0; i < currentGenerationSize; ++i) {
		Specimen specimen(c_evaluator, c_rand_engine);
		specimen.evaluateFitness();
		generation.push_back(specimen);
	}
}

void GeneticAlgorithm::ResizeGeneration(int newGenerationSize) {
	if (newGenerationSize > generation.size()) {
		int diff = newGenerationSize - generation.size();
		for (int i = 0; i < diff; i++) {
			Specimen specimen(c_evaluator, c_rand_engine);
			specimen.evaluateFitness();
			generation.push_back(specimen);
		}
	}
	else {
		generation.erase(generation.begin() + newGenerationSize, generation.end());
	}
}

void GeneticAlgorithm::SaveBestSpecimen() {
	//sprawdzamy czy najlepsze rozwiazanie z tej generacji jest lepsze od najlepszego z dotychczasowych rozwiazan
	if (generation[0].getFitness() > globalBestFitness) {
		//changeStrategyCounter = 250; //jesli strategia zadziala potrzymaj ciut dluzej i daj jej cos wymyslic
		changeStrategyCounter = 0;

		globalBestGenes = generation[0].getGenes();
		globalBestFitness = generation[0].getFitness();
		localBestFitness = generation[0].getFitness();

		//ustaw kolor na zielony
		PrintSpecimenFitness("new global best: ", globalBestFitness, 10);
	}
	else if (generation[0].getFitness() > localBestFitness) {
		//changeStrategyCounter = 250; //jesli strategia zadziala potrzymaj ciut dluzej i daj jej cos wymyslic
		changeStrategyCounter = 0;

		localBestFitness = generation[0].getFitness();

		//ustaw kolor na zolty
		PrintSpecimenFitness("new local best: ", localBestFitness, 14);
	}
	else {
		//ustaw kolor na czerwony
		PrintSpecimenFitness("no new best: ", generation[1].getFitness(), 12);

		changeStrategyCounter++;
		if (isStrategyChanged && changeStrategyCounter >= changeStrategyThreshold) {
			//changeStrategyCounter = 100; //jesli nowa strategia szybko nie zadziala to zmien strategie
			changeStrategyCounter = 0;
			UpdateStrategy();
		}
	}
	//ustaw kolor na bialy
	SetConsoleTextAttribute(hConsole, 7);
}

void GeneticAlgorithm::UpdateStrategy() {
	//ustaw kolor na niebieski
	SetConsoleTextAttribute(hConsole, 9);
	std::cout << std::endl << "----- new strategy -----" << std::endl;

	if (true) { //strategia 1 - ma³a wariacja na zmiennych kontroluj¹cych populacje
		//szansa na mutacje
		mutationChance = mutationChanceStates[c_rand_engine() % mutationChanceStates.size()];
		PrintSettingsVariable(mutationChance, mutationChanceStates, "mutationChance");

		//procent krzyzowania
		crossoverPercent = crossoverPercentStates[c_rand_engine() % crossoverPercentStates.size()];
		PrintSettingsVariable(crossoverPercent, crossoverPercentStates, "crossoverPercent");

		//procent scoutowania
		scoutPercent = scoutPercentStates[c_rand_engine() % scoutPercentStates.size()];
		PrintSettingsVariable(scoutPercent, scoutPercentStates, "scoutPercent");

		//ilosc najlepszych osobnikow ktore przepisujemy bez zmian
		vipAmount = vipAmountStates[c_rand_engine() % vipAmountStates.size()];
		PrintSettingsVariable(vipAmount, vipAmountStates, "vipAmount");

		//usun najgorsze osobniki lub losowe
		removeWorstOrRandomChance = removeWorstOrRandomChanceStates[c_rand_engine() % removeWorstOrRandomChanceStates.size()];
		PrintSettingsVariable(removeWorstOrRandomChance, removeWorstOrRandomChanceStates, "removeWorstOrRandomChance");
	}
	if (false) { //strategia 2 - nowa populacja vipów
		/*int strategy = c_rand_engine() % 5;
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
		saveGenerationToFile(vips, "vips.txt");*/
	}

	//ustaw kolor na zielony
	PrintSpecimenFitness("current global best: ", globalBestFitness, 10);
	std::cout << std::endl;

	//ustaw kolor na bialy
	SetConsoleTextAttribute(hConsole, 7);
}
void GeneticAlgorithm::SavePersonalBestGenerationToFile() {
	if (globalBestFitness > pbThreshold) {
		SaveGenerationToFile(to_string(localBestFitness) + ".txt"); //or "generation.txt"
		pbThreshold += pbThresholdChange;
	}
}
void GeneticAlgorithm::SaveGenerationToFile(const std::string& filename) {
	std::ofstream outFile(filename);
	EvaluateGeneration(); //just to be safe

	if (outFile.is_open()) {
		for (int i = 0; i < generation.size(); i++) {
			outFile << generation[i].getFitness() << ' ';

			for (const int& gene : generation[i].getGenes()) {
				outFile << gene << ' ';
			}

			outFile << '\n';
		}

		outFile.close();
		std::cout << "Zapisano do pliku: " << filename << std::endl;
	}
	else {
		std::cout << "B³¹d podczas otwierania pliku do zapisu." << std::endl;
	}
}
void GeneticAlgorithm::LoadGenerationFromFile(const std::string& filename) {

	std::ifstream inFile(filename);

	if (inFile.is_open()) {
		std::string line;

		while (std::getline(inFile, line)) {
			std::istringstream iss(line);

			double fitness;
			if (!(iss >> fitness)) {
				std::cout << "B³¹d podczas wczytywania danych z pliku." << std::endl;
				return;
			}

			std::vector<int> genes;
			int gene;

			while (iss >> gene) {
				genes.push_back(gene);
			}

			Specimen specimen(c_evaluator, c_rand_engine);
			specimen.setFitness(fitness);
			specimen.setGenes(genes);
			specimen.evaluateFitness(); //just to be safe calculate again

			generation.push_back(specimen);
		}

		inFile.close();
		std::cout << "Wczytano z pliku: " << filename << std::endl;
	}
	else {
		std::cout << "B³¹d podczas otwierania pliku do odczytu." << std::endl;
	}
}

void GeneticAlgorithm::PrintSpecimenFitness(string pretext, double fitness, int color) {
	SetConsoleTextAttribute(hConsole, color);
	std::cout << pretext << fitness << std::endl;
	SetConsoleTextAttribute(hConsole, 7); //przywroc bia³y kolor
}

template<typename T> void GeneticAlgorithm::PrintSettingsVariable(T& variable, vector<T>& states, const string& name) {
	std::cout << name << ": {" << states[0];
	for (int i = 1; i < states.size(); i++) std::cout << ", " << states[i];
	std::cout << "} = " << variable << std::endl;
}