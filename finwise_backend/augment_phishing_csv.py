import pandas as pd
import re

# List of suspicious keywords
SUSPICIOUS_KEYWORDS = [
    'secure', 'account', 'webscr', 'login', 'signin', 'bank', 'verify', 'update',
    'password', 'confirm', 'paypal', 'wallet', 'support', 'security', 'click',
    'suspended', 'limited', 'urgent', 'action', 'required'
]
# List of known shorteners
SHORTENERS = ['bit.ly', 'tinyurl.com', 'goo.gl', 't.co', 'ow.ly', 'is.gd', 'buff.ly', 'adf.ly']

# Load CSV
csv_file = 'enhanced_phishing_dataset.csv'
df = pd.read_csv(csv_file)

# If these columns already exist, skip adding them
for col in ['special_characters', 'suspicious_keywords_found', 'shortener_score']:
    if col not in df.columns:
        df[col] = 0

# Try to find the URL column (commonly named 'URL' or similar)
url_col = None
for candidate in ['URL', 'Url', 'url', 'link']:
    if candidate in df.columns:
        url_col = candidate
        break
if url_col is None:
    raise Exception('Could not find URL column in CSV.')

for idx, row in df.iterrows():
    url = str(row[url_col])
    # Count special characters
    special_chars = len(re.findall(r'[!@#$%^&*(),.?":{}|<>]', url))
    # Count suspicious keywords
    suspicious_count = sum(1 for keyword in SUSPICIOUS_KEYWORDS if keyword in url.lower())
    # Shortener score
    shortener_score = 0.8 if any(short in url for short in SHORTENERS) else 0
    df.at[idx, 'special_characters'] = special_chars
    df.at[idx, 'suspicious_keywords_found'] = suspicious_count
    df.at[idx, 'shortener_score'] = shortener_score

# Save the updated CSV
out_file = 'enhanced_phishing_dataset.csv'
df.to_csv(out_file, index=False)
print(f'Updated {out_file} with new features.') 