import pandas as pd
import tldextract
import re
from urllib.parse import urlparse
from difflib import SequenceMatcher

# Load the original dataset
input_csv = 'PhiUSIIL_Phishing_URL_Dataset.csv'
df = pd.read_csv(input_csv, low_memory=False)

def extract_new_features(url):
    features = {}
    ext = tldextract.extract(url)
    parsed_url = urlparse(url)
    # Subdomain analysis
    subdomains = ext.subdomain.split('.') if ext.subdomain else []
    features['subdomain_count'] = len(subdomains)
    suspicious_subdomains = ['localhost', 'admin', 'secure', 'login', 'paypal', 'bank', 'update', 'signin', 'account']
    features['suspicious_subdomain'] = int(any(s in subdomains for s in suspicious_subdomains))
    # Punycode/unicode tricks
    features['punycode'] = int(url.startswith('xn--') or 'xn--' in url)
    try:
        url.encode('ascii')
        features['unicode_trick'] = 0
    except UnicodeEncodeError:
        features['unicode_trick'] = 1
    # Brand similarity (max similarity to known brands)
    known_brands = ['paypal', 'google', 'apple', 'amazon', 'bank', 'microsoft']
    features['brand_similarity'] = max([SequenceMatcher(None, ext.domain, brand).ratio() for brand in known_brands])
    return features

# Extract new features for each row
new_features = df['URL'].apply(extract_new_features)
new_features_df = pd.DataFrame(list(new_features))

# Concatenate new features to original DataFrame
enhanced_df = pd.concat([df, new_features_df], axis=1)

# Save to new CSV
enhanced_df.to_csv('enhanced_phishing_dataset.csv', index=False)

print('Enhanced dataset with new features saved as enhanced_phishing_dataset.csv') 