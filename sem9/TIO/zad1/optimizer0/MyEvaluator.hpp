#pragma once

#include "../ProblemData.hpp"
#include <vector>
#include <unordered_map>
#include <list>
#include <cstdint>
#include <shared_mutex>
#include <atomic>

using namespace std;

namespace LcVRPContest {

	class MyEvaluator {
	public:
		static constexpr double WRONG_VAL = 1e18;

		static constexpr size_t DEFAULT_MAX_CACHE_SIZE = 2000000; // ~+- 8gig ram

		MyEvaluator(const ProblemData& problem_data, int num_groups, size_t max_cache_size = DEFAULT_MAX_CACHE_SIZE);

		double Evaluate(const vector<int>& solution);

		// delta evaluation - only recalculates affected routes
		double EvaluateDelta(const vector<int>& solution, int geneIdx, int oldValue, int newValue);

		// apply the change (update internal state after gene change is committed)
		void ApplyChange(const vector<int>& solution, int geneIdx, int oldValue, int newValue);

		// getters
		int GetSolutionSize() const { return num_customers_; }
		int GetLowerBound() const { return 0; }
		int GetUpperBound() const { return num_groups_ - 1; }
		int GetNumGroups() const { return num_groups_; }

		double GetCachedFitness() const { return cached_total_cost_; }

		// cache statistics (global cache - static methods)
		static size_t GetCacheSize();
		static size_t GetCacheHits() { return s_cache_hits_.load(); }
		static size_t GetCacheMisses() { return s_cache_misses_.load(); }
		static void ClearCache();
		static void SetMaxCacheSize(size_t max_size) { s_max_cache_size_ = max_size; }

		// getters for advanced route selection
		double GetRouteCost(int routeIdx) const { return route_costs_[routeIdx]; }
		const vector<int>& GetRouteCustomers(int routeIdx) const { return routes_[routeIdx]; }

		// get distance from customer
		double GetDistanceToDepot(int customerIdx) const {
			int nodeIdx = customerIdx + 1;
			return distance_matrix_[nodeIdx][depot_index_];
		}

	private:
		const ProblemData& problem_data_;
		int num_groups_;
		int num_customers_;
		int dimension_;
		int depot_index_;
		int capacity_;
		double max_distance_;
		bool has_distance_constraint_;

		// precalculated distance matrix (sqrt)
		vector<vector<double>> distance_matrix_;

		// cached route costs (one per group)
		vector<double> route_costs_;

		// cached total cost
		double cached_total_cost_;
		vector<vector<int>> routes_;

		// reference to permutation
		const vector<int>& permutation_;
		const vector<int>& demands_;

		// internal methods
		void BuildDistanceMatrix();
		void BuildRoutes(const vector<int>& grouping);
		double CalculateRouteCost(const vector<int>& route) const;

		// get distance from precalculated matrix
		inline double GetDistance(int i, int j) const {
			return distance_matrix_[i][j];
		}

		static uint64_t HashGenotype(const vector<int>& genotype);

		using CacheKey = uint64_t;
		using CacheEntry = pair<CacheKey, double>; // hash, fitness

		static list<CacheEntry> s_cache_order_; // front = oldest, back = newest
		static unordered_map<CacheKey, list<CacheEntry>::iterator> s_fitness_cache_;

		static shared_mutex s_cache_mutex_;

		static size_t s_max_cache_size_;
		static atomic<size_t> s_cache_hits_;
		static atomic<size_t> s_cache_misses_;

		static bool TryGetCachedFitness(const vector<int>& genotype, double& out_fitness);
		static void AddToCache(const vector<int>& genotype, double fitness);
	};
}
