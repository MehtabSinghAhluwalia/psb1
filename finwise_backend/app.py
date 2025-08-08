from flask import Flask, request, jsonify
from flask_cors import CORS
from phishing_model import check_phishing
from inflation_model import predict_inflation_rate
from translation_model import translate_text
from models import db, User
from account_type_model import recommend_account_type_logic
from savings_method_model import recommend_savings_method_logic
from budget_model import recommend_budget_logic
from credit_score_model import recommend_credit_score_logic
from insurance_model import recommend_insurance_logic

app = Flask(__name__)
CORS(app)

# Configure your database URI here (PostgreSQL example)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://apple@localhost/archive'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db.init_app(app)

with app.app_context():
    db.create_all()

@app.route('/register', methods=['POST'])
def register_user():
    data = request.get_json()
    if not data or 'name' not in data or 'email' not in data:
        return jsonify({'error': 'Name and email are required'}), 400
    if User.query.filter_by(email=data['email']).first():
        return jsonify({'error': 'Email already registered'}), 400
    user = User(name=data['name'], email=data['email'])
    db.session.add(user)
    db.session.commit()
    return jsonify({'message': 'User registered successfully'})

@app.route('/api/check', methods=['POST'])
def api_check_url():
    data = request.get_json()
    url = data.get('url') if data else None
    result = check_phishing(url)
    return jsonify(result), 200 if 'error' not in result else 400

@app.route('/predict_inflation', methods=['POST'])
def predict_inflation():
    data = request.get_json()
    years = data.get('years_to_retirement', 0)
    predicted_inflation = predict_inflation_rate(years)
    return jsonify({'inflation_rate': round(predicted_inflation, 1)})

@app.route('/recommend_savings_method', methods=['POST'])
def recommend_savings_method():
    data = request.get_json()
    target_lang = data.get('target_lang', 'en')
    result = recommend_savings_method_logic(data)
    if target_lang != 'en':
        result['recommended_method'] = translate_text(result['recommended_method'], target_lang)
        result['reason'] = translate_text(result['reason'], target_lang)
    return jsonify(result)

@app.route('/recommend_account_type', methods=['POST'])
def recommend_account_type():
    data = request.get_json()
    target_lang = data.get('target_lang', 'en')
    result = recommend_account_type_logic(data)
    if target_lang != 'en':
        result['recommended_account_type'] = translate_text(result['recommended_account_type'], target_lang)
    return jsonify(result)

@app.route('/recommend_budget', methods=['POST'])
def recommend_budget():
    data = request.get_json()
    target_lang = data.get('target_lang', 'en')
    result = recommend_budget_logic(data)
    if target_lang != 'en':
        # Translate all text fields
        result['investment_recommendation']['type'] = translate_text(result['investment_recommendation']['type'], target_lang)
        result['investment_recommendation']['reason'] = translate_text(result['investment_recommendation']['reason'], target_lang)
        result['tips'] = [translate_text(tip, target_lang) for tip in result['tips']]
        result['warnings'] = [translate_text(warning, target_lang) for warning in result['warnings']]
    return jsonify(result)

@app.route('/recommend_credit_score', methods=['POST'])
def recommend_credit_score():
    data = request.get_json()
    target_lang = data.get('target_lang', 'en')
    result = recommend_credit_score_logic(data)
    if target_lang != 'en':
        # Translate all text fields
        result['score_description'] = translate_text(result['score_description'], target_lang)
        result['score_range'] = translate_text(result['score_range'], target_lang)
        result['improvement_timeline'] = translate_text(result['improvement_timeline'], target_lang)
        result['tips'] = [translate_text(tip, target_lang) for tip in result['tips']]
        result['warnings'] = [translate_text(warning, target_lang) for warning in result['warnings']]
        result['next_steps'] = [translate_text(step, target_lang) for step in result['next_steps']]
        # Translate factor statuses
        for factor in result['factors'].values():
            factor['status'] = translate_text(factor['status'], target_lang)
            factor['score_impact'] = translate_text(factor['score_impact'], target_lang)
    return jsonify(result)

@app.route('/recommend_insurance', methods=['POST'])
def recommend_insurance():
    data = request.get_json()
    target_lang = data.get('target_lang', 'en')
    result = recommend_insurance_logic(data)
    if target_lang != 'en':
        # Translate all text fields
        result['coverage']['health_coverage'] = translate_text(result['coverage']['health_coverage'], target_lang)
        result['coverage']['vehicle_coverage'] = translate_text(result['coverage']['vehicle_coverage'], target_lang)
        result['coverage_adequacy'] = translate_text(result['coverage_adequacy'], target_lang)
        result['recommendations'] = [translate_text(rec, target_lang) for rec in result['recommendations']]
        result['warnings'] = [translate_text(warning, target_lang) for warning in result['warnings']]
        result['tips'] = [translate_text(tip, target_lang) for tip in result['tips']]
        result['next_steps'] = [translate_text(step, target_lang) for step in result['next_steps']]
        # Translate risk assessment
        for risk in result['risk_assessment'].values():
            risk = translate_text(risk, target_lang)
    return jsonify(result)

if __name__ == '__main__':
    app.run(debug=True, port=5001) 