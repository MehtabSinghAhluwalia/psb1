import 'dart:convert';
import 'package:http/http.dart' as http;

class SavingsApiService {
  static const String _baseUrl = 'http://192.168.1.5:8000'; // Use your actual local IP

  static Future<double?> getRecommendedSaving({
    required double income,
    required double expenses,
    required double goalAmount,
    required double monthsToGoal,
  }) async {
    final url = Uri.parse('$_baseUrl/predict');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'income': income,
        'expenses': expenses,
        'goal_amount': goalAmount,
        'months_to_goal': monthsToGoal,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['recommended_saving']?.toDouble();
    } else {
      // Handle error
      return null;
    }
  }
} 