# account_type_model.py

def recommend_account_type_logic(data):
    # Simple rules-based logic for account type recommendation
    account_purpose = data.get('accountPurpose')
    initial_deposit = data.get('initialDeposit')
    monthly_transactions = data.get('monthlyTransactions')
    account_usage = data.get('accountUsage')

    if account_purpose == 'Savings' and initial_deposit == 'Less than ₹10,000':
        recommendation = 'Basic Savings Account'
    elif account_purpose == 'Business' or monthly_transactions == 'More than 50':
        recommendation = 'Current Account'
    elif account_purpose == 'Investment' and initial_deposit == 'More than ₹50,000':
        recommendation = 'Premium Savings Account'
    elif account_usage == 'Regular salary deposits':
        recommendation = 'Salary Account'
    elif account_purpose == 'Savings' and initial_deposit == '₹10,000 - ₹50,000':
        recommendation = 'Regular Savings Account'
    else:
        recommendation = 'Basic Savings Account'
    return {'recommended_account_type': recommendation} 