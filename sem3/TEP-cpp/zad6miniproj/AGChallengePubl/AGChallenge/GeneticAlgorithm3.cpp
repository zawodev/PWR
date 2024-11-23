#include "GeneticAlgorithm3.h"

#include <cfloat>
#include <iostream>
#include <windows.h>

#include <fstream>
#include <sstream>
#include <algorithm>
#include <vector>
#include <string.h>


using namespace std;

// wersja stypendialna


void GeneticAlgorithm3::Initialize() {
	//ustawiamy najlepsze rozwiazanie na najgorsze mozliwe

	globalBestFitness = -DBL_MAX;
	globalBestGenes.clear();

	i_genotype_length = myEvaluator.iGetNumberOfBits();

	//tworzymy populacje
	vInitPop();

	/*for (int i = 0; i < generationSize; i++) {
		cout << generation[i].first << endl;
	}*/
	std::cout << "-------------------" << std::endl;
}
void GeneticAlgorithm3::vInitPop() {
	CAlikIndividual* pc_ind_new;

	v_pop.clear(); //

	for (int i_ind = 0; i_ind < zawo_population_size; i_ind++) {
		pc_ind_new = new CAlikIndividual(this);
		pc_ind_new->vInitRandom();
		//pc_ind_new->vSetType(i_ind % 2);

		//if (pc_ind_new->i_type == 0) v_pop_m.push_back(pc_ind_new);
		//else v_pop_w.push_back(pc_ind_new);

		v_pop.push_back(pc_ind_new);
	}
}

void GeneticAlgorithm3::RunIteration() {
	iterationNumber++;
	vRunIteration(iterationNumber);
}
void GeneticAlgorithm3::vRunIteration(int iIterationNumber) {
	//usun z populacji najgorsze osobniki
	//wykonaj selekcje, krzyzowanie i mutacje
	//dodaj nowe osobniki do populacji

	for (int i = 1; i <= zawo_iteration_num_in_iteration; i++) {

		//-----    Crossover and mutate    ------


		//delete worst individuals
		vCrossoverAndMutate();


		//-----    Transplant genes    ------

		if (zawo_rule_transplant_genes == 1 && i == zawo_iteration_num_in_iteration) {

			//compute distance matrix
			vComputeDistanceMatrix();  //REMEMBER TO COMPUTE THIS BEFORE ANYTHING ELSE

			//transplant genes
			vTransplantGenes();
		}


		//-----    Selection    ------

		//compute distance matrix
		vComputeDistanceMatrix();  //REMEMBER TO COMPUTE THIS BEFORE ANYTHING ELSE

		//compute diversity penalty
		vComputeDiversityValue();

		//sort population
		vSortPopulation();



		vSelection();
	}
}
void GeneticAlgorithm3::vCrossoverAndMutate() {
	//remove f_crossover_percentage of worst individuals and replace them with new ones
	int i_to_remove = (int)(zawo_crossover_percentage * zawo_population_size);
	int i_start = zawo_population_size - i_to_remove;
	int i_end = zawo_population_size;

	for (int i_ind = i_start; i_ind < i_end; i_ind++) {
		//2 random parents from v_pop[0] to v_pop[i_to_remove]
		CAlikIndividual* pc_parent1 = v_pop[lRand(i_to_remove - 1)];
		CAlikIndividual* pc_parent2 = v_pop[lRand(i_to_remove - 1)];

		v_pop[i_ind]->vCrossover(pc_parent1, pc_parent2);
		v_pop[i_ind]->vMutate(zawo_mutation_probability, zawo_mutation_amount);
		v_pop[i_ind]->vComputeObjectives();
	}
}

void GeneticAlgorithm3::vComputeDistanceMatrix() {

	//REMEMBER TO COMPUTE THIS BEFORE ANYTHING ELSE
	v_genotype_distance_matrix = vector<vector<int>>(v_pop.size(), vector<int>(v_pop.size(), 0));
	v_compute_genotype_distance_matrix(&v_genotype_distance_matrix);
}

void GeneticAlgorithm3::vComputeDiversityValue() {

	//compute diversity penalty per every individual
	vector<double> v_diversity(v_pop.size(), 0);
	for (int ii = 0; ii < v_pop.size(); ii++) {
		for (int jj = 0; jj < v_pop.size(); jj++) {
			v_diversity[ii] += (double)v_genotype_distance_matrix[ii][jj];
		}
	}

	//normalize diversity penalty between 0 and 1
	double d_max = *max_element(v_diversity.begin(), v_diversity.end());
	double d_min = *min_element(v_diversity.begin(), v_diversity.end());

	//set diversity penalty (im wieksza warto�� tym bardziej r�ny od innych)
	for (int ii = 0; ii < v_pop.size(); ii++) {

		//the bigger the value the more different from others
		double d_diversity_value = (v_diversity[ii] - d_min) / (d_max - d_min);

		//clamp between 0 and 1 (for safety)
		if (d_diversity_value < 0) d_diversity_value = 0;
		if (d_diversity_value > 1) d_diversity_value = 1;

		v_pop[ii]->vSetDiversityValue(d_diversity_value);
	}
}

void GeneticAlgorithm3::vSortPopulation() {

	//sort population by fitness
	//sort(v_pop.begin(), v_pop.end(), [this](CAlikIndividual* a, CAlikIndividual* b) { 
	//  return a->dGetFitness(d_current_alfa) > b->dGetFitness(d_current_alfa); 
	//});

	//sort population by diversity fitness
	sort(v_pop.begin(), v_pop.end(), [this](CAlikIndividual* a, CAlikIndividual* b) {
		return a->dGetDiversityFitness() > b->dGetDiversityFitness();
		});


	//print first and last individual
	//CString str;
	//str.Format("First individual: %f", v_pop[0]->dGetFitness(d_current_alfa));
	//pc_log->vPrintLine(str, true);
	//
	//str.Format("Last individual: %f", v_pop[v_pop.size() - 1]->dGetFitness(d_current_alfa));
	//pc_log->vPrintLine(str, true);
}

void GeneticAlgorithm3::vTransplantGenes() {

	//build clusters
	vector<vector<int>> v_clusters = v_build_clusters(&v_genotype_distance_matrix, zawo_cluster_number);
	vector<vector<pair<int, int>>> v_common_genotype = v_find_common_genotype(&v_clusters, zawo_common_genotype_threshold, zawo_common_genotype_max_genes);
	vector<vector<pair<int, int>>> v_transplants = v_find_best_transplants_for_clusters(&v_common_genotype, &v_clusters);

	//transplant genes within clusters, and most successful transplant between clusters
	//vector<pair<int, int>> v_success_failure(v_transplants.size(), pair<int, int>(0, 0));
	int i_success = 0;
	int i_failure = 0;

	for (int ii = 0; ii < v_pop.size(); ii++) {
		for (int jj = 0; jj < v_transplants.size(); jj++) {
			if (v_pop[ii]->bIsTransplantPossible(&v_transplants[jj])) {
				bool b_success = v_pop[ii]->bApplyGeneTransplant(&v_transplants[jj]);
				//if (b_success) v_success_failure[jj].first++;
				//else v_success_failure[jj].second++;
				if (b_success) i_success++;
				else i_failure++;
			}
		}
	}

	//calculate percent of successful transplants
	//int i_success = 0;
	//for (int ii = 0; ii < v_pop.size(); ii++) {
	//	for (int jj = 0; jj < v_common_genotype.size(); jj++) {
	//		bool b_success = v_pop[ii]->vApplyGeneTransplant(&v_common_genotype[jj]);
	//		bool b_success = v_pop[ii]->vFullFIHC_OnlyTransplant(&v_common_genotype[jj]);
	//		if (b_success) i_success++;
	//	}
	//}

	//print percent of successful transplants by cluster
	//for (int ii = 0; ii < v_success_failure.size(); ii++) {
	//	if (v_success_failure[ii].first + v_success_failure[ii].second == 0) continue;
	//	CString str;
	//	double d_percent = (double)v_success_failure[ii].first / (double)(v_success_failure[ii].first + v_success_failure[ii].second);
	//	str.Format("====Success rate for cluster %d: %d/%d | %f", ii, v_success_failure[ii].first, v_success_failure[ii].first + v_success_failure[ii].second, d_percent);
	//	pc_log->vPrintLine(str, true);
	//}
}

int GeneticAlgorithm3::i_hamming_distance(vector<int>& v1, vector<int>& v2) {

	int i_dist = 0;
	for (int ii = 0; ii < v1.size(); ii++) {
		if (v1.at(ii) != v2.at(ii)) i_dist++;
	}

	return i_dist;
}

//funkcja pomocnicza do liczenia odleg�o�ci mi�dzy klastrami (�rednia odleg�o��)
double GeneticAlgorithm3::d_cluster_distance(vector<int>* v1, vector<int>* v2, vector<vector<int>>* v_distance_matrix) {
	double d_dist = 0;
	for (int ii = 0; ii < v1->size(); ii++) {
		for (int jj = 0; jj < v2->size(); jj++) {
			d_dist += (*v_distance_matrix)[v1->at(ii)][v2->at(jj)];
		}
	}

	return d_dist / (v1->size() * v2->size()); //zamiast '�redniej' spr�buj 'minimum' kiedy�
}

void GeneticAlgorithm3::v_compute_genotype_distance_matrix(vector<vector<int>>* v_genotype_distance_matrix) {

	//vector<vector<int>> v_matrix(v_pop.size(), vector<int>(v_pop.size(), 0));

	//for (int ii = 0; ii < v_pop.size(); ii++) {
	//	for (int jj = ii + 1; jj < v_pop.size(); jj++) {
	//		v_matrix[ii][jj] = v_matrix[jj][ii] = i_hamming_distance(v_pop[ii]->v_genotype, v_pop[jj]->v_genotype);
	//	}
	//}

	for (int ii = 0; ii < v_pop.size(); ii++) {
		for (int jj = ii + 1; jj < v_pop.size(); jj++) {
			(*v_genotype_distance_matrix)[ii][jj] = (*v_genotype_distance_matrix)[jj][ii] = i_hamming_distance(v_pop[ii]->v_genotype, v_pop[jj]->v_genotype);
		}
	}
}

void GeneticAlgorithm3::v_sort_by_absolute_value(vector<pair<double, int>>* v) {
	//std::sort(v.begin(), v.end(), [](const std::pair<double, int>& a, const std::pair<double, int>& b) {
	//	return std::fabs(a.first) > std::fabs(b.first); // sortowanie malej�ce po warto�ci bezwzgl�dnej
	//});

	sort(v->begin(), v->end(), [](const pair<double, int>& a, const pair<double, int>& b) {
		return fabs(a.first) > fabs(b.first);
		});
}

vector<pair<double, int>> GeneticAlgorithm3::v_compute_average_sorted_genes(vector<int>* v_cluster) {

	//vector<double> v_average_genes(i_genotype_length, 0);
	//vector<int> v_indexes(i_genotype_length, 0);

	vector<pair<double, int>> v_result(i_genotype_length, pair<double, int>(0, 0));

	//pc_log->vPrintLine("test test test", true);

	for (int ii = 0; ii < v_cluster->size(); ii++) {
		for (int jj = 0; jj < i_genotype_length; jj++) {
			//v_average_genes[jj] += v_pop[v_cluster[ii]]->v_genotype[jj];
			v_result[jj].first += v_pop[v_cluster->at(ii)]->v_genotype[jj];
		}
		//if(ii < 5) pc_log->vPrintLine(convert_to_cstring(to_string(v_cluster->at(ii))), true);
	}

	//pc_log->vPrintLine("----Average genes: ---", true);
	//pc_log->vPrintLine(convert_to_cstring(to_string(v_result[0].first) + " " + to_string(v_result[0].second)), true);
	//pc_log->vPrintLine(convert_to_cstring(to_string(v_result[1].first) + " " + to_string(v_result[1].second)), true);
	//pc_log->vPrintLine(convert_to_cstring(to_string(v_result[2].first) + " " + to_string(v_result[2].second)), true);

	for (int ii = 0; ii < i_genotype_length; ii++) {
		//save indexes
		//v_indexes[ii] = ii;
		v_result[ii].second = ii;

		//calculate average where 1.0 is all 1s and 0.0 is all 0s
		//v_average_genes[ii] /= v_cluster.size();
		v_result[ii].first /= (double)(v_cluster->size());

		//instead of values between 0 and 1 we have values between -1 and 1
		//v_average_genes[ii] = 2 * v_average_genes[ii] - 1;
		v_result[ii].first = 2 * v_result[ii].first - 1;

		//clamp values between -1 and 1
		if (v_result[ii].first < -1) v_result[ii].first = -1;
		if (v_result[ii].first > 1) v_result[ii].first = 1;
	}

	//pc_log->vPrintLine(convert_to_cstring(to_string(v_result[0].first) + " " + to_string(v_result[0].second)), true);
	//pc_log->vPrintLine(convert_to_cstring(to_string(v_result[1].first) + " " + to_string(v_result[1].second)), true);
	//pc_log->vPrintLine(convert_to_cstring(to_string(v_result[2].first) + " " + to_string(v_result[2].second)), true);


	//shuffle v_result
	std::random_shuffle(v_result.begin(), v_result.end());
	v_sort_by_absolute_value(&v_result);

	return v_result; //where -1.0 is all 0s, 1.0 is all 1s
}

vector<vector<pair<int, int>>> GeneticAlgorithm3::v_find_best_transplants_for_clusters(vector<vector<pair<int, int>>>* v_common_genotype, vector<vector<int>>* v_clusters) {

	vector<vector<pair<int, int>>> result;

	for (int ii = 0; ii < v_clusters->size(); ii++) {
		vector<int> v_genes = v_convert_pii_to_i(&(v_common_genotype->at(ii)));

		//get random element from ii cluster
		int i_rand_individual_index = (*v_clusters)[ii][lRand((*v_clusters)[ii].size() - 1)];
		vector<pair<int, int>> v_transplant = v_pop[i_rand_individual_index]->vGetBestTransplantByFullFIHC(&v_genes); //lepiej robic na kilku osobach, zeby miec wieksze szanse ze transplant bedzie skuteczny

		result.push_back(v_transplant);
	}

	return result;
}

vector<pair<int, int>> GeneticAlgorithm3::v_convert_pdi_to_pii(vector<pair<double, int>>* v_input) {
	//converts vector of pairs from double to int, losing precision (but looks nicer to work with)
	vector<pair<int, int>> result;
	result.reserve(v_input->size()); // rezerwuje pami�� dla wydajno�ci (chyba jest wydaniej?)

	for (const auto& elem : *v_input) {
		int first = (elem.first > 0.0) ? 1 : 0; // zamiana double na 1 lub 0
		result.push_back({ first, elem.second }); // dodaje now� par�
	}

	return result;
}

vector<int> GeneticAlgorithm3::v_convert_pii_to_i(vector<pair<int, int>>* v_input) {
	vector<int> result;
	result.reserve(v_input->size());

	for (const auto& elem : *v_input) {
		result.push_back(elem.second); // dodaje drugi element (int) z pary
	}

	return result;
}

//arbitralny treshhold 0.7
vector<vector<int>> GeneticAlgorithm3::v_build_clusters(vector<vector<int>>* v_distance_matrix, int i_clusters_number) {

	//vector<vector<int>> v_distance_matrix = v_compute_genotype_distance_matrix();
	vector<vector<int>> clusters(v_pop.size(), vector<int>());

	for (int ii = 0; ii < v_pop.size(); ii++) {
		clusters[ii].push_back(ii); // kazdy osobnik zaczyna w swoim klastrze
	}

	while (clusters.size() > i_clusters_number) {
		double d_min_dist = 1000000;
		int i_min_i = 0;
		int i_min_j = 0;

		//find two closest clusters
		for (int ii = 0; ii < clusters.size(); ii++) {
			for (int jj = ii + 1; jj < clusters.size(); jj++) {
				double d_dist = d_cluster_distance(&clusters[ii], &clusters[jj], v_distance_matrix);
				if (d_dist < d_min_dist) {
					d_min_dist = d_dist;
					i_min_i = ii;
					i_min_j = jj;
				}
			}
		}

		//merge clusters
		for (int ii = 0; ii < clusters[i_min_j].size(); ii++) {
			clusters[i_min_i].push_back(clusters[i_min_j][ii]);
		}

		//delete merged cluster
		clusters.erase(clusters.begin() + i_min_j);
	}

	//print cluster[0]
	//pc_log->vPrintLine("----Cluster 0: ---", true);
	//string str = "";
	//for (int jj = 0; jj < clusters[0].size(); jj++) {
	//	str += to_string(clusters[0][jj]);
	//	str += " ";
	//}
	//pc_log->vPrintLine(convert_to_cstring(str), true);

	//print cluster[1]
	//pc_log->vPrintLine("----Cluster 1: ---", true);
	//str = "";
	//for (int jj = 0; jj < clusters[1].size(); jj++) {
	//	str += to_string(clusters[1][jj]);
	//	str += " ";
	//}
	//pc_log->vPrintLine(convert_to_cstring(str), true);




	//delete clusters with size 1
	for (int ii = 0; ii < clusters.size(); ii++) {
		if (clusters[ii].size() == 1) {
			clusters.erase(clusters.begin() + ii);
			ii--;
		}
	}

	return clusters;
}

vector<vector<pair<int, int>>> GeneticAlgorithm3::v_find_common_genotype(vector<vector<int>>* v_clusters, double d_threshold, int i_max_genes) {

	vector<vector<pair<int, int>>> result;

	for (int ii = 0; ii < v_clusters->size(); ii++) {

		//compute average genes
		vector<pair<double, int>> v_average_sorted_genes = v_compute_average_sorted_genes(&(v_clusters->at(ii)));
		//v_sort_by_absolute_value(&v_average_genes);

		//print average genes
		//string str = "";
		//for (int jj = 0; jj < v_average_genes.size(); jj++) {
		//	str += "{" + to_string(v_average_genes[jj].first) + ", " + to_string(v_average_genes[jj].second) + "}, ";
		//}
		//pc_log->vPrintLine(convert_to_cstring(str), true);

		if (v_average_sorted_genes.size() > i_max_genes) {
			v_average_sorted_genes.resize(i_max_genes);
		}
		while (!v_average_sorted_genes.empty() && fabs(v_average_sorted_genes.back().first) < d_threshold) {
			v_average_sorted_genes.pop_back();
		}

		result.push_back(v_convert_pdi_to_pii(&v_average_sorted_genes));
	}

	return result;
}
void GeneticAlgorithm3::PrintSpecimenFitness(string pretext, double fitness, int color) {
	SetConsoleTextAttribute(hConsole, color);
	std::cout << pretext << fitness << std::endl;
	SetConsoleTextAttribute(hConsole, 7); //przywroc biały kolor
}
void GeneticAlgorithm3::vSelection() {

	pair<double, vector<int>> bestSpecimen = pair<double, vector<int>>(v_pop[0]->v_objectives[0], v_pop[0]->v_genotype);

	if (newBest) {
		//ustaw kolor na zielony
		PrintSpecimenFitness("new global best: ", globalBestFitness, 10);
		newBest = false;
	}
	else {
		//ustaw kolor na czerwony
		PrintSpecimenFitness("no new best: ", globalBestFitness, 12);
	}
	//ustaw kolor na bialy
	SetConsoleTextAttribute(hConsole, 7);
}



//---------------------------------------------------CAlikIndividual-------------------------------


CAlikIndividual::CAlikIndividual(GeneticAlgorithm3* pcParent) {
	pc_parent = pcParent;
	vector<int> item_vec(vector<int>(pc_parent->i_genotype_length, 0));
	//obj vec size 2
	vector<double> obj_vec(2, 0);

	v_genotype = item_vec;
	v_objectives = obj_vec;

	//weight = knap_vec;
	//profit = knap_vec;
}

CAlikIndividual::CAlikIndividual(const CAlikIndividual& pcOther) {
	this->pc_parent = pcOther.pc_parent;
	this->v_genotype = pcOther.v_genotype;
	this->v_objectives = pcOther.v_objectives;
	this->d_fitness = pcOther.d_fitness;
	this->i_type = pcOther.i_type;
}

CAlikIndividual& CAlikIndividual::operator=(const CAlikIndividual& pcOther) {
	if (this == &pcOther) {
		return (*this);
	}

	this->pc_parent = pcOther.pc_parent;
	this->v_genotype = pcOther.v_genotype;
	this->v_objectives = pcOther.v_objectives;
	this->d_fitness = pcOther.d_fitness;
	this->i_type = pcOther.i_type;

	return *this;
}

CAlikIndividual::~CAlikIndividual() {

}



// randomly initialize solution
void CAlikIndividual::vInitRandom() {
	v_genotype.resize((size_t)pc_parent->myEvaluator.iGetNumberOfBits());
	for (int ii = 0; ii < v_genotype.size(); ii++) {
		v_genotype.at(ii) = lRand(pc_parent->myEvaluator.iGetNumberOfValues(ii));
	}

	vComputeObjectives(); //well it is quite important? idk can be commented if we compute right after 
}

void CAlikIndividual::vFIHC() {
	//pocz�tkowe warto�ci
	double d_best_fitness = dGetFitness();

	//losowanie kolejno�ci gen�w
	vector<int> v_order(v_genotype.size());
	for (int ii = 0; ii < v_order.size(); ii++) {
		v_order.at(ii) = ii;
	}

	//tasowanie gen�w
	random_shuffle(v_order.begin(), v_order.end());

	//przej�cie po wszystkich genach
	for (int ii = 0; ii < v_order.size(); ii++) {
		//zmiana warto�ci genu
		v_genotype.at(v_order.at(ii)) = 1 - v_genotype.at(v_order.at(ii));

		//obliczenie nowej warto�ci funkcji celu
		vComputeObjectives();
		double d_new_fitness = dGetFitness();

		//je�eli nowa warto�� jest lepsza to zostawiamy zmian�
		if (d_new_fitness > d_best_fitness) {
			d_best_fitness = d_new_fitness;
		}
		else {
			//je�eli nie to cofamy zmian�
			v_genotype.at(v_order.at(ii)) = 1 - v_genotype.at(v_order.at(ii));
		}
	}
}

vector<pair<int, int>> CAlikIndividual::vGetBestTransplantByFullFIHC(vector<int>* v_genes) {
	//pocz�tkowe warto�ci
	double d_best_fitness = dGetFitness();

	vector<double> v_best_objectives = v_objectives;
	vector<int> v_best_genotype = v_genotype;

	if (v_genes->size() > 10) {
		//pc_parent->pc_log->vPrintLine("Error: Too many genes to change", true);
		return vGetGoodTransplantByPartialRandomFIHC(v_genes, 1024);
	}

	//przej�cie po wszystkich mo�liwych kombinacjach zmian gen�w
	//mp dla gen�w {2, 3, 4} dla genotypu danego testujemy wszystkie zmiany 2, 3, 4 genu
	//dla ka�dej kombinacji sprawdzamy czy jest lepsza od obecnej najlepszej je�li tak to j� zapisujemy
	//np dla genotypu 0000 i zmiany 2, 3, 4 sprawdzamy 0000, 0001, 0010, 0011, 0100, 0101, 0110, 0111, poniewa� gen na pozycji 1 nie by� w genach, to jej nie sprawdzamy


	int i_max = pow(2, v_genes->size());

	for (int i = 0; i < i_max; i++) {
		for (int j = 0; j < v_genes->size(); j++) {
			v_genotype.at(v_genes->at(j)) = (i >> j) & 1; //"(i >> j) & 1"    ->    reprezentacja binarna liczby i
		}

		vComputeObjectives();
		double d_new_fitness = dGetFitness();

		if (d_new_fitness > d_best_fitness) {
			d_best_fitness = d_new_fitness;
			v_best_genotype = v_genotype;
			v_best_objectives = v_objectives;
		}
	}
	v_genotype = v_best_genotype;
	v_objectives = v_best_objectives;


	//return best genotype
	vector<pair<int, int>> v_result;
	for (int ii = 0; ii < v_genes->size(); ii++) {
		v_result.push_back(make_pair(v_best_genotype.at(v_genes->at(ii)), v_genes->at(ii)));
	}

	return v_result;
}

vector<pair<int, int>> CAlikIndividual::vGetGoodTransplantByPartialRandomFIHC(vector<int>* v_genes, int i_attempts) {
	//spr�buj i_attempts razy znale�� lepszy genotyp, zmieniaj�c jedynie geny z v_genes na losowe warto�ci
	//upewnij si� �e dwie pr�by nie b�d� sprawdza� tego samego genotypu

	double d_best_fitness = dGetFitness();

	vector<double> v_best_objectives = v_objectives;
	vector<int> v_best_genotype = v_genotype;



	for (int i = 0; i < i_attempts; i++) {

		vector<int> v_new_genotype = v_genotype;

		for (int j = 0; j < v_genes->size(); j++) {
			v_new_genotype.at(v_genes->at(j)) = lRand(pc_parent->myEvaluator.iGetNumberOfValues(j));
		}

		v_genotype = v_new_genotype;
		vComputeObjectives();
		double d_new_fitness = dGetFitness();

		if (d_new_fitness > d_best_fitness) {
			d_best_fitness = d_new_fitness;
			v_best_genotype = v_genotype;
			v_best_objectives = v_objectives;
		}
	}

	v_genotype = v_best_genotype;
	v_objectives = v_best_objectives;

	//return best genotype
	vector<pair<int, int>> v_result;
	for (int ii = 0; ii < v_genes->size(); ii++) {
		v_result.push_back(make_pair(v_best_genotype.at(v_genes->at(ii)), v_genes->at(ii)));
	}

	return v_result;
}

bool CAlikIndividual::bIsTransplantPossible(vector<pair<int, int>>* v_transplant) {
	//check if transplant is changing anything at all
	bool b_change = false;
	for (int ii = 0; ii < v_transplant->size(); ii++) {
		if (v_transplant->at(ii).first != v_genotype[v_transplant->at(ii).second]) {
			b_change = true;
			break;
		}
	}
	if (!b_change) {
		//pc_parent->pc_log->vPrintLine("Error: Transplant is equal to original", true);
		return false;
	}

	return true;
}

bool CAlikIndividual::bApplyGeneTransplant(vector<pair<int, int>>* v_transplant) {

	//save individual if transplant is worse than original
	vector<int> v_original_genotype = v_genotype;
	vector<double> v_original_objectives = v_objectives;
	double d_original_fitness = dGetFitness();

	//apply transplant
	for (int ii = 0; ii < v_transplant->size(); ii++) {
		v_genotype.at(v_transplant->at(ii).second) = v_transplant->at(ii).first;
	}
	vComputeObjectives();

	//if transplant is worse than original, return false and restore original genes
	if (dGetFitness() < d_original_fitness) {
		v_genotype = v_original_genotype;
		v_objectives = v_original_objectives;
		return false;
	}
	if (dGetFitness() == d_original_fitness) {
		//pc_parent->pc_log->vPrintLine("Transplant is equal to original", true);
		return false;
	}

	return true;
}

void CAlikIndividual::vMutate(const float fMutationProbability, const float fMutationAmount) {
	if (dRand() < fMutationProbability) {
		for (int ii = 0; ii < v_genotype.size(); ii++) {
			if (dRand() < fMutationAmount) {
				v_genotype.at(ii) = lRand(pc_parent->myEvaluator.iGetNumberOfValues(ii));
			}
		}
	}
}

void CAlikIndividual::vCrossover(CAlikIndividual* pcParent1, CAlikIndividual* pcParent2) {
	//replace this individual with crossover of two parents
	for (int ii = 0; ii < v_genotype.size(); ii++) {
		if (iRand() % 2 == 0) {
			v_genotype.at(ii) = pcParent1->v_genotype.at(ii);
		}
		else {
			v_genotype.at(ii) = pcParent2->v_genotype.at(ii);
		}
	}
}

void CAlikIndividual::vComputeObjectives() { //add to global pareto front

	v_objectives[0] = pc_parent->myEvaluator.dEvaluate(&v_genotype);
	v_objectives[1] = 0;

	if (v_objectives[0] > pc_parent->globalBestFitness) {
		pc_parent->globalBestFitness = v_objectives[0];
		pc_parent->globalBestGenes.resize(v_genotype.size());
		for (int i = 0; i < v_genotype.size(); i++) {
			pc_parent->globalBestGenes[i] = v_genotype[i];
		}

		pc_parent->newBest = true;
	}
}

double CAlikIndividual::dGetFitness() { //get 1d fitness
	// vComputeObjectives(); //remember to compute objectives before computing fitness, because if objectives == 0, fitness will be 0

	d_fitness = v_objectives[0];
	return d_fitness;
}

double CAlikIndividual::dGetDiversityFitness() { // d_diversity_value is between [0 and 1]-> 0 meaning same as others, 1 meaning different from others
	double d_diversity_reward = (d_diversity_value * pc_parent->zawo_diversity_reward_scaler);
	d_diversity_fitness = dGetFitness() * (1 + d_diversity_reward);
	return d_diversity_fitness;
}

void CAlikIndividual::vShow() {
	for (int ii = 0; ii < pc_parent->i_genotype_length; ii++) {
		cout << v_genotype.at(ii);
	}

	cout << endl;
}