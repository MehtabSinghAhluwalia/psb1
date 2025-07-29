# budget_model.py

def recommend_budget_logic(data):
    # Extract user inputs
    monthly_income = float(data.get('monthlyIncome', 0))
    monthly_expenses = float(data.get('monthlyExpenses', 0))
    savings_goal = data.get('savingsGoal', 'Emergency Fund')
    time_frame = data.get('timeFrame', '6 months')
    
    # Calculate basic metrics
    disposable_income = monthly_income - monthly_expenses
    savings_rate = (disposable_income / monthly_income) * 100 if monthly_income > 0 else 0
    
    # Determine recommended savings amount based on goal and timeframe
    if savings_goal == 'Emergency Fund':
        target_amount = monthly_expenses * 6  # 6 months of expenses
        recommended_savings = max(disposable_income * 0.8, target_amount / 12)
    elif savings_goal == 'Vacation':
        target_amount = monthly_income * 2  # 2 months salary
        recommended_savings = target_amount / 12
    elif savings_goal == 'House':
        target_amount = monthly_income * 60  # 5 years salary
        recommended_savings = target_amount / 60
    else:  # General savings
        recommended_savings = disposable_income * 0.5
    
    # Budget breakdown (50-30-20 rule with adjustments)
    essentials_percentage = 0.5
    wants_percentage = 0.3
    savings_percentage = 0.2
    
    # Adjust based on income level
    if monthly_income < 30000:
        essentials_percentage = 0.6
        wants_percentage = 0.25
        savings_percentage = 0.15
    elif monthly_income > 100000:
        essentials_percentage = 0.4
        wants_percentage = 0.3
        savings_percentage = 0.3
    
    essentials_amount = monthly_income * essentials_percentage
    wants_amount = monthly_income * wants_percentage
    savings_amount = monthly_income * savings_percentage
    
    # Investment recommendations based on goal and timeframe
    if savings_goal == 'Emergency Fund':
        investment_type = 'Savings Account'
        investment_reason = 'High liquidity for emergency access'
    elif savings_goal == 'Vacation' and time_frame == '3 months':
        investment_type = 'Savings Account'
        investment_reason = 'Short-term goal, need liquidity'
    elif savings_goal == 'House' or time_frame == '1 year':
        investment_type = 'Fixed Deposit (FD)'
        investment_reason = 'Better returns for medium-term goals'
    else:
        investment_type = 'Recurring Deposit (RD)'
        investment_reason = 'Regular savings with good returns'
    
    # Generate tips and warnings
    tips = []
    warnings = []
    
    if savings_rate < 20:
        warnings.append('Your savings rate is low. Consider reducing expenses.')
    if monthly_expenses > monthly_income * 0.8:
        warnings.append('Your expenses are very high relative to income.')
    if disposable_income < 5000:
        warnings.append('Limited disposable income. Focus on essential expenses.')
    
    if savings_rate > 30:
        tips.append('Great savings rate! Consider investing excess funds.')
    if monthly_expenses < monthly_income * 0.5:
        tips.append('Excellent expense management. You can save more aggressively.')
    
    return {
        'recommended_savings': round(recommended_savings, 2),
        'budget_breakdown': {
            'essentials': {
                'percentage': essentials_percentage * 100,
                'amount': round(essentials_amount, 2)
            },
            'wants': {
                'percentage': wants_percentage * 100,
                'amount': round(wants_amount, 2)
            },
            'savings': {
                'percentage': savings_percentage * 100,
                'amount': round(savings_amount, 2)
            }
        },
        'investment_recommendation': {
            'type': investment_type,
            'reason': investment_reason
        },
        'tips': tips,
        'warnings': warnings,
        'savings_rate': round(savings_rate, 1),
        'disposable_income': round(disposable_income, 2)
    } 