# insurance_model.py

def recommend_insurance_logic(data):
    # Extract user inputs
    age = int(data.get('age', 30))
    income = float(data.get('income', 50000))
    health_condition = data.get('healthCondition', 'Good')  # Excellent, Good, Fair, Poor
    occupation = data.get('occupation', 'Office')  # Office, Manual, High Risk, Professional
    family_size = int(data.get('familySize', 3))
    existing_insurance = data.get('existingInsurance', 'None')  # None, Basic, Comprehensive
    vehicle_type = data.get('vehicleType', 'Car')  # Car, Bike, Commercial
    vehicle_age = int(data.get('vehicleAge', 3))
    driving_history = data.get('drivingHistory', 'Good')  # Excellent, Good, Fair, Poor
    
    # Calculate base premiums and recommendations
    recommendations = []
    warnings = []
    tips = []
    
    # Health Insurance Analysis
    health_premium = 0
    if age < 30:
        base_health_premium = 5000
    elif age < 45:
        base_health_premium = 8000
    elif age < 60:
        base_health_premium = 15000
    else:
        base_health_premium = 25000
    
    # Adjust for health condition
    if health_condition == 'Excellent':
        health_premium = base_health_premium * 0.7
        tips.append('Excellent health condition helps reduce premium costs.')
    elif health_condition == 'Good':
        health_premium = base_health_premium * 0.9
    elif health_condition == 'Fair':
        health_premium = base_health_premium * 1.2
        warnings.append('Consider improving health habits to reduce premiums.')
    else:  # Poor
        health_premium = base_health_premium * 1.8
        warnings.append('Poor health condition significantly increases premiums.')
    
    # Adjust for family size
    if family_size > 4:
        health_premium *= 1.3
        tips.append('Consider family floater plans for better value.')
    
    # Life Insurance Analysis
    life_coverage = income * 10  # 10x annual income
    life_premium = (life_coverage * 0.02) / 12  # 2% annual rate
    
    if age > 50:
        life_premium *= 1.5
        warnings.append('Life insurance premiums increase with age.')
    
    # Vehicle Insurance Analysis
    vehicle_premium = 0
    if vehicle_type == 'Car':
        base_vehicle_premium = 8000
    elif vehicle_type == 'Bike':
        base_vehicle_premium = 2000
    else:  # Commercial
        base_vehicle_premium = 15000
    
    # Adjust for vehicle age
    if vehicle_age > 10:
        vehicle_premium = base_vehicle_premium * 1.5
        warnings.append('Older vehicles may have higher insurance costs.')
    elif vehicle_age > 5:
        vehicle_premium = base_vehicle_premium * 1.2
    else:
        vehicle_premium = base_vehicle_premium
    
    # Adjust for driving history
    if driving_history == 'Excellent':
        vehicle_premium *= 0.7
        tips.append('Excellent driving record helps reduce vehicle insurance costs.')
    elif driving_history == 'Good':
        vehicle_premium *= 0.9
    elif driving_history == 'Fair':
        vehicle_premium *= 1.3
        warnings.append('Improve driving record to reduce vehicle insurance costs.')
    else:  # Poor
        vehicle_premium *= 2.0
        warnings.append('Poor driving record significantly increases vehicle insurance costs.')
    
    # Occupation-based adjustments
    if occupation == 'High Risk':
        health_premium *= 1.5
        life_premium *= 1.3
        warnings.append('High-risk occupation increases insurance premiums.')
    elif occupation == 'Professional':
        health_premium *= 0.9
        life_premium *= 0.9
        tips.append('Professional occupation may qualify for better rates.')
    
    # Income-based recommendations
    if income < 30000:
        recommendations.append('Consider basic health insurance plans within your budget.')
        recommendations.append('Term life insurance may be more affordable than whole life.')
    elif income > 100000:
        recommendations.append('Consider comprehensive health insurance with higher coverage.')
        recommendations.append('Whole life insurance provides additional investment benefits.')
    
    # Existing insurance analysis
    if existing_insurance == 'None':
        warnings.append('No existing insurance coverage. Consider basic health and life insurance.')
        recommendations.append('Start with basic health insurance and term life insurance.')
    elif existing_insurance == 'Basic':
        recommendations.append('Consider upgrading to comprehensive coverage for better protection.')
    elif existing_insurance == 'Comprehensive':
        tips.append('Good existing coverage. Review annually for optimal rates.')
    
    # Calculate total annual premium
    total_annual_premium = health_premium + (life_premium * 12) + vehicle_premium
    
    # Determine coverage adequacy
    coverage_adequacy = 'Good'
    if total_annual_premium < income * 0.05:
        coverage_adequacy = 'Excellent'
        tips.append('Insurance costs are well within your budget.')
    elif total_annual_premium > income * 0.15:
        coverage_adequacy = 'Poor'
        warnings.append('Insurance costs are high relative to income. Consider basic plans.')
    
    return {
        'premiums': {
            'health_insurance': round(health_premium, 2),
            'life_insurance': round(life_premium, 2),
            'vehicle_insurance': round(vehicle_premium, 2),
            'total_annual': round(total_annual_premium, 2),
            'total_monthly': round(total_annual_premium / 12, 2)
        },
        'coverage': {
            'life_coverage': round(life_coverage, 2),
            'health_coverage': 'Up to ₹5,00,000 per year',
            'vehicle_coverage': 'Comprehensive coverage'
        },
        'recommendations': recommendations,
        'warnings': warnings,
        'tips': tips,
        'coverage_adequacy': coverage_adequacy,
        'risk_assessment': {
            'health_risk': 'Low' if health_condition in ['Excellent', 'Good'] else 'High',
            'life_risk': 'Low' if age < 45 else 'Medium' if age < 60 else 'High',
            'vehicle_risk': 'Low' if driving_history in ['Excellent', 'Good'] else 'High'
        },
        'next_steps': [
            'Compare quotes from multiple insurers',
            'Consider bundling policies for discounts',
            'Review coverage annually',
            'Maintain good health and driving record'
        ]
    } 