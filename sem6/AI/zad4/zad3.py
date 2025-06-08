from sklearn.naive_bayes import GaussianNB
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.svm import SVC
from sklearn.metrics import accuracy_score

# helper: train & eval
def train_eval(model, X_tr, y_tr, X_te, y_te):
    model.fit(X_tr, y_tr)
    y_pred = model.predict(X_te)
    print(f"{model.__class__.__name__}: accuracy =",
          round(accuracy_score(y_te, y_pred), 3))

# 1) Gaussian Naive Bayes
gnb = GaussianNB()
train_eval(gnb, X_train_std, y_train, X_test_std, y_test)

# 2) Decision Tree – 3 zestawy hiperparametrów
dt_params = [
    {"random_state":42},                      # default
    {"max_depth":5, "random_state":42},       # shallow
    {"min_samples_split":10, "random_state":42}
]
for params in dt_params:
    dt = DecisionTreeClassifier(**params)
    train_eval(dt, X_train_std, y_train, X_test_std, y_test)

# 3) Random Forest (bonus)
rf_params = [
    {"n_estimators":100, "random_state":42},
    {"n_estimators":200, "max_depth":7, "random_state":42}
]
for params in rf_params:
    rf = RandomForestClassifier(**params)
    train_eval(rf, X_train_std, y_train, X_test_std, y_test)

# 4) SVM (bonus)
svm_models = [
    SVC(kernel="linear", random_state=42),
    SVC(kernel="rbf", C=1.0, random_state=42)
]
for svm in svm_models:
    train_eval(svm, X_train_std, y_train, X_test_std, y_test)

# 5) łagodzenie przeuczenia dla drzewa: cost-complexity pruning
#    porównanie default vs ccp_alpha=0.01
dt_default = DecisionTreeClassifier(random_state=42)
dt_pruned  = DecisionTreeClassifier(ccp_alpha=0.01, random_state=42)
print("\npruning:")
train_eval(dt_default, X_train_std, y_train, X_test_std, y_test)
train_eval(dt_pruned,  X_train_std, y_train, X_test_std, y_test)
