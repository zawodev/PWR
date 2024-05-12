from typing import List, Tuple


def get_confusion_matrix(y_true: List[int], y_pred: List[int], num_classes: int) -> List[List[int]]:
    """
    Generate a confusion matrix in a form of a list of lists. 

    :param y_true: a list of ground truth values
    :param y_pred: a list of prediction values
    :param num_classes: number of supported classes

    :return: confusion matrix
    """

    if len(y_true) != len(y_pred):
        raise ValueError("Invalid input shapes!")

    matrix = [[0] * num_classes for _ in range(num_classes)]

    for actual, predicted in zip(y_true, y_pred):
        if actual >= num_classes or predicted >= num_classes or actual < 0 or predicted < 0:
            raise ValueError("Invalid prediction classes!")
        matrix[actual][predicted] += 1

    return matrix


def get_quality_factors(y_true: List[int], y_pred: List[int]) -> Tuple[int, int, int, int]:
    """
    Calculate True Negative, False Positive, False Negative and True Positive

    metrics basing on the ground truth and predicted lists.

    :param y_true: a list of ground truth values
    :param y_pred: a list of prediction values

    :return: a tuple of TN, FP, FN, TP
    """

    TN, FP, FN, TP = 0, 0, 0, 0
    for actual, predicted in zip(y_true, y_pred):
        if actual == 0:
            if predicted == 0:
                TN += 1
            else:
                FP += 1
        elif actual == 1:
            if predicted == 1:
                TP += 1
            else:
                FN += 1
    return TN, FP, FN, TP

def accuracy_score(y_true: List[int], y_pred: List[int]) -> float:
    """
    Calculate the accuracy for given lists

    :param y_true: a list of ground truth values
    :param y_pred: a list of prediction values

    :return: accuracy score
    """

    TN, FP, FN, TP = get_quality_factors(y_true, y_pred)
    total = TN + FP + FN + TP
    if total == 0:
        return 0.0
    return (TP + TN) / total


def precision_score(y_true: List[int], y_pred: List[int]) -> float:
    """
    Calculate the precision for given lists

    :param y_true: a list of ground truth values
    :param y_pred: a list of prediction values

    :return: precision score
    """

    TN, FP, FN, TP = get_quality_factors(y_true, y_pred)
    positive_predictions = TP + FP
    if positive_predictions == 0:
        return 0.0
    return TP / positive_predictions


def recall_score(y_true: List[int], y_pred: List[int]) -> float:
    """
    Calculate the recall for given lists

    :param y_true: a list of ground truth values
    :param y_pred: a list of prediction values

    :return: recall score
    """

    TN, FP, FN, TP = get_quality_factors(y_true, y_pred)
    actual_positives = TP + FN
    if actual_positives == 0:
        return 0.0
    return TP / actual_positives


def f1_score(y_true: List[int], y_pred: List[int]) -> float:
    """
    Calculate the F1-score for given lists

    :param y_true: a list of ground truth values
    :param y_pred: a list of prediction values

    :return: F1-score
    """

    precision = precision_score(y_true, y_pred)
    recall = recall_score(y_true, y_pred)
    if precision + recall == 0:
        return 0.0
    return 2 * (precision * recall) / (precision + recall)
