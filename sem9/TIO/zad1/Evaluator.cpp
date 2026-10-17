#include "Evaluator.hpp"
#include <algorithm>
#include <numeric>

using namespace LcVRPContest;

Evaluator::Evaluator(const ProblemData& problem_data, int num_groups)
	: problem_data_(problem_data), 
	  num_groups_(num_groups), 
	  num_customers_(problem_data.GetNumCustomers()) {}

double Evaluator::Evaluate(const vector<int>* solution) const {
	if (!solution) {
		return WRONG_VAL;
	}
	return Evaluate(*solution);
}

double Evaluator::Evaluate(const vector<int>& solution) const {
	if (solution.size() != static_cast<size_t>(GetSolutionSize())) {
		return WRONG_VAL;
	}
	return Evaluate(solution.data());
}

double Evaluator::Evaluate(const int* solution) const {
	if (!ValidateConstraints()) {
		return WRONG_VAL;
	}

	// convert to vector<int> for easier processing
	vector<int> grouping(solution, solution + num_customers_);

	if (!IsValidSolution(grouping)) {
		return WRONG_VAL;
	}

	vector<vector<int>> routes;
	BuildRoutes(grouping, routes);

	double total_cost = 0.0;
	for (const auto& route : routes) {
		double route_cost = CalculateRouteCost(route);
		
		if (route_cost < 0.0) {
			return WRONG_VAL;
		}
			
		total_cost += route_cost;
	}

	return total_cost;
}

bool Evaluator::IsValidSolution(const vector<int>& grouping) const {
	// basic check if all grouping values are within bounds
	for (int group : grouping) {
		if (group < GetLowerBound() || group > GetUpperBound()) {
			return false;
		}
	}
	return true;
}

bool Evaluator::ValidateConstraints() const {
	int depot = problem_data_.GetDepot();
	int depot_index = depot - 1; //again, depot index in 0-based
	const vector<int>& demands = problem_data_.GetDemands();
	int capacity = problem_data_.GetCapacity();
	
	// check each customer
	for (int customer_id = 2; customer_id <= problem_data_.GetDimension(); ++customer_id) {
		int customer_index = customer_id - 1;
		
		// check if any customer has demand > capacity
		if (demands[customer_index] > capacity) {
			return false;
		}

		// check if distance constraint exists
		if (problem_data_.HasDistanceConstraint()) {
			double max_distance = problem_data_.GetDistance();
			double dist_to_depot = problem_data_.CalculateDistance(depot_index, customer_index);
			
			if (dist_to_depot < 0.0) {
				return false;
			}
			
			// each customer must be reachable: depot -> customer -> depot <= max_distance
			// so: dist_to_depot * 2 <= max_distance
			if (dist_to_depot * 2.0 > max_distance) {
				return false;
			}
		}
	}
	
	return true;
}

void Evaluator::BuildRoutes(const vector<int>& grouping, vector<vector<int>>& routes) const {
	routes.clear();
	routes.resize(num_groups_);

	const vector<int>& permutation = problem_data_.GetPermutation();

	// distribute customers using permutation and grouping
	// permutation contains customer ids from 2 to dimension (1 is depo)
	// grouping contains customer index (0 to num_customers-1)
		
	for (size_t i = 0; i < permutation.size(); ++i) {
		int customer_id = permutation[i];
		// customer id start from 2 (depot is 1), so customer index = customer_id - 2
		int customer_index = customer_id - 2;
			
		if (customer_index >= 0 && customer_index < num_customers_) {
			int group = grouping[customer_index];
			routes[group].push_back(customer_id);
		}
	}
}

double Evaluator::CalculateRouteCost(const vector<int>& route) const {
	if (route.empty()) {
		return 0.0;
	}

	double total_cost = 0.0;
	int depot = problem_data_.GetDepot();
	int depot_index = depot - 1; // depot index in 0-based for easier calculations
	int capacity = problem_data_.GetCapacity();
	double max_distance = problem_data_.HasDistanceConstraint() ? problem_data_.GetDistance() : -1.0;
	const vector<int>& demands = problem_data_.GetDemands();

	int current_load = 0;
	double current_distance = 0.0;
	int last_position_index = depot_index;

	for (size_t i = 0; i < route.size(); ++i) {
		int customer_id = route[i];
		int customer_index = customer_id - 1;
		int customer_demand = demands[customer_index];

		// we check if adding this new customer would exceed CAPACITY constraint
		if (current_load + customer_demand > capacity) {
			// return to depot, close current subtour
			double dist_to_depot = problem_data_.CalculateDistance(last_position_index, depot_index);
			if (dist_to_depot < 0.0) return WRONG_VAL;
			
			current_distance += dist_to_depot;
			total_cost += current_distance;

			// reset for new subtour
			current_load = 0;
			current_distance = 0.0;
			last_position_index = depot_index;
		}

		// calculate distance to the next customer
		double dist_to_customer = problem_data_.CalculateDistance(last_position_index, customer_index);
		if (dist_to_customer < 0.0) return WRONG_VAL;

		// check if adding this customer would exceed DISTANCE constraint
		if (max_distance > 0.0) {
			double dist_back_to_depot = problem_data_.CalculateDistance(customer_index, depot_index);
			if (dist_back_to_depot < 0.0) return WRONG_VAL;

			// would this customer + return to depot exceed max_distance?
			if (current_distance + dist_to_customer + dist_back_to_depot > max_distance) {
				// close current subtour and start new one
				double dist_to_depot = problem_data_.CalculateDistance(last_position_index, depot_index);
				if (dist_to_depot < 0.0) return WRONG_VAL;
				
				current_distance += dist_to_depot;
				total_cost += current_distance;

				// reset for new subtour starting from depot
				current_load = 0;
				current_distance = 0.0;
				last_position_index = depot_index;

				// recalculate distance to customer from depot
				dist_to_customer = problem_data_.CalculateDistance(depot_index, customer_index);
				if (dist_to_customer < 0.0) return WRONG_VAL;
			}
		}

		// add customer to current subtour
		current_distance += dist_to_customer;
		current_load += customer_demand;
		last_position_index = customer_index;
	}

	// close final subtour and return to depot
	double dist_to_depot = problem_data_.CalculateDistance(last_position_index, depot_index);
	if (dist_to_depot < 0.0) return WRONG_VAL;
	
	current_distance += dist_to_depot;
	total_cost += current_distance;

	return total_cost;
}
