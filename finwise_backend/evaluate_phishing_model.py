import pandas as pd
import joblib
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, confusion_matrix, classification_report

# Load enhanced dataset and model
csv_file = 'enhanced_phishing_dataset.csv'
df = pd.read_csv(csv_file)
model = joblib.load('phishing_model.pkl')

# Feature columns (should match those used in training)
feature_cols = [
    'URLLength', 'DomainLength', 'subdomain_count', 'suspicious_subdomain',
    'punycode', 'unicode_trick', 'brand_similarity',
]
X = df[feature_cols].fillna(0)
y_true = df['label']

y_pred = model.predict(X)

print('--- Model Evaluation ---')
print(f'Accuracy:  {accuracy_score(y_true, y_pred):.4f}')
print(f'Precision: {precision_score(y_true, y_pred):.4f}')
print(f'Recall:    {recall_score(y_true, y_pred):.4f}')
print(f'F1-score:  {f1_score(y_true, y_pred):.4f}')
print('\nConfusion Matrix:')
print(confusion_matrix(y_true, y_pred))
print('\nClassification Report:')
print(classification_report(y_true, y_pred)) 