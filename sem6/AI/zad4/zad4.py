from sklearn.metrics import precision_score, recall_score, f1_score, confusion_matrix

rf = RandomForestClassifier(n_estimators=100, random_state=42)
rf.fit(X_train_std, y_train)
y_pred = rf.predict(X_test_std)

print("Precision (macro):", round(precision_score(y_test, y_pred, average='macro'), 3))
print("Recall    (macro):", round(recall_score   (y_test, y_pred, average='macro'), 3))
print("F1-score  (macro):", round(f1_score       (y_test, y_pred, average='macro'), 3))
print("Confusion matrix:\n", confusion_matrix(y_test, y_pred))
