# credit_score_model.py

def recommend_credit_score_logic(data):
    # Extract user inputs
    payment_history = data.get('paymentHistory', 'Good')  # Excellent, Good, Fair, Poor
    credit_utilization = float(data.get('creditUtilization', 30))  # Percentage
    credit_age = int(data.get('creditAge', 5))  # Years
    credit_mix = data.get('creditMix', 'Mixed')  # Credit Cards, Loans, Mixed
    new_credit = int(data.get('newCredit', 0))  # Number of new accounts
    income = float(data.get('income', 50000))
    existing_loans = int(data.get('existingLoans', 0))
    existing_credit_cards = int(data.get('existingCreditCards', 1))
    
    # Calculate base credit score (300-850 scale)
    base_score = 650  # Starting point
    
    # Payment History (35% of score)
    if payment_history == 'Excellent':
        base_score += 100
    elif payment_history == 'Good':
        base_score += 50
    elif payment_history == 'Fair':
        base_score += 25
    else:  # Poor
        base_score -= 50
    
    # Credit Utilization (30% of score)
    if credit_utilization < 10:
        base_score += 80
    elif credit_utilization < 30:
        base_score += 50
    elif credit_utilization < 50:
        base_score += 20
    elif credit_utilization < 70:
        base_score -= 20
    else:
        base_score -= 50
    
    # Credit Age (15% of score)
    if credit_age >= 10:
        base_score += 60
    elif credit_age >= 7:
        base_score += 40
    elif credit_age >= 5:
        base_score += 20
    elif credit_age >= 3:
        base_score += 10
    else:
        base_score -= 20
    
    # Credit Mix (10% of score)
    if credit_mix == 'Mixed':
        base_score += 30
    elif credit_mix == 'Credit Cards':
        base_score += 15
    else:  # Loans only
        base_score += 10
    
    # New Credit (10% of score)
    if new_credit == 0:
        base_score += 20
    elif new_credit == 1:
        base_score += 10
    elif new_credit <= 3:
        base_score -= 10
    else:
        base_score -= 30
    
    # Income factor (bonus)
    if income > 100000:
        base_score += 20
    elif income > 50000:
        base_score += 10
    
    # Ensure score is within bounds
    credit_score = max(300, min(850, base_score))
    
    # Determine credit score range
    if credit_score >= 750:
        score_range = 'Excellent'
        score_description = 'Excellent credit score. You qualify for the best rates and terms.'
    elif credit_score >= 700:
        score_range = 'Good'
        score_description = 'Good credit score. You qualify for most loans and credit cards.'
    elif credit_score >= 650:
        score_range = 'Fair'
        score_description = 'Fair credit score. You may qualify for some loans but with higher rates.'
    elif credit_score >= 600:
        score_range = 'Poor'
        score_description = 'Poor credit score. You may have difficulty getting approved for loans.'
    else:
        score_range = 'Very Poor'
        score_description = 'Very poor credit score. Focus on improving your credit before applying for loans.'
    
    # Generate improvement tips
    tips = []
    warnings = []
    
    # Payment history tips
    if payment_history in ['Fair', 'Poor']:
        warnings.append('Late payments significantly hurt your credit score. Pay all bills on time.')
        tips.append('Set up automatic payments to avoid late payments.')
    
    # Credit utilization tips
    if credit_utilization > 70:
        warnings.append('Your credit utilization is very high. This hurts your credit score.')
        tips.append('Keep credit utilization below 30% for better scores.')
    elif credit_utilization > 50:
        warnings.append('Your credit utilization is high. Consider paying down balances.')
        tips.append('Aim to keep credit utilization below 30%.')
    
    # Credit age tips
    if credit_age < 3:
        tips.append('Keep old accounts open to build credit history length.')
        warnings.append('Your credit history is short. Time will help improve your score.')
    
    # New credit tips
    if new_credit > 3:
        warnings.append('Too many new credit applications can hurt your score.')
        tips.append('Limit new credit applications to avoid multiple hard inquiries.')
    
    # Credit mix tips
    if credit_mix == 'Credit Cards':
        tips.append('Consider adding a small loan to diversify your credit mix.')
    
    # Income-based tips
    if income < 30000:
        tips.append('Consider increasing your income to improve creditworthiness.')
    
    # General tips
    if credit_score < 700:
        tips.append('Monitor your credit report regularly for errors.')
        tips.append('Consider a secured credit card to build credit.')
    
    return {
        'credit_score': credit_score,
        'score_range': score_range,
        'score_description': score_description,
        'factors': {
            'payment_history': {
                'impact': '35%',
                'status': payment_history,
                'score_impact': 'High' if payment_history in ['Excellent', 'Good'] else 'Low'
            },
            'credit_utilization': {
                'impact': '30%',
                'status': f'{credit_utilization}%',
                'score_impact': 'Good' if credit_utilization < 30 else 'Poor'
            },
            'credit_age': {
                'impact': '15%',
                'status': f'{credit_age} years',
                'score_impact': 'Good' if credit_age >= 5 else 'Poor'
            },
            'credit_mix': {
                'impact': '10%',
                'status': credit_mix,
                'score_impact': 'Good' if credit_mix == 'Mixed' else 'Fair'
            },
            'new_credit': {
                'impact': '10%',
                'status': f'{new_credit} new accounts',
                'score_impact': 'Good' if new_credit <= 1 else 'Poor'
            }
        },
        'tips': tips,
        'warnings': warnings,
        'improvement_timeline': '3-6 months for significant improvement',
        'next_steps': [
            'Pay all bills on time',
            'Reduce credit card balances',
            'Avoid new credit applications',
            'Monitor credit report regularly'
        ]
    } 