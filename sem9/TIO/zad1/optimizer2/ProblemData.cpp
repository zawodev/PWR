#include "ProblemData.hpp"

using namespace LcVRPContest;

ProblemData::ProblemData()
	: dimension_(0),
      capacity_(0),
      distance_(0.0),
      has_distance_constraint_(false),
      depot_(1),
      num_groups_(0) {}

double ProblemData::CalculateDistance(int i, int j) const {
    if (i < 0 || i >= dimension_ || j < 0 || j >= dimension_) {
        return WRONG_VAL;
    }
    if (i == j) return 0.0;
    
    if (edge_weight_type_ == "EUC_2D") {
        if (coordinates_.size() != static_cast<size_t>(dimension_)) {
            return WRONG_VAL;
        }
        double dx = coordinates_[i].x - coordinates_[j].x;
        double dy = coordinates_[i].y - coordinates_[j].y;
        return sqrt(dx * dx + dy * dy);
    }
    else if (edge_weight_type_ == "EXPLICIT") {
        if (edge_weights_.empty() || i >= (int)edge_weights_.size() || j >= (int)edge_weights_[i].size()) {
            return WRONG_VAL;
        }
        if (i > j) {
            return edge_weights_[i][j];
        }
        else {
            return edge_weights_[j][i];
        }
    }
    return WRONG_VAL;
}

void ProblemData::BuildEdgeWeightMatrix() {
    if (edge_weight_type_ == "EUC_2D") {
        if (coordinates_.size() != static_cast<size_t>(dimension_)) {
            return;
        }
        
        edge_weights_.resize(dimension_);
        for (int i = 0; i < dimension_; ++i) {
            edge_weights_[i].resize(dimension_);
            for (int j = 0; j < dimension_; ++j) {
                if (i == j) {
                    edge_weights_[i][j] = 0.0;
                }
                else {
                    double dx = coordinates_[i].x - coordinates_[j].x;
                    double dy = coordinates_[i].y - coordinates_[j].y;
                    edge_weights_[i][j] = sqrt(dx * dx + dy * dy);
                }
            }
        }
    }
}
