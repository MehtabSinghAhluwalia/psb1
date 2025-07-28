def predict_inflation_rate(years_to_retirement):
    # Mock logic: 6% + 0.1% per year, capped at 10%
    return min(10.0, max(4.0, 6.0 + 0.1 * years_to_retirement)) 