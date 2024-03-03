#include "GeneticAlgorithm.h"

using namespace std;

GeneticAlgorithm::GeneticAlgorithm(MyEvaluator& _myEvaluator) : myEvaluator(_myEvaluator), globalBestSpecimen(Specimen()) {
	hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
}
void GeneticAlgorithm::Initialize() {

	//tworzymy populacje
	Population population1(myEvaluator, mainPopulationSize, true);

	//wczytaj populacje z pliku lub wygeneruj nowa
	if (isLoadedFromFile) LoadPopulationFromFile(population1, "generation.txt");
	else population1.GenerateRandomGeneration();

	//dodaj populacje do wektora populacji
	populations.push_back(population1);

	if (sidePopulationSize > 0) {
		Population population2(myEvaluator, sidePopulationSize, false);
		population2.GenerateGenerationFromOther(population1); //wygeneruj druga populacje z pierwszej
		populations.push_back(population2);
	}

	/*for (int i = 0; i < currentGenerationSize; i++) {
		cout << generation[i].getFitness() << endl;
	}*/
	std::cout << "-------------------" << std::endl;
}

void GeneticAlgorithm::RunIteration() {

	/*
	vector<thread> threads;
	for (int i = 0; i < currentPopulationNum; i++) {
		threads.emplace_back(&Population::RunIteration, &populations[i]);
		populations[i].RunIteration();
	}
	for (auto& thread : threads) {
		thread.join();
	}
	*/

	for (int i = 0; i < populations.size(); i++) {
		populations[i].RunIteration();
	}

	//oceniamy najlepsze osobniki
	SaveBestSpecimen();
}

void GeneticAlgorithm::SaveBestSpecimen() {

	//dla wszystkich populacji sprawdz czy najlepszy osobnik jest lepszy od dotychczasowego najlepszego
	int newBestIndex = -1;
	for (int i = 0; i < populations.size(); i++) {
		if (populations[i].getLocalBestSpecimen().getFitness() > globalBestSpecimen.getFitness()) {
			globalBestSpecimen = populations[i].getLocalBestSpecimen();
			newBestIndex = i;
		}
	}

	//wypisz najlepsze osobniki
	PrintLocalBestFitnesses(10, 12, newBestIndex);

	//jezeli populacja[0] nie znalazla nowego najlepszego osobnika to mieszamy populacje
	if (newBestIndex == 1 && populations.size() >= 2) {
		MixTwoPopulations(populations[0], populations[1]);
		PrintTextInColor("----- populations: [" + to_string(0) + "], [" + to_string(1) + "] have been mixed -----", 9);

		for (int i = 0; i < populations.size(); i++) {
			populations[i].setNoNewLocalBestTreshholdReached(false);
		}
	}

	//zapisz do pliku jezeli najlepszy osobnik ma odpowiednia wartosc
	if (globalBestSpecimen.getFitness() > pbThreshold) {
		SaveSpecimenToFile(globalBestSpecimen, "pb population");
		pbThreshold += pbThresholdChange;
	}

	//ustaw kolor na bialy
	SetConsoleTextAttribute(hConsole, 7);
}
/*
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
	PrintSpecimenFitness("current global best: ", globalBestFitness, 10);
	std::cout << std::endl;

	//ustaw kolor na bialy
	SetConsoleTextAttribute(hConsole, 7);
}
*/
void GeneticAlgorithm::MixTwoPopulations(Population& population1, Population& population2) {
	int pop1Size = population1.getPopulationSize();
	int pop2Size = population2.getPopulationSize();
	int _minPopulationSize = pop1Size < pop2Size ? pop1Size : pop2Size;

	for (int i = 0; i < _minPopulationSize; i++) {
		Specimen& specimen1 = population1.getPopulation()[pop1Size - i - 1];
		Specimen& specimen2 = population2.getPopulation()[pop2Size - i - 1];
		if (iRand() % 2 == 0) SwapSpecimens(specimen1, specimen2);
	}
}
void GeneticAlgorithm::SwapSpecimens(Specimen& specimen1, Specimen& specimen2) {
	Specimen temp = specimen1;
	specimen1 = specimen2;
	specimen2 = temp;
}

void GeneticAlgorithm::SavePopulationToFile(Population& population, const std::string& populationName) {
	for (Specimen& specimen : population.getPopulation()) {
		SaveSpecimenToFile(specimen, populationName);
	}
}
void GeneticAlgorithm::SaveSpecimenToFile(Specimen& specimen, const std::string& populationName) {
	std::string fileName = populationName + "/specimen_" + to_string(specimen.getFitness()) + ".txt";
	std::ofstream outFile(fileName);
	if (outFile.is_open()) {
		outFile << specimen.getFitness() << ' ';

		for (const int& gene : specimen.getGenes()) {
			outFile << gene << ' ';
		}

		outFile << '\n';

		outFile.close();
		std::cout << "Zapisano do pliku: " << fileName << std::endl;
	}
	else {
		std::cout << "B³¹d podczas otwierania pliku do zapisu." << std::endl;
	}
}

void GeneticAlgorithm::LoadPopulationFromFile(Population& population, const std::string& filename) {
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

			Specimen specimen(myEvaluator);
			specimen.setFitness(fitness);
			specimen.setGenes(genes);
			specimen.evaluateFitness(); //just to be safe calculate again

			population.getPopulation().push_back(specimen);
		}

		population.ResizePopulation();

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
void GeneticAlgorithm::PrintTextInColor(string text, int color) {
	SetConsoleTextAttribute(hConsole, color);
	std::cout << text << std::endl;
	SetConsoleTextAttribute(hConsole, 7); //przywroc bia³y kolor
}
void GeneticAlgorithm::PrintLocalBestFitnesses(int globalColor, int localColor, int globalBestIndex) {
	SetConsoleTextAttribute(hConsole, localColor);
	for (int i = 0; i < populations.size(); i++) {
		if(globalBestIndex == i) SetConsoleTextAttribute(hConsole, globalColor);
		cout << "[" << i << "]: " << populations[i].getLocalBestSpecimen().getFitness() << " ";
		SetConsoleTextAttribute(hConsole, localColor);
	}
	cout << endl;
	SetConsoleTextAttribute(hConsole, 7); //przywroc bia³y kolor
}
template<typename T> void GeneticAlgorithm::PrintSettingsVariable(T& variable, vector<T>& states, const string& name) {
	std::cout << name << ": {" << states[0];
	for (int i = 1; i < states.size(); i++) std::cout << ", " << states[i];
	std::cout << "} = " << variable << std::endl;
}