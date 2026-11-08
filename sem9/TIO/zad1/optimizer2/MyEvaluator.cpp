#include "MyEvaluator.hpp"
#include <algorithm>
#include <cmath>

using namespace LcVRPContest;

list<MyEvaluator::CacheEntry> MyEvaluator::s_cache_order_;
unordered_map<MyEvaluator::CacheKey, list<MyEvaluator::CacheEntry>::iterator> MyEvaluator::s_fitness_cache_;
shared_mutex MyEvaluator::s_cache_mutex_;
size_t MyEvaluator::s_max_cache_size_ = MyEvaluator::DEFAULT_MAX_CACHE_SIZE;
atomic<size_t> MyEvaluator::s_cache_hits_{ 0 };
atomic<size_t> MyEvaluator::s_cache_misses_{ 0 };

MyEvaluator::MyEvaluator(const ProblemData& problem_data, int num_groups, size_t max_cache_size)
	: problem_data_(problem_data),
	num_groups_(num_groups),
	num_customers_(problem_data.GetNumCustomers()),
	dimension_(problem_data.GetDimension()),
	depot_index_(problem_data.GetDepot() - 1),
	capacity_(problem_data.GetCapacity()),
	max_distance_(problem_data.HasDistanceConstraint() ? problem_data.GetDistance() : -1.0),
	has_distance_constraint_(problem_data.HasDistanceConstraint()),
	permutation_(problem_data.GetPermutation()),
	demands_(problem_data.GetDemands()),
	cached_total_cost_(WRONG_VAL)
{
	s_max_cache_size_ = max_cache_size;

	BuildDistanceMatrix();
	routes_.resize(num_groups_);
	route_costs_.resize(num_groups_, 0.0);
}

void MyEvaluator::BuildDistanceMatrix() {
	distance_matrix_.resize(dimension_);

	const auto& coords = problem_data_.GetCoordinates();
	const string& edge_type = problem_data_.GetEdgeWeightType();

	for (int i = 0; i < dimension_; ++i) {
		distance_matrix_[i].resize(dimension_);
		for (int j = 0; j < dimension_; ++j) {
			if (i == j) {
				distance_matrix_[i][j] = 0.0;
			}
			else if (edge_type == "EUC_2D") {
				double dx = coords[i].x - coords[j].x;
				double dy = coords[i].y - coords[j].y;
				distance_matrix_[i][j] = sqrt(dx * dx + dy * dy);
			}
			else if (edge_type == "EXPLICIT") {
				// use existing edge weights
				const auto& ew = problem_data_.GetEdgeWeights();
				if (i > j) {
					distance_matrix_[i][j] = ew[i][j];
				}
				else {
					distance_matrix_[i][j] = ew[j][i];
				}
			}
			else {
				distance_matrix_[i][j] = problem_data_.CalculateDistance(i, j);
			}
		}
	}
}

void MyEvaluator::BuildRoutes(const vector<int>& grouping) {
	for (auto& route : routes_) {
		route.clear();
	}

	// distribute customers using permutation and grouping
	for (size_t i = 0; i < permutation_.size(); ++i) {
		int customer_id = permutation_[i];
		int customer_index = customer_id - 2; // customer id starts from 2

		if (customer_index >= 0 && customer_index < num_customers_) {
			int group = grouping[customer_index];
			if (group >= 0 && group < num_groups_) {
				routes_[group].push_back(customer_id);
			}
		}
	}
}

double MyEvaluator::CalculateRouteCost(const vector<int>& route) const {
	if (route.empty()) {
		return 0.0;
	}

	double total_cost = 0.0;
	int current_load = 0;
	double current_distance = 0.0;
	int last_position_index = depot_index_;

	for (size_t i = 0; i < route.size(); ++i) {
		int customer_id = route[i];
		int customer_index = customer_id - 1;
		int customer_demand = demands_[customer_index];

		// check capacity constraint
		if (current_load + customer_demand > capacity_) {
			// return to depot
			double dist_to_depot = GetDistance(last_position_index, depot_index_);
			current_distance += dist_to_depot;
			total_cost += current_distance;

			// reset for new subtour
			current_load = 0;
			current_distance = 0.0;
			last_position_index = depot_index_;
		}

		double dist_to_customer = GetDistance(last_position_index, customer_index);

		// check distance constraint
		if (has_distance_constraint_) {
			double dist_back_to_depot = GetDistance(customer_index, depot_index_);

			if (current_distance + dist_to_customer + dist_back_to_depot > max_distance_) {
				// close current subtour
				double dist_to_depot = GetDistance(last_position_index, depot_index_);
				current_distance += dist_to_depot;
				total_cost += current_distance;

				// reset
				current_load = 0;
				current_distance = 0.0;
				last_position_index = depot_index_;

				dist_to_customer = GetDistance(depot_index_, customer_index);
			}
		}

		current_distance += dist_to_customer;
		current_load += customer_demand;
		last_position_index = customer_index;
	}

	// close final subtour
	double dist_to_depot = GetDistance(last_position_index, depot_index_);
	current_distance += dist_to_depot;
	total_cost += current_distance;

	return total_cost;
}

double MyEvaluator::Evaluate(const vector<int>& solution) {
	if (solution.size() != static_cast<size_t>(num_customers_)) {
		return WRONG_VAL;
	}

	// validate solution
	for (int group : solution) {
		if (group < 0 || group >= num_groups_) {
			return WRONG_VAL;
		}
	}

	// try to get from cache first
	double cached_fitness;
	if (TryGetCachedFitness(solution, cached_fitness)) {
		// still need to rebuild internal state for delta evaluations
		BuildRoutes(solution);
		cached_total_cost_ = 0.0;
		for (int g = 0; g < num_groups_; ++g) {
			route_costs_[g] = CalculateRouteCost(routes_[g]);
			cached_total_cost_ += route_costs_[g];
		}
		return cached_fitness;
	}

	// build routes and calculate all costs
	BuildRoutes(solution);

	cached_total_cost_ = 0.0;
	for (int g = 0; g < num_groups_; ++g) {
		route_costs_[g] = CalculateRouteCost(routes_[g]);
		cached_total_cost_ += route_costs_[g];
	}

	// add to cache
	AddToCache(solution, cached_total_cost_);

	return cached_total_cost_;
}

double MyEvaluator::EvaluateDelta(const vector<int>& solution, int geneIdx, int oldValue, int newValue) {
	if (oldValue == newValue) {
		return cached_total_cost_;
	}

	if (newValue < 0 || newValue >= num_groups_) {
		return WRONG_VAL;
	}

	// temporarily modify routes
	int customer_id = geneIdx + 2; // gene index to customer id

	// build temporary routes for affected groups
	vector<int> old_route, new_route;
	old_route.reserve(routes_[oldValue].size());
	new_route.reserve(routes_[newValue].size() + 1);

	// copy old route without the customer
	for (int cid : routes_[oldValue]) {
		if (cid != customer_id) {
			old_route.push_back(cid);
		}
	}

	// copy new route and insert customer in correct position (based on permutation order)
	bool inserted = false;
	for (int cid : routes_[newValue]) {
		// find permutation index for comparison
		if (!inserted) {
			// we need to insert customer_id before cid if customer_id comes before cid in permutation
			// but this requires knowing permutation positions...
			// simpler: just rebuild the route from scratch (i dont have time to implement permutation index lookup now)
		}
		new_route.push_back(cid);
	}

	// actually, easier approach: rebuild both affected routes from scratch
	// using the solution with the change applied
	old_route.clear();
	new_route.clear();

	for (size_t i = 0; i < permutation_.size(); ++i) {
		int cid = permutation_[i];
		int cidx = cid - 2;

		if (cidx >= 0 && cidx < num_customers_) {
			int group = (cidx == geneIdx) ? newValue : solution[cidx];

			if (group == oldValue) {
				old_route.push_back(cid);
			}
			else if (group == newValue) {
				new_route.push_back(cid);
			}
		}
	}

	// calculate new costs for these two routes
	double new_old_route_cost = CalculateRouteCost(old_route);
	double new_new_route_cost = CalculateRouteCost(new_route);

	// calculate delta
	double delta = (new_old_route_cost - route_costs_[oldValue]) +
		(new_new_route_cost - route_costs_[newValue]);

	return cached_total_cost_ + delta;
}

void MyEvaluator::ApplyChange(const vector<int>& solution, int geneIdx, int oldValue, int newValue) {
	if (oldValue == newValue) {
		return;
	}

	// rebuild affected routes
	int customer_id = geneIdx + 2;

	routes_[oldValue].clear();
	routes_[newValue].clear();

	for (size_t i = 0; i < permutation_.size(); ++i) {
		int cid = permutation_[i];
		int cidx = cid - 2;

		if (cidx >= 0 && cidx < num_customers_) {
			int group = solution[cidx]; // solution already has the new value

			if (group == oldValue) {
				routes_[oldValue].push_back(cid);
			}
			else if (group == newValue) {
				routes_[newValue].push_back(cid);
			}
		}
	}

	// recalculate costs for affected routes
	route_costs_[oldValue] = CalculateRouteCost(routes_[oldValue]);
	route_costs_[newValue] = CalculateRouteCost(routes_[newValue]);

	// update total cost
	cached_total_cost_ = 0.0;
	for (int g = 0; g < num_groups_; ++g) {
		cached_total_cost_ += route_costs_[g];
	}
}

uint64_t MyEvaluator::HashGenotype(const vector<int>& genotype) {
	// FNV-1a hash combined with polynomial rolling for better distribution
	// FNV-1a constants for 64-bit
	// some hashing magic baby
	constexpr uint64_t FNV_OFFSET_BASIS = 14695981039346656037ULL;
	constexpr uint64_t FNV_PRIME = 1099511628211ULL;

	// additional mixing constant (large prime)
	constexpr uint64_t MIX_PRIME = 0x9E3779B97F4A7C15ULL; // golden ratio based

	uint64_t hash = FNV_OFFSET_BASIS;
	uint64_t rolling = 0;

	for (size_t i = 0; i < genotype.size(); ++i) {
		int val = genotype[i];

		// FNV-1a step: XOR then multiply
		hash ^= static_cast<uint64_t>(val);
		hash *= FNV_PRIME;

		// polynomial rolling with position mixing
		// this helps distinguish [1,2,3] from [3,2,1]
		// MORE MAGIC!
		rolling += (static_cast<uint64_t>(val) + 1) * (i + 1);
		rolling *= MIX_PRIME;
		rolling ^= (rolling >> 27);
	}

	// final mixing - combine both hashes
	hash ^= rolling;
	hash *= FNV_PRIME;

	// final avalanche
	hash ^= hash >> 33;
	hash *= 0xFF51AFD7ED558CCDULL;
	hash ^= hash >> 33;
	hash *= 0xC4CEB9FE1A85EC53ULL;
	hash ^= hash >> 33;

	return hash;
}

bool MyEvaluator::TryGetCachedFitness(const vector<int>& genotype, double& out_fitness) {
	uint64_t hash = HashGenotype(genotype);

	shared_lock<shared_mutex> lock(s_cache_mutex_);

	auto it = s_fitness_cache_.find(hash);
	if (it != s_fitness_cache_.end()) {
		out_fitness = it->second->second;
		++s_cache_hits_; // atomic increment
		return true;
	}

	++s_cache_misses_; // atomic increment
	return false;
}

void MyEvaluator::AddToCache(const vector<int>& genotype, double fitness) {
	uint64_t hash = HashGenotype(genotype);

	unique_lock<shared_mutex> lock(s_cache_mutex_);

	auto it = s_fitness_cache_.find(hash);
	if (it != s_fitness_cache_.end()) {
		it->second->second = fitness;
		s_cache_order_.splice(s_cache_order_.end(), s_cache_order_, it->second);
		return;
	}

	while (s_fitness_cache_.size() >= s_max_cache_size_ && !s_cache_order_.empty()) {
		auto oldest = s_cache_order_.begin();
		s_fitness_cache_.erase(oldest->first);
		s_cache_order_.pop_front();
	}

	s_cache_order_.push_back({ hash, fitness });
	s_fitness_cache_[hash] = prev(s_cache_order_.end());
}

void MyEvaluator::ClearCache() {
	unique_lock<shared_mutex> lock(s_cache_mutex_);
	s_fitness_cache_.clear();
	s_cache_order_.clear();
	s_cache_hits_ = 0;
	s_cache_misses_ = 0;
}

size_t MyEvaluator::GetCacheSize() {
	shared_lock<shared_mutex> lock(s_cache_mutex_);
	return s_fitness_cache_.size();
}
