import re
import tldextract
import numpy as np
import joblib
import socket
import ssl
import whois
import datetime
from difflib import SequenceMatcher

# Load the machine learning model
try:
    ML_MODEL = joblib.load('phishing_model.pkl')
except Exception as e:
    ML_MODEL = None

def create_model():
    weights = {
        'url_length': 0.05,
        'special_chars': 0.1,
        'suspicious_words': 0.25,
        'ssl_valid': 0.2,
        'domain_age': 0.2,
        'suspicious_tld': 0.15,
        'ip_in_domain': 0.05
    }
    return weights

PHISHING_WEIGHTS = create_model()

def extract_features(url):
    features = {}
    parsed_url = tldextract.extract(url)
    ext = parsed_url
    url_length = len(url)
    features['URL Length'] = url_length
    if url_length < 20:
        features['url_length_score'] = 0.3
    elif url_length > 100:
        features['url_length_score'] = 0.4
    else:
        features['url_length_score'] = 0.0
    features['Domain Length'] = len(ext.domain)
    subdomains = ext.subdomain.split('.') if ext.subdomain else []
    features['Number of Subdomains'] = len(subdomains)
    features['subdomain_count_score'] = 0.0
    if len(subdomains) >= 3:
        features['subdomain_count_score'] = 0.5
    elif len(subdomains) == 2:
        features['subdomain_count_score'] = 0.2
    suspicious_subdomains = ['localhost', 'admin', 'secure', 'login', 'paypal', 'bank', 'update', 'signin', 'account']
    found_suspicious_subdomain = any(s in subdomains for s in suspicious_subdomains)
    features['suspicious_subdomain'] = found_suspicious_subdomain
    features['suspicious_subdomain_score'] = 0.7 if found_suspicious_subdomain else 0.0
    features['punycode'] = url.startswith('xn--') or 'xn--' in url
    features['punycode_score'] = 0.7 if features['punycode'] else 0.0
    try:
        url.encode('ascii')
        features['unicode_trick'] = False
        features['unicode_trick_score'] = 0.0
    except UnicodeEncodeError:
        features['unicode_trick'] = True
        features['unicode_trick_score'] = 0.7
    known_brands = ['paypal', 'google', 'apple', 'amazon', 'bank', 'microsoft']
    features['brand_similarity'] = max([SequenceMatcher(None, ext.domain, brand).ratio() for brand in known_brands])
    special_chars = len(re.findall(r'[!@#$%^&*(),.?":{}|<>]', url))
    features['Special Characters'] = special_chars
    if special_chars == 0:
        features['special_chars_score'] = 0.0
    elif special_chars <= 2:
        features['special_chars_score'] = 0.2
    elif special_chars <= 5:
        features['special_chars_score'] = 0.5
    else:
        features['special_chars_score'] = 0.8
    suspicious_keywords = ['secure', 'account', 'webscr', 'login', 'signin', 'bank', 'verify', 'update', 
                         'password', 'confirm', 'paypal', 'wallet', 'support', 'security', 'click', 'update',
                         'suspended', 'limited', 'verify', 'confirm', 'urgent', 'action', 'required']
    keyword_count = sum(1 for keyword in suspicious_keywords if keyword in url.lower())
    features['Suspicious Keywords'] = keyword_count
    if keyword_count == 0:
        features['suspicious_words_score'] = 0.0
    elif keyword_count == 1:
        features['suspicious_words_score'] = 0.3
    elif keyword_count == 2:
        features['suspicious_words_score'] = 0.6
    else:
        features['suspicious_words_score'] = 0.9
    try:
        hostname = ext.domain + '.' + ext.suffix
        context = ssl.create_default_context()
        with socket.create_connection((hostname, 443), timeout=3) as sock:
            with context.wrap_socket(sock, server_hostname=hostname) as ssock:
                cert = ssock.getpeercert()
                features['SSL Valid'] = True
                features['ssl_valid_score'] = 0.0
    except:
        features['SSL Valid'] = False
        features['ssl_valid_score'] = 0.8
    try:
        domain_info = whois.whois(ext.domain + '.' + ext.suffix)
        if domain_info.creation_date:
            if isinstance(domain_info.creation_date, list):
                creation_date = domain_info.creation_date[0]
            else:
                creation_date = domain_info.creation_date
            domain_age = (datetime.datetime.now() - creation_date).days
            features['Domain Age (days)'] = domain_age
            if domain_age < 30:
                features['domain_age_score'] = 0.9
            elif domain_age < 90:
                features['domain_age_score'] = 0.6
            elif domain_age < 365:
                features['domain_age_score'] = 0.3
            else:
                features['domain_age_score'] = 0.0
        else:
            features['Domain Age (days)'] = 0
            features['domain_age_score'] = 0.9
    except:
        features['Domain Age (days)'] = 0
        features['domain_age_score'] = 0.9
    suspicious_tlds = ['xyz', 'top', 'cc', 'tk', 'ml', 'ga', 'cf', 'gq', 'pw', 'info', 'online', 'site', 'click']
    features['Suspicious TLD'] = ext.suffix.lower() in suspicious_tlds
    features['suspicious_tld_score'] = 0.8 if ext.suffix.lower() in suspicious_tlds else 0.0
    features['Contains IP'] = bool(re.search(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}', url))
    features['ip_in_domain_score'] = 0.9 if features['Contains IP'] else 0.0
    if 'localhost' in url.lower() or '127.0.0.1' in url or '192.168.' in url:
        features['is_localhost'] = True
        features['localhost_score'] = 0.0
    else:
        features['is_localhost'] = False
        features['localhost_score'] = 0.0
    shorteners = ['bit.ly', 'tinyurl.com', 'goo.gl', 't.co', 'ow.ly', 'is.gd', 'buff.ly', 'adf.ly']
    features['is_shortener'] = any(short in url for short in shorteners)
    features['shortener_score'] = 0.8 if features['is_shortener'] else 0.0
    return features

def calculate_phishing_probability(features):
    if features.get('is_localhost', False):
        return False, 5.0, 5.0, None
    total_score = 0
    max_score = 0
    for feature, weight in PHISHING_WEIGHTS.items():
        score_key = f"{feature}_score"
        if score_key in features:
            total_score += features[score_key] * weight
            max_score += weight
    total_score += features.get('subdomain_count_score', 0) * 0.1
    max_score += 0.1
    total_score += features.get('suspicious_subdomain_score', 0) * 0.2
    max_score += 0.2
    total_score += features.get('punycode_score', 0) * 0.2
    max_score += 0.2
    total_score += features.get('unicode_trick_score', 0) * 0.2
    max_score += 0.2
    total_score += features.get('shortener_score', 0) * 0.3
    max_score += 0.3
    known_brands = ['paypal', 'google', 'apple', 'amazon', 'bank', 'microsoft']
    for brand in known_brands:
        if features['brand_similarity'] > 0.8 and brand in features and brand not in features.get('domain', ''):
            total_score += 0.7
            max_score += 0.7
            break
        if features['brand_similarity'] > 0.8 and brand not in features.get('domain', '') and brand in features.get('domain', ''):
            total_score += 0.7
            max_score += 0.7
            break
    if max_score > 0:
        rule_based_probability = (total_score / max_score) * 100
    else:
        rule_based_probability = 0
    ml_probability = None
    if ML_MODEL is not None:
        try:
            ml_features = np.array([
                features['url_length_score'],
                features['special_chars_score'],
                features['suspicious_words_score'],
                features['ssl_valid_score'],
                features['domain_age_score'],
                features['suspicious_tld_score'],
                features['ip_in_domain_score'],
                features.get('subdomain_count_score', 0),
                features.get('suspicious_subdomain_score', 0),
                features.get('punycode_score', 0),
                features.get('unicode_trick_score', 0)
            ]).reshape(1, -1)
            ml_probability = ML_MODEL.predict_proba(ml_features)[0][1] * 100
        except Exception as e:
            pass
    if ml_probability is not None:
        final_probability = (ml_probability * 0.6) + (rule_based_probability * 0.4)
    else:
        final_probability = rule_based_probability
    is_phishing = final_probability > 30
    return is_phishing, final_probability, rule_based_probability, ml_probability

def check_phishing(url):
    if not url:
        return {'error': 'No URL provided'}
    if not url.startswith(('http://', 'https://')):
        url = 'http://' + url
    try:
        features = extract_features(url)
        is_phishing, final_confidence, rule_confidence, ml_confidence = calculate_phishing_probability(features)
        response = {
            'url': url,
            'is_phishing': is_phishing,
            'confidence': round(final_confidence, 2),
            'rule_confidence': round(rule_confidence, 2) if rule_confidence is not None else None,
            'ml_confidence': round(ml_confidence, 2) if ml_confidence is not None else None,
            'features': {
                'url_length': features['URL Length'],
                'domain_length': features['Domain Length'],
                'special_characters': features['Special Characters'],
                'suspicious_keywords_found': features['Suspicious Keywords'],
                'ssl_certificate': 'Valid' if features['SSL Valid'] else 'Invalid/Missing',
                'domain_age_days': features['Domain Age (days)'],
                'contains_ip_address': features['Contains IP'],
                'suspicious_tld': features.get('Suspicious TLD', False),
                'subdomain_count': features['Number of Subdomains'],
                'suspicious_subdomain': features['suspicious_subdomain'],
                'punycode_trick': features['punycode'],
                'unicode_trick': features['unicode_trick'],
                'brand_similarity': features['brand_similarity']
            }
        }
        return response
    except Exception as e:
        return {'error': f'Error analyzing URL: {str(e)}'} 