#include "Optimizer.hpp"
#include "MyEvaluator.hpp"
#include <iostream>
#include <limits>
#include <iomanip>
#include <algorithm>
#include <numeric>
#include <fstream>
#include <sstream>

using namespace LcVRPContest;

Optimizer::Optimizer(Evaluator& evaluator)
    : evaluator_(evaluator) {
    current_best_.fitness = numeric_limits<double>::max();
}

Optimizer::~Optimizer() {
    StopThreads();
}

void Optimizer::StopThreads() {
    stop_flag_ = true;
    for (auto& t : threads_) {
        if (t.joinable()) {
            t.join();
        }
    }
    threads_.clear();
    stop_flag_ = false;
}

void Optimizer::Initialize() {
    // stop any existing threads first
    StopThreads();

    // initialize current best with a random individual using original evaluator
    mt19937 init_rng(random_device{}());
    current_best_.genotype.resize(evaluator_.GetSolutionSize());
    uniform_int_distribution<int> dist(evaluator_.GetLowerBound(), evaluator_.GetUpperBound());
    for (size_t i = 0; i < current_best_.genotype.size(); ++i) {
        current_best_.genotype[i] = dist(init_rng);
    }
    current_best_.fitness = evaluator_.Evaluate(current_best_.genotype);

    // create and start worker threads
    random_device rd;
    threads_.reserve(population_size);

    for (int i = 0; i < population_size; ++i) {
        // each thread gets its own copy of MyEvaluator (optimized) and unique seed
        MyEvaluator thread_evaluator(evaluator_.GetProblemData(), evaluator_.GetNumGroups());
        unsigned int seed = rd();

        threads_.emplace_back(&Optimizer::WorkerThread, this, i, std::move(thread_evaluator), seed);
    }
}

void Optimizer::WorkerThread(int thread_id, MyEvaluator evaluator, unsigned int seed) {
    // each thread has its own RNG and Individual
    mt19937 rng(seed);
    Individual individual;

    // initialize individual
    InitRandomIndividual(individual, evaluator, rng);

    //LoadIndividualFromFile(individual, evaluator, "current_best_input.txt");
    //MutateIndividual(individual, evaluator, rng);

    //ReassignRouteIndividualOld(individual, evaluator, rng);
    //ReassignRouteIndividual(individual, evaluator, rng);

    //individual.genotype = {};
    //individual.fitness = evaluator.Evaluate(individual.genotype);

    Individual local_best = individual;
    UpdateLocalBestIndividual(individual, local_best);

    // run forever until stop_flag is set
    while (!stop_flag_) {
        RunIndividual(individual, local_best, evaluator, rng);
        //UpdateBestIndividual(individual);

        // update local_best if individual is better
        UpdateLocalBestIndividual(individual, local_best);
    }
}

void Optimizer::RunIteration() {
    //cout << "Cache hits: " << MyEvaluator::GetCacheHits() << " Cache misses: " << MyEvaluator::GetCacheMisses() << "\r";
    // print some status/info/progress here
    this_thread::sleep_for(chrono::milliseconds(1000));
}

void Optimizer::UpdateBestIndividual(const Individual& individual) {
    lock_guard<mutex> lock(best_mutex_);

    if (individual.fitness < current_best_.fitness) {
        current_best_ = individual;
        //PrintIndividual(current_best_);
        //SaveIndividualToFile(current_best_, "current_best_output.txt");
    }
}

void Optimizer::UpdateLocalBestIndividual(const Individual& individual, Individual& local_best) {
    if (individual.fitness < local_best.fitness) {
        local_best = individual;
        // update diversity pool with new local best
        UpdateDiversityPool(individual);
    }
    UpdateBestIndividual(individual);
}

int Optimizer::CalculateGenotypeDifference(const vector<int>& genotype1, const vector<int>& genotype2, int numGroups) {
    // build contingency matrix: contingency[g1][g2] = count of customers in group g1 in genotype1 AND group g2 in genotype2
    // using flat vector for better cache performance
    vector<int> contingency(numGroups * numGroups, 0);
    
    int n = static_cast<int>(genotype1.size());
    
    // fill contingency matrix
    for (int i = 0; i < n; ++i) {
        int g1 = genotype1[i];
        int g2 = genotype2[i];
        contingency[g1 * numGroups + g2]++;
    }
    
    // find maximum in each row (best mapping for each group in genotype1)
    // sum of maxes = number of customers that would match after optimal remapping
    int sumOfMaxes = 0;
    for (int g1 = 0; g1 < numGroups; ++g1) {
        int maxInRow = 0;
        for (int g2 = 0; g2 < numGroups; ++g2) {
            int val = contingency[g1 * numGroups + g2];
            if (val > maxInRow) {
                maxInRow = val;
            }
        }
        sumOfMaxes += maxInRow;
    }
    
    // difference = n - sumOfMaxes (how many customers would need to move)
    return n - sumOfMaxes;
}

void Optimizer::UpdateDiversityPool(const Individual& individual) {
    lock_guard<mutex> lock(diversity_pool_mutex_);
    
    int numGroups = evaluator_.GetNumGroups();
    
    // if pool is not full yet, just add the individual
    if (diversity_pool_.size() < DIVERSITY_POOL_SIZE) {
        diversity_pool_.push_back(individual);
        return;
    }
    
    // pool is full - find the individual with minimum difference to the new one
    int minDiff = numeric_limits<int>::max();
    int minIdx = 0;
    
    for (size_t i = 0; i < diversity_pool_.size(); ++i) {
        int diff = CalculateGenotypeDifference(individual.genotype, diversity_pool_[i].genotype, numGroups);
        if (diff < minDiff) {
            minDiff = diff;
            minIdx = static_cast<int>(i);
        }
    }
    
    // replace the most similar individual (smallest difference)
    diversity_pool_[minIdx] = individual;
}

Individual Optimizer::GetRandomFromDiversityPool(mt19937& rng) {
    lock_guard<mutex> lock(diversity_pool_mutex_);
    
    if (diversity_pool_.empty()) {
        // return current_best_ individual if pool is empty (UGLY!) - should not happen but better safe than sorry
        return current_best_;
    }
    
    uniform_int_distribution<int> dist(0, static_cast<int>(diversity_pool_.size()) - 1);
    return diversity_pool_[dist(rng)];
}

void Optimizer::EvaluateAndUpdate(Individual& individual, MyEvaluator& evaluator) {
    individual.fitness = evaluator.Evaluate(individual.genotype);
    UpdateBestIndividual(individual);
}

void Optimizer::InitRandomIndividual(Individual& individual, MyEvaluator& evaluator, mt19937& rng) {
    individual.genotype.resize(evaluator.GetSolutionSize());
    uniform_int_distribution<int> dist(evaluator.GetLowerBound(), evaluator.GetUpperBound());
    for (size_t i = 0; i < individual.genotype.size(); ++i) {
        individual.genotype[i] = dist(rng);
    }
    // full evaluation initializes internal state of MyEvaluator
    individual.fitness = evaluator.Evaluate(individual.genotype);
}

void Optimizer::RunIndividual(Individual& individual, Individual& local_best, MyEvaluator& evaluator, mt19937& rng) {
    // 50/50 wybór między gene-based a swap-based FIHC
    uniform_int_distribution<int> fihcChoice(0, 1);

    bool everImproved;
    if (fihcChoice(rng) == 0) {
        everImproved = FihcGeneBased(individual, evaluator, rng);
        if (!everImproved) everImproved = FihcSwapBased(individual, evaluator, rng);
    }
    else {
        everImproved = FihcSwapBased(individual, evaluator, rng);
        if (!everImproved) everImproved = FihcGeneBased(individual, evaluator, rng);
    }

    // jeśli nie znaleziono żadnej poprawy, weź local besta i zastosuj mutację
    if (!everImproved && !stop_flag_) {
        /*{
            lock_guard<mutex> lock(best_mutex_);
            individual = current_best_;
        }*/
        //individual = local_best;
        //MutateIndividual(individual, evaluator, rng);

        // 50/50 szansa na małą mutację vs destroy-and-repair
        uniform_int_distribution<int> randEvent(0, 100);
		int eventRoll = randEvent(rng);
        if (eventRoll <= 30) {
            individual = GetRandomFromDiversityPool(rng);
            MutateIndividual(individual, evaluator, rng);
        }
        else if (eventRoll <= 60) {
            individual = local_best;
            MutateIndividual(individual, evaluator, rng);
        }
        else if (eventRoll <= 80) {
            MutateIndividual(individual, evaluator, rng);
        }
        else if (eventRoll <= 85) {
            individual = GetRandomFromDiversityPool(rng);
            ReassignRouteIndividualOld(individual, evaluator, rng);
        }
        else if (eventRoll <= 90) {
            individual = local_best;
            ReassignRouteIndividualOld(individual, evaluator, rng);
        }
        else {
            ReassignRouteIndividualOld(individual, evaluator, rng);
        }
    }
}

bool Optimizer::FihcGeneBased(Individual& individual, MyEvaluator& evaluator, mt19937& rng) {
    // Oryginalny FIHC - przejeżdżamy przez wszystkie geny i każdy próbujemy zmienić
    bool improved = true;
    bool everImproved = false;

    while (improved && !stop_flag_) {
        improved = false;

        std::vector<int> geneIndices(evaluator.GetSolutionSize());
        std::iota(geneIndices.begin(), geneIndices.end(), 0);
        std::shuffle(geneIndices.begin(), geneIndices.end(), rng);

        for (int geneIdx : geneIndices) {
            if (stop_flag_) break;

            int originalValue = individual.genotype[geneIdx];

            for (int val = evaluator.GetLowerBound(); val <= evaluator.GetUpperBound(); ++val) {
                if (val == originalValue) continue;

                double newFitness = evaluator.EvaluateDelta(individual.genotype, geneIdx, originalValue, val);

                if (newFitness < individual.fitness) {
                    individual.genotype[geneIdx] = val;
                    evaluator.ApplyChange(individual.genotype, geneIdx, originalValue, val);
                    individual.fitness = newFitness;
                    improved = true;
                    everImproved = true;
                    UpdateBestIndividual(individual);
                    break;
                }
            }
        }
    }

    return everImproved;
}

bool Optimizer::FihcSwapBased(Individual& individual, MyEvaluator& evaluator, mt19937& rng) {
    // FIHC zorientowany na swapy dwóch klientów z różnych tras
    // Bierzemy trasę i próbujemy zamieniać jej klientów z klientami z innych tras
    bool improved = true;
    bool everImproved = false;

    int numGroups = evaluator.GetNumGroups();
    int solutionSize = evaluator.GetSolutionSize();

    while (improved && !stop_flag_) {
        improved = false;

        // wybierz losową trasę do optymalizacji
        uniform_int_distribution<int> routeDist(0, numGroups - 1);
        int selectedRoute = routeDist(rng);

        // znajdź klientów na wybranej trasie
        vector<int> routeCustomers;
        for (int custIdx = 0; custIdx < solutionSize; ++custIdx) {
            if (individual.genotype[custIdx] == selectedRoute) {
                routeCustomers.push_back(custIdx);
            }
        }

        // jeśli trasa pusta, spróbuj innej
        if (routeCustomers.empty()) {
            // znajdź pierwszą niepustą trasę
            for (int route = 0; route < numGroups && routeCustomers.empty(); ++route) {
                for (int custIdx = 0; custIdx < solutionSize; ++custIdx) {
                    if (individual.genotype[custIdx] == route) {
                        routeCustomers.push_back(custIdx);
                    }
                }
                if (!routeCustomers.empty()) {
                    selectedRoute = route;
                }
            }
        }

        if (routeCustomers.empty()) break;

        // pomieszaj kolejność klientów na trasie
        std::shuffle(routeCustomers.begin(), routeCustomers.end(), rng);

        // znajdź klientów z innych tras
        vector<int> otherCustomers;
        for (int custIdx = 0; custIdx < solutionSize; ++custIdx) {
            if (individual.genotype[custIdx] != selectedRoute) {
                otherCustomers.push_back(custIdx);
            }
        }

        // pomieszaj kolejność klientów z innych tras
        std::shuffle(otherCustomers.begin(), otherCustomers.end(), rng);

        // próbuj zamieniać klientów z wybranej trasy z klientami z innych tras
        for (int custA : routeCustomers) {
            if (stop_flag_) break;

            int routeA = individual.genotype[custA]; // = selectedRoute

            for (int custB : otherCustomers) {
                if (stop_flag_) break;

                int routeB = individual.genotype[custB];

                // oblicz fitness po swapie: custA idzie do routeB, custB idzie do routeA
                double fitnessAfterFirstMove = evaluator.EvaluateDelta(individual.genotype, custA, routeA, routeB);

                // tymczasowo zastosuj pierwszą zmianę żeby policzyć drugą
                individual.genotype[custA] = routeB;
                evaluator.ApplyChange(individual.genotype, custA, routeA, routeB);

                // teraz przenosimy custB do routeA
                double fitnessAfterSwap = evaluator.EvaluateDelta(individual.genotype, custB, routeB, routeA);

                if (fitnessAfterSwap < individual.fitness) {
                    // swap jest korzystny - zastosuj drugą zmianę
                    individual.genotype[custB] = routeA;
                    evaluator.ApplyChange(individual.genotype, custB, routeB, routeA);
                    individual.fitness = fitnessAfterSwap;
                    improved = true;
                    everImproved = true;
                    UpdateBestIndividual(individual);
                    break; // restart z nową konfiguracją
                }
                else {
                    // cofnij pierwszą zmianę
                    individual.genotype[custA] = routeA;
                    evaluator.ApplyChange(individual.genotype, custA, routeB, routeA);
                }
            }

            if (improved) break; // restart outer loop
        }
    }

    return everImproved;
}

void Optimizer::ReassignRouteIndividualOld(Individual& individual, MyEvaluator& evaluator, mt19937& rng) {
    int numGroups = evaluator.GetNumGroups();
    int solutionSize = evaluator.GetSolutionSize();

    // 1. Wybierz losową trasę (pojazd) do zniszczenia
    uniform_int_distribution<int> routeDist(0, numGroups - 1);
    int destroyedRoute = routeDist(rng);

    // 2. Znajdź wszystkich klientów przypisanych do tej trasy
    vector<int> customersToReassign;
    for (int custIdx = 0; custIdx < solutionSize; ++custIdx) {
        if (individual.genotype[custIdx] == destroyedRoute) {
            customersToReassign.push_back(custIdx);
        }
    }

    // jeśli trasa jest pusta, wybierz inną
    if (customersToReassign.empty()) {
        // znajdź trasę z przynajmniej jednym klientem
        for (int route = 0; route < numGroups; ++route) {
            for (int custIdx = 0; custIdx < solutionSize; ++custIdx) {
                if (individual.genotype[custIdx] == route) {
                    customersToReassign.push_back(custIdx);
                }
            }
            if (!customersToReassign.empty()) {
                destroyedRoute = route;
                break;
            }
        }
    }

    // jeśli wciąż puste (nie powinno się zdarzyć), wróć
    if (customersToReassign.empty()) {
        return;
    }

    // 3. Pomieszaj kolejność klientów do przypisania
    std::shuffle(customersToReassign.begin(), customersToReassign.end(), rng);

    // 4. Dla każdego klienta znajdź najlepszy pojazd (inny niż oryginalny)
    for (int custIdx : customersToReassign) {
        int originalRoute = destroyedRoute;
        int bestRoute = -1;
        double bestFitness = numeric_limits<double>::max();

        // sprawdź wszystkie inne trasy
        for (int route = 0; route < numGroups; ++route) {
            if (route == originalRoute) continue;

            // użyj delta evaluation żeby sprawdzić fitness
            double newFitness = evaluator.EvaluateDelta(individual.genotype, custIdx, originalRoute, route);

            if (newFitness < bestFitness) {
                bestFitness = newFitness;
                bestRoute = route;
            }
        }

        // przypisz klienta do najlepszej trasy
        if (bestRoute != -1) {
            individual.genotype[custIdx] = bestRoute;
            evaluator.ApplyChange(individual.genotype, custIdx, originalRoute, bestRoute);
            individual.fitness = bestFitness;
        }
    }

    // 5. Zapełnij pustą trasę (destroyedRoute)
    uniform_int_distribution<int> heuristicDist(0, 1);
    FillEmptyRoute(individual, evaluator, rng, destroyedRoute, heuristicDist(rng));

    // pełna ewaluacja i update besta
    EvaluateAndUpdate(individual, evaluator);
}

void Optimizer::FillEmptyRoute(Individual& individual, MyEvaluator& evaluator, mt19937& rng, int emptyRoute, int heuristicType) {
    int numGroups = evaluator.GetNumGroups();
    int solutionSize = evaluator.GetSolutionSize();

    // oblicz docelową liczbę klientów na trasę (średnia)
    int targetCustomers = solutionSize / numGroups;
    if (targetCustomers < 1) targetCustomers = 1;

    // dodaj trochę losowości do target (+/- 20%)
    uniform_int_distribution<int> targetVariation(-targetCustomers / 5, targetCustomers / 5);
    int actualTarget = max(1, targetCustomers + targetVariation(rng));

    // zbierz wszystkich klientów którzy NIE są na pustej trasie
    // i oblicz dla nich heurystykę "jak bardzo warto ich przenieść"
    struct CustomerScore {
        int custIdx;
        int currentRoute;
        double score;  // wyższa = lepszy kandydat do przeniesienia
    };

    vector<CustomerScore> candidates;

    for (int custIdx = 0; custIdx < solutionSize; ++custIdx) {
        int currentRoute = individual.genotype[custIdx];
        if (currentRoute == emptyRoute) continue; // już na tej trasie (nie powinno się zdarzyć)

        double score = 0.0;
        double distToDepot = evaluator.GetDistanceToDepot(custIdx);

        // policz ilu klientów jest na obecnej trasie tego klienta
        int routeSize = 0;
        double routeTotalDist = 0.0;
        for (int i = 0; i < solutionSize; ++i) {
            if (individual.genotype[i] == currentRoute) {
                routeSize++;
                routeTotalDist += evaluator.GetDistanceToDepot(i);
            }
        }

        // heurystyka 0: suma dystansów trasy / liczba klientów
        // preferuj klientów z "gęstych" tras (dużo klientów, krótkie dystanse)
        if (heuristicType == 0) {
            // im więcej klientów na trasie i im bliżej depot, tym lepszy kandydat
            score = static_cast<double>(routeSize) / (distToDepot + 1.0);
        }
        // heurystyka 1: suma dystansów trasy / suma ważona klientów (ważona przez odległość do depot)
        // preferuj klientów z tras gdzie są "mało wartościowi" klienci (blisko depot)
        else {
            // im większy routeSize i im mniejsza średnia odległość do depot na trasie, tym lepszy
            double avgDistOnRoute = routeTotalDist / max(1, routeSize);
            score = static_cast<double>(routeSize) * (1.0 / (avgDistOnRoute + 1.0));
        }

        candidates.push_back({ custIdx, currentRoute, score });
    }

    if (candidates.empty()) return;

    // posortuj malejąco po score (najlepsi kandydaci pierwsi)
    std::sort(candidates.begin(), candidates.end(), [](const CustomerScore& a, const CustomerScore& b) {
        return a.score > b.score;
        });

    // wybierz klientów do przeniesienia używając geometric distribution
    // (najczęściej najlepszy, ale czasem gorsi)
    int customersToMove = min(actualTarget, static_cast<int>(candidates.size()));

    geometric_distribution<int> geomDist(0.4); // p=0.4 daje rozsądny rozkład

    vector<bool> selected(candidates.size(), false);
    int movedCount = 0;

    while (movedCount < customersToMove && movedCount < static_cast<int>(candidates.size())) {
        // wybierz indeks z geometric distribution (ograniczony do dostępnych)
        int maxIdx = static_cast<int>(candidates.size()) - 1;
        int selectedIdx = min(geomDist(rng), maxIdx);

        // znajdź pierwszy niewybrany kandydat od selectedIdx
        int actualIdx = -1;
        for (int i = selectedIdx; i < static_cast<int>(candidates.size()); ++i) {
            if (!selected[i]) {
                actualIdx = i;
                break;
            }
        }
        // jeśli nie znaleziono, szukaj od początku
        if (actualIdx == -1) {
            for (int i = 0; i < selectedIdx; ++i) {
                if (!selected[i]) {
                    actualIdx = i;
                    break;
                }
            }
        }

        if (actualIdx == -1) break; // wszystko wybrane

        selected[actualIdx] = true;

        // przenieś klienta na pustą trasę
        int custIdx = candidates[actualIdx].custIdx;
        int oldRoute = candidates[actualIdx].currentRoute;

        individual.genotype[custIdx] = emptyRoute;
        evaluator.ApplyChange(individual.genotype, custIdx, oldRoute, emptyRoute);

        movedCount++;
    }
}

void Optimizer::MutateIndividual(Individual& individual, MyEvaluator& evaluator, mt19937& rng) {
    int solutionSize = evaluator.GetSolutionSize();
    int lowerBound = evaluator.GetLowerBound();
    int upperBound = evaluator.GetUpperBound();

    // rozkład geometryczny: P(n) = 1/2^n
    // czyli 50% szans na 1 gen, 25% na 2, 12.5% na 3 itd.
    // używamy geometric_distribution z p=0.5, dodajemy 1 bo zaczyna od 0
    // niska wartość p = więcej mutacji, wysoka wartość p = mniej mutacji
    geometric_distribution<int> geomDist(0.5);
    int numMutations = geomDist(rng) + 1; // minimum 1 mutacja

    // ogranicz do rozmiaru genotypu
    numMutations = min(numMutations, solutionSize);

    // wybierz losowe indeksy genów do mutacji (bez powtórzeń)
    vector<int> allIndices(solutionSize);
    iota(allIndices.begin(), allIndices.end(), 0);
    std::shuffle(allIndices.begin(), allIndices.end(), rng);

    uniform_int_distribution<int> valueDist(lowerBound, upperBound);

    // mutuj wybrane geny
    for (int i = 0; i < numMutations; ++i) {
        int geneIdx = allIndices[i];
        int oldValue = individual.genotype[geneIdx];
        int newValue;

        // upewnij się że nowa wartość jest inna niż stara
        do {
            newValue = valueDist(rng);
        } while (newValue == oldValue && upperBound > lowerBound);

        individual.genotype[geneIdx] = newValue;
    }

    // przeliczymy cały fitness raz na końcu (to też zresetuje stan wewnętrzny evaluatora)
    individual.fitness = evaluator.Evaluate(individual.genotype);
}

string Optimizer::FormatIndividual(const Individual& individual) const {
    ostringstream oss;
    oss << "current fitness: " << fixed << setprecision(2) << individual.fitness << endl;
    for (int val : individual.genotype) {
        oss << val << " ";
    }
    oss << endl;


    vector<int> group_counts(evaluator_.GetNumGroups(), 0);
    for (int group : individual.genotype) {
        group_counts[group]++;
    }
    oss << "groups: [";
    for (size_t i = 0; i < group_counts.size(); ++i) {
        oss << group_counts[i] << (i < group_counts.size() - 1 ? ", " : "");
    }
    oss << "]" << endl;


    return oss.str();
}

void Optimizer::PrintIndividual(const Individual& individual) const {
    cout << FormatIndividual(individual);
}

void Optimizer::SaveIndividualToFile(const Individual& individual, const string& filename) {
    ofstream file(filename);
    if (!file.is_open()) {
        cout << "Error opening file for writing: " << filename << endl;
        return;
    }
    file << FormatIndividual(individual);
    file.close();
}

void Optimizer::LoadIndividualFromFile(Individual& individual, MyEvaluator& evaluator, const string& filename) {
    ifstream file(filename);
    if (!file.is_open()) {
        cout << "Error opening file for reading: " << filename << endl;
        return;
    }
    string line;
    // pierwsza linia: "current fitness: XX.XX"
    if (!getline(file, line)) {
        cout << "Error reading fitness line from file: " << filename << endl;
        return;
    }
    istringstream iss(line);
    string dummy;
    iss >> dummy >> dummy; // "current fitness:"
    double fitness;
    iss >> fitness;
    // druga linia: wartości genotypu
    if (!getline(file, line)) {
        cout << "Error reading genotype line from file: " << filename << endl;
        return;
    }
    istringstream iss2(line);
    vector<int> genotype;
    int val;
    while (iss2 >> val) {
        genotype.push_back(val);
    }

    //check if genotype size matches evaluator solution size, if not dont change individual
    if (genotype.size() == static_cast<size_t>(evaluator.GetSolutionSize())) {
        individual.fitness = evaluator.Evaluate(genotype);
        //cout << individual.fitness << endl;
        individual.genotype = genotype;
    }

    file.close();
}