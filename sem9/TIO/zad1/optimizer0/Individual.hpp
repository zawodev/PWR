#pragma once

#include <vector>

using namespace std;

namespace LcVRPContest {
	class Individual {
	public:
		vector<int> genotype;
		double fitness;
	};
}