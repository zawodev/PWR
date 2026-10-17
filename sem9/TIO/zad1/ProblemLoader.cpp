#include "ProblemLoader.hpp"
#include <fstream>
#include <sstream>
#include <iostream>
#include <algorithm>
#include <random>

using namespace LcVRPContest;

ProblemLoader::ProblemLoader(const string& folder_name, const string& instance_name, bool use_random_permutation)
	: folder_name_(folder_name), 
    instance_name_(instance_name),
    use_random_permutation_(use_random_permutation)
{
	base_path_ = "data/lcvrp/" + folder_name_ + "/";
}

ProblemData ProblemLoader::LoadProblem() {
    ProblemData problem_data;
    string file_path = base_path_ + instance_name_ + ".lcvrp";
    
    ParseLcVrpFile(file_path, problem_data);
    
    // we need to build the edge weight matrix if EUC_2D
    if (problem_data.GetEdgeWeightType() == "EUC_2D") {
        problem_data.BuildEdgeWeightMatrix();
    }
    
    // generate random permutation if needed (from some fixed seed)
    if (use_random_permutation_) {
        int num_customers = problem_data.GetNumCustomers();
        vector<int> permutation;
        // min: 2, max: num_customers + 1, since 1 is depot
        for (int i = 2; i <= num_customers + 1; ++i) {
            permutation.push_back(i);
        }
        mt19937 gen(RANDOM_PERMUTATION_SEED);
        shuffle(permutation.begin(), permutation.end(), gen);
        problem_data.SetPermutation(permutation);
    }
    
    return problem_data;
}

void ProblemLoader::ParseLcVrpFile(const string& file_path, ProblemData& problem_data) {
    ifstream file(file_path);
    if (!file.is_open()) {
        cout << "Error: Cannot open file: " << file_path << endl;
        exit(1);
    }

    string line;
    while (getline(file, line)) {
        // skip empty lines
        if (line.empty()) continue;

        // parse header fields
        if (line.find("NAME") != string::npos) {
            size_t colon_pos = line.find(':');
            if (colon_pos != string::npos) {
                string name = line.substr(colon_pos + 1);
                // remove all kind of whitespaces
                size_t start = name.find_first_not_of(" \t\r\n");
                if (start != string::npos) {
                    name = name.substr(start);
                    size_t end = name.find_last_not_of(" \t\r\n");
                    name = name.substr(0, end + 1);
                }
                problem_data.SetName(name);
            }
        }
        else if (line.find("DIMENSION") != string::npos) {
            size_t colon_pos = line.find(':');
            if (colon_pos != string::npos) {
                int dimension = stoi(line.substr(colon_pos + 1));
                problem_data.SetDimension(dimension);
            }
        }
        else if (line.find("CAPACITY") != string::npos) {
            size_t colon_pos = line.find(':');
            if (colon_pos != string::npos) {
                int capacity = stoi(line.substr(colon_pos + 1));
                problem_data.SetCapacity(capacity);
            }
        }
        else if (line.find("DISTANCE") != string::npos) {
            size_t colon_pos = line.find(':');
            if (colon_pos != string::npos) {
                double distance = stod(line.substr(colon_pos + 1));
                problem_data.SetDistance(distance);
            }
        }
        else if (line.find("EDGE_WEIGHT_TYPE") != string::npos) {
            size_t colon_pos = line.find(':');
            if (colon_pos != string::npos) {
                string type = line.substr(colon_pos + 1);
                size_t start = type.find_first_not_of(" \t\r\n");
                if (start != string::npos) {
                    type = type.substr(start);
                    size_t end = type.find_last_not_of(" \t\r\n");
                    type = type.substr(0, end + 1);
                }
                problem_data.SetEdgeWeightType(type);
            }
        }
        else if (line.find("EDGE_WEIGHT_SECTION") != string::npos) {
            ParseEdgeWeightSection(file, problem_data);
        }
        else if (line.find("NODE_COORD_SECTION") != string::npos) {
            ParseNodeCoordSection(file, problem_data);
        }
        else if (line.find("DEMAND_SECTION") != string::npos) {
            ParseDemandSection(file, problem_data);
        }
        else if (line.find("DEPOT_SECTION") != string::npos) {
            ParseDepotSection(file, problem_data);
        }
        else if (line.find("NUM_GROUPS") != string::npos) {
            size_t colon_pos = line.find(':');
            if (colon_pos != string::npos) {
                int num_groups = stoi(line.substr(colon_pos + 1));
                problem_data.SetNumGroups(num_groups);
            }
        }
        else if (line.find("PERMUTATION") != string::npos) {
            size_t colon_pos = line.find(':');
            if (colon_pos != string::npos) {
                vector<int> permutation;
                string perm_data = line.substr(colon_pos + 1);
                istringstream iss(perm_data);
                int customer_id;
                while (iss >> customer_id) {
                    permutation.push_back(customer_id);
                }
                problem_data.SetPermutation(permutation);
            }
        }
        else if (line.find("EOF") != string::npos) {
            break;
        }
    }

    file.close();
}

void ProblemLoader::ParseEdgeWeightSection(ifstream& file, ProblemData& problem_data) {
    int dimension = problem_data.GetDimension();
    vector<vector<double>> edge_weights(dimension, vector<double>(dimension, 0.0));

    // for reading triangular matrix
    for (int i = 1; i < dimension; ++i) {
        for (int j = 0; j < i; ++j) {
            double weight;
            file >> weight;
            edge_weights[i][j] = weight;
            edge_weights[j][i] = weight; // we assume its symmetric
        }
    }

    problem_data.SetEdgeWeights(edge_weights);
}

void ProblemLoader::ParseNodeCoordSection(ifstream& file, ProblemData& problem_data) {
    int dimension = problem_data.GetDimension();
    vector<Coordinate> coordinates(dimension);

    for (int i = 0; i < dimension; ++i) {
        int node_id;
        double x, y;
        file >> node_id >> x >> y;
        // (again) node ids start from 1, array indices from 0 - i hate this
        coordinates[node_id - 1] = Coordinate(x, y);
    }

    problem_data.SetCoordinates(coordinates);
}

void ProblemLoader::ParseDemandSection(ifstream& file, ProblemData& problem_data) {
    int dimension = problem_data.GetDimension();
    vector<int> demands(dimension);

    for (int i = 0; i < dimension; ++i) {
        int node_id, demand;
        file >> node_id >> demand;
        // (same as above)
        demands[node_id - 1] = demand;
    }

    problem_data.SetDemands(demands);
}

void ProblemLoader::ParseDepotSection(ifstream& file, ProblemData& problem_data) {
    int depot;
    file >> depot;
    problem_data.SetDepot(depot);
    
    // read -1 terminator
    int terminator;
    file >> terminator;
}
