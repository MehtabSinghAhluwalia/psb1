from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

def recommend_savings_method_logic(data):
    goal = data.get('goal')
    amount = float(data.get('amount', 0))
    duration = int(data.get('duration', 0))  # in months
    deposit_frequency = data.get('deposit_frequency')
    risk = data.get('risk')

    # Simple rules-based logic (replace with ML model if available)
    if risk == 'Low':
        if deposit_frequency == 'Once' and duration >= 12:
            method = 'Fixed Deposit (FD)'
            reason = 'FDs are best for lump-sum, low-risk, long-term savings.'
        elif deposit_frequency == 'Monthly' and duration >= 12:
            method = 'Recurring Deposit (RD)'
            reason = 'RDs are ideal for regular monthly savings with low risk.'
        else:
            method = 'Savings Account'
            reason = 'For short-term or flexible savings, a Savings Account is suitable.'
    elif risk == 'Medium':
        if duration >= 24:
            method = 'Debt Mutual Fund'
            reason = 'Debt funds offer moderate returns with moderate risk for longer durations.'
        else:
            method = 'RD or FD'
            reason = 'For medium risk and shorter durations, RD or FD is recommended.'
    else:  # High risk
        if duration >= 36:
            method = 'Equity Mutual Fund'
            reason = 'For high risk and long-term, equity funds can offer higher returns.'
        else:
            method = 'Debt Mutual Fund'
            reason = 'For high risk but short-term, debt funds are safer.'
    return {'recommended_method': method, 'reason': reason}

@app.route('/recommend_savings_method', methods=['POST'])
def recommend_savings_method():
    data = request.json
    result = recommend_savings_method_logic(data)
    return jsonify(result)

if __name__ == '__main__':
    app.run(port=5001, debug=True) 