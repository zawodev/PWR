from sklearn.model_selection import train_test_split
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import StandardScaler, Normalizer
from sklearn.decomposition import PCA

# 2.1 podział na zestaw uczący i testowy
X_train, X_test, y_train, y_test = train_test_split(
    X, y['CLASS'],
    test_size=0.3,
    stratify=y['CLASS'],
    random_state=42
)

# 2.2 imputacja braków (mean) – tu zbiór już bez missing
imputer = SimpleImputer(strategy='mean')
X_train_imp = imputer.fit_transform(X_train)
X_test_imp = imputer.transform(X_test)

# 2.3 różne sposoby przetwarzania:

# a) standaryzacja
scaler = StandardScaler()
X_train_std = scaler.fit_transform(X_train_imp)
X_test_std = scaler.transform(X_test_imp)

# b) normalizacja do długości wektora = 1
normalizer = Normalizer()
X_train_norm = normalizer.fit_transform(X_train_imp)
X_test_norm = normalizer.transform(X_test_imp)

# c) PCA zachowujące 95% wariancji (na danych wystandaryzowanych)
pca = PCA(n_components=0.95, random_state=42)
X_train_pca = pca.fit_transform(X_train_std)
X_test_pca = pca.transform(X_test_std)

# 2.4 kształty macierzy
print("raw imp:", X_train_imp.shape, X_test_imp.shape)
print("std:",     X_train_std.shape,  X_test_std.shape)
print("norm:",    X_train_norm.shape, X_test_norm.shape)
print("pca:",     X_train_pca.shape,  X_test_pca.shape)
