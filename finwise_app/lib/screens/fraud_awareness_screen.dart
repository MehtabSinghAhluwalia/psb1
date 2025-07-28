import 'package:flutter/material.dart';
import 'package:finwise_app/models/fraud_case.dart';
import 'package:finwise_app/theme/app_theme.dart';
import 'package:finwise_app/l10n/app_localizations.dart';
import 'package:finwise_app/screens/settings_screen.dart';
import 'package:finwise_app/screens/profile_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:finwise_app/widgets/finwise_app_bar.dart';
import 'package:finwise_app/widgets/finwise_drawer.dart';
import 'package:finwise_app/main.dart'; // For NotificationService

class FraudAwarenessScreen extends StatefulWidget {
  const FraudAwarenessScreen({super.key});

  @override
  State<FraudAwarenessScreen> createState() => _FraudAwarenessScreenState();
}

class _FraudAwarenessScreenState extends State<FraudAwarenessScreen> {
  final List<FraudCase> _fraudCases = FraudCase.getSampleCases();
  String _selectedCategory = 'All';

  List<String> get _categories {
    final categories = _fraudCases.map((e) => e.category).toSet().toList();
    categories.insert(0, AppLocalizations.of(context)!.all);
    return categories;
  }

  List<FraudCase> get _filteredCases {
    if (_selectedCategory == AppLocalizations.of(context)!.all) {
      return _fraudCases;
    }
    return _fraudCases.where((e) => e.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FinwiseAppBar(
        context: context,
        subtitle: AppLocalizations.of(context)!.staySafe,
      ),
      endDrawer: const FinwiseDrawer(),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryColor.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.staySafe,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.fraudAwarenessDesc,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.filterByCategory,
                border: const OutlineInputBorder(),
              ),
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                }
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredCases.length,
              itemBuilder: (context, index) {
                final fraudCase = _filteredCases[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FraudCaseDetailPage(fraudCase: fraudCase),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  fraudCase.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getSeverityColor(fraudCase.severity),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _getSeverityLabel(context, fraudCase.severity),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                fraudCase.category,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            fraudCase.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getSeverityLabel(BuildContext context, String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return AppLocalizations.of(context)!.high;
      case 'medium':
        return AppLocalizations.of(context)!.medium;
      case 'low':
        return AppLocalizations.of(context)!.low;
      default:
        return severity;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class FraudCaseDetailPage extends StatelessWidget {
  final FraudCase fraudCase;
  const FraudCaseDetailPage({super.key, required this.fraudCase});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FinwiseAppBar(
        context: context,
        subtitle: fraudCase.title,
      ),
      endDrawer: const FinwiseDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fraudCase.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(fraudCase.severity),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getSeverityLabel(context, fraudCase.severity),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    fraudCase.category,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.description,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                fraudCase.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.preventionTips,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                fraudCase.preventionTips,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (fraudCase.title == 'Credit Card Fraud') ...[
                const SizedBox(height: 24),
                Divider(),
                Text('Reminders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _CreditCardReminderWidget(),
              ],
              if (fraudCase.title == 'Phishing Scams') ...[
                const SizedBox(height: 24),
                Divider(),
                Text('Phishing URL Checker', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _PhishingCheckerWidget(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getSeverityLabel(BuildContext context, String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return AppLocalizations.of(context)!.high;
      case 'medium':
        return AppLocalizations.of(context)!.medium;
      case 'low':
        return AppLocalizations.of(context)!.low;
      default:
        return severity;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class _PhishingCheckerWidget extends StatefulWidget {
  const _PhishingCheckerWidget({Key? key}) : super(key: key);

  @override
  State<_PhishingCheckerWidget> createState() => _PhishingCheckerWidgetState();
}

class _PhishingCheckerWidgetState extends State<_PhishingCheckerWidget> {
  final TextEditingController _urlController = TextEditingController();
  String? _result;
  Map<String, dynamic>? _details;
  bool _loading = false;

  Future<void> checkPhishing() async {
    setState(() {
      _loading = true;
      _result = null;
      _details = null;
    });
    final url = 'http://192.168.1.2:5001/api/check';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': _urlController.text}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _result = data['is_phishing'] ? 'Phishing Detected!' : 'Safe Link';
          _details = data;
        });
      } else {
        setState(() {
          _result = 'Error: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color? resultColor;
    IconData? resultIcon;
    if (_result != null) {
      if (_result == 'Phishing Detected!') {
        resultColor = Colors.red[100];
        resultIcon = Icons.warning_amber_rounded;
      } else if (_result == 'Safe Link') {
        resultColor = Colors.green[100];
        resultIcon = Icons.check_circle_outline;
      } else {
        resultColor = Colors.grey[200];
        resultIcon = Icons.info_outline;
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _urlController,
          decoration: const InputDecoration(
            labelText: 'Enter URL',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.link),
          ),
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _loading ? null : checkPhishing,
            icon: const Icon(Icons.search),
            label: const Text('Check for Phishing'),
          ),
        ),
        const SizedBox(height: 24),
        if (_loading)
          const Center(child: CircularProgressIndicator()),
        if (_result != null && !_loading) ...[
          Card(
            color: resultColor,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(resultIcon, size: 40, color: resultColor == Colors.red[100] ? Colors.red : Colors.green),
              title: Text(
                _result!,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: resultColor == Colors.red[100] ? Colors.red[900] : Colors.green[900],
                ),
              ),
              subtitle: _details != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Confidence: ${_details!['confidence']}%'),
                          if (_details!['rule_confidence'] != null)
                            Text('Rule-based: ${_details!['rule_confidence']}%'),
                          if (_details!['ml_confidence'] != null)
                            Text('ML-based: ${_details!['ml_confidence']}%'),
                          const SizedBox(height: 8),
                          Text('Details:', style: TextStyle(fontWeight: FontWeight.bold)),
                          ..._details!['features'].entries.map((e) => Text('${e.key}: ${e.value}')).toList(),
                        ],
                      ),
                    )
                  : null,
            ),
          ),
        ],
        if (_result != null && _result!.startsWith('Error'))
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              _result!,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}

class _CreditCardReminderWidget extends StatefulWidget {
  @override
  State<_CreditCardReminderWidget> createState() => _CreditCardReminderWidgetState();
}

class _CreditCardReminderWidgetState extends State<_CreditCardReminderWidget> {
  String? _ccFrequency;
  String? _creditScoreFrequency;
  DateTime? _ccNextReminder;
  DateTime? _creditScoreNextReminder;
  String? _confirmation;

  static const List<String> _frequencies = [
    'Daily',
    'Weekly (Recommended)',
    'Monthly',
    'Quarterly',
    'Half-yearly',
    'Yearly',
  ];

  DateTime _calculateNextReminder(String frequency) {
    final now = DateTime.now();
    switch (frequency) {
      case 'Daily':
        return now.add(const Duration(days: 1));
      case 'Weekly (Recommended)':
        return now.add(const Duration(days: 7));
      case 'Monthly':
        return DateTime(now.year, now.month + 1, now.day);
      case 'Quarterly':
        return DateTime(now.year, now.month + 3, now.day);
      case 'Half-yearly':
        return DateTime(now.year, now.month + 6, now.day);
      case 'Yearly':
        return DateTime(now.year + 1, now.month, now.day);
      default:
        return now;
    }
  }

  Future<void> _scheduleNotification({required int id, required String title, required String body, required DateTime scheduledTime}) async {
    await NotificationService().scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _ccFrequency,
          decoration: const InputDecoration(
            labelText: 'Credit Card Count Reminder Frequency',
            border: OutlineInputBorder(),
          ),
          items: _frequencies.map((freq) => DropdownMenuItem(
            value: freq,
            child: Text(freq),
          )).toList(),
          onChanged: (val) async {
            setState(() {
              _ccFrequency = val;
              if (val != null) {
                _ccNextReminder = _calculateNextReminder(val);
                _confirmation = 'Reminder set to check credit card count every $val. Next: ${_ccNextReminder!.toLocal()}';
              }
            });
            if (val != null && _ccNextReminder != null) {
              await _scheduleNotification(
                id: 2001,
                title: 'Credit Card Reminder',
                body: 'Time to check how many credit cards are in your name!',
                scheduledTime: _ccNextReminder!,
              );
            }
          },
        ),
        if (_ccNextReminder != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('Next reminder: ${_ccNextReminder!.toLocal()}'),
          ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _creditScoreFrequency,
          decoration: const InputDecoration(
            labelText: 'Credit Score Reminder Frequency',
            border: OutlineInputBorder(),
          ),
          items: _frequencies.map((freq) => DropdownMenuItem(
            value: freq,
            child: Text(freq),
          )).toList(),
          onChanged: (val) async {
            setState(() {
              _creditScoreFrequency = val;
              if (val != null) {
                _creditScoreNextReminder = _calculateNextReminder(val);
                _confirmation = 'Reminder set to check credit score every $val. Next: ${_creditScoreNextReminder!.toLocal()}';
              }
            });
            if (val != null && _creditScoreNextReminder != null) {
              await _scheduleNotification(
                id: 2002,
                title: 'Credit Score Reminder',
                body: 'Time to check your credit score!',
                scheduledTime: _creditScoreNextReminder!,
              );
            }
          },
        ),
        if (_creditScoreNextReminder != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('Next reminder: ${_creditScoreNextReminder!.toLocal()}'),
          ),
        if (_confirmation != null)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(_confirmation!, style: const TextStyle(color: Colors.green)),
          ),
      ],
    );
  }
} 