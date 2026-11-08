#pragma once

#include <string>
#include <vector>

using namespace std;

namespace LcVRPContest {
	// seed for random permutation generation (any fixed value, you can change if you want to experiment)
	constexpr unsigned int RANDOM_PERMUTATION_SEED = 42;
	struct Coordinate {
		double x;
		double y;

		Coordinate() : x(0.0), y(0.0) {}
		Coordinate(double x, double y) : x(x), y(y) {}
	};

	class ProblemData {
	public:
		ProblemData();

		// getters
		string GetName() const { return name_; }
		int GetDimension() const { return dimension_; }
		int GetCapacity() const { return capacity_; }
		double GetDistance() const { return distance_; }
		bool HasDistanceConstraint() const { return has_distance_constraint_; }
		string GetEdgeWeightType() const { return edge_weight_type_; }
		int GetDepot() const { return depot_; }
		int GetNumCustomers() const { return dimension_ - 1; } // dimension includes depot
		int GetNumGroups() const { return num_groups_; }
		
		const vector<Coordinate>& GetCoordinates() const { return coordinates_; }
		const vector<int>& GetDemands() const { return demands_; }
		const vector<int>& GetPermutation() const { return permutation_; }
		const vector<vector<double>>& GetEdgeWeights() const { return edge_weights_; }

		// setters
		void SetName(const string& name) { name_ = name; }
		void SetDimension(int dimension) { 
			dimension_ = dimension;
			coordinates_.resize(dimension);
			demands_.resize(dimension);
		}
		void SetCapacity(int capacity) { capacity_ = capacity; }
		void SetDistance(double distance) { 
			distance_ = distance; 
			has_distance_constraint_ = true;
		}
		void SetEdgeWeightType(const string& type) { edge_weight_type_ = type; }
		void SetDepot(int depot) { depot_ = depot; }
		void SetNumGroups(int num_groups) { num_groups_ = num_groups; }
		
		void SetCoordinates(const vector<Coordinate>& coordinates) { coordinates_ = coordinates; }
		void SetDemands(const vector<int>& demands) { demands_ = demands; }
		void SetPermutation(const vector<int>& permutation) { permutation_ = permutation; }
		void SetEdgeWeights(const vector<vector<double>>& edge_weights) { edge_weights_ = edge_weights; }

		// utility methods
		double CalculateDistance(int i, int j) const;
		void BuildEdgeWeightMatrix();

		static constexpr double WRONG_VAL = -1.0;

	private:
		string name_;
		int dimension_; // total number of nodes (customers + depot)
		int capacity_; // singular vehicle capacity
		double distance_; // maximum distance constraint (optional)
		bool has_distance_constraint_;
		string edge_weight_type_; // EUC_2D, EXPLICIT, maybe more?
		int depot_; // depot node id (usually 1)
		int num_groups_; // number of groups/vehicles (loaded from .lcvrp file now instead of being set in entry file)

		vector<Coordinate> coordinates_; // node coordinates (indexed from 0, but node 1 is at index 0)
		vector<int> demands_; // customer demands (indexed from 0, but node 1 is at index 0)
		vector<int> permutation_; // fixed permutation for LcVRP (customer indexes 1..n-1)
		vector<vector<double>> edge_weights_; // distance matrix
	};
}