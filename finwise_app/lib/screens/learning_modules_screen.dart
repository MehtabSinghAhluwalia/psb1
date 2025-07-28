import 'package:flutter/material.dart';
import 'package:finwise_app/models/learning_module.dart';
import 'package:finwise_app/theme/app_theme.dart';
import 'package:finwise_app/l10n/app_localizations.dart';
import 'package:finwise_app/screens/settings_screen.dart';
import 'package:finwise_app/screens/profile_screen.dart';
import '../main.dart'; // For NotificationService
import 'dart:convert'; // Added for jsonEncode and jsonDecode
import 'package:http/http.dart' as http; // Added for http requests
import 'package:finwise_app/widgets/finwise_app_bar.dart';
import 'package:finwise_app/widgets/finwise_drawer.dart'; // Added for FinwiseDrawer
// Removed dart:html import for mobile compatibility

class LearningModulesScreen extends StatefulWidget {
  const LearningModulesScreen({super.key});

  @override
  State<LearningModulesScreen> createState() => _LearningModulesScreenState();
}

class _LearningModulesScreenState extends State<LearningModulesScreen> {
  final List<LearningModule> _modules = LearningModule.getSampleModules();
  String _selectedCategory = 'All';

  List<String> get _categories {
    final categories = _modules.map((e) => e.category).toSet().toList();
    categories.insert(0, AppLocalizations.of(context)!.all);
    return categories;
  }

  List<LearningModule> get _filteredModules {
    if (_selectedCategory == AppLocalizations.of(context)!.all) {
      return _modules;
    }
    return _modules.where((e) => e.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FinwiseAppBar(
        context: context,
        subtitle: AppLocalizations.of(context)!.financialEducation,
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
                  AppLocalizations.of(context)!.financialEducation,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.financialEducationDesc,
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
              itemCount: _filteredModules.length,
              itemBuilder: (context, index) {
                final module = _filteredModules[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LearningModuleDetailPage(module: module),
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
                                  module.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getDifficultyColor(module.difficulty),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  getDifficultyLabel(context, module.difficulty),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            module.description,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.duration(module.duration.toString()),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                module.category,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
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

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getDifficultyLabel(BuildContext context, String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return AppLocalizations.of(context)!.beginner;
      case 'intermediate':
        return AppLocalizations.of(context)!.intermediate;
      case 'advanced':
        return AppLocalizations.of(context)!.advanced;
      default:
        return difficulty;
    }
  }
}

class LearningModuleDetailPage extends StatefulWidget {
  final LearningModule module;
  const LearningModuleDetailPage({super.key, required this.module});

  @override
  State<LearningModuleDetailPage> createState() => _LearningModuleDetailPageState();
}

class _LearningModuleDetailPageState extends State<LearningModuleDetailPage> {
  // Track checkbox state for each instruction step
  late List<List<bool>> _checkedSteps;
  int? _selectedInstructionIndex;
  bool _showAccountSurvey = false;
  String? _accountPurpose;
  String? _initialDeposit;
  String? _monthlyTransactions;
  String? _accountUsage;
  String? _recommendedAccount;

  @override
  void initState() {
    super.initState();
    // Initialize checkbox state for each instruction set (if any)
    if (widget.module.instructions != null) {
      _checkedSteps = widget.module.instructions!
          .map((inst) => List<bool>.filled(inst.steps.length, false))
          .toList();
    } else {
      _checkedSteps = [];
    }
  }

  Future<void> _analyzeAccountPreferences() async {
    // Get current language code
    String currentLang = Localizations.localeOf(context).languageCode;
    final response = await http.post(
              Uri.parse('http://192.168.1.2:5001/recommend_account_type'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'accountPurpose': _accountPurpose,
        'initialDeposit': _initialDeposit,
        'monthlyTransactions': _monthlyTransactions,
        'accountUsage': _accountUsage,
        'target_lang': currentLang, // <-- Add this line
      }),
    );
    final data = jsonDecode(response.body);
    setState(() {
      _recommendedAccount = data['recommended_account_type'];
    });
  }

  Widget _buildAccountSurvey() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account Type Recommendation Survey',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _accountPurpose,
                decoration: const InputDecoration(
                  labelText: 'Primary purpose of the account',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'Savings',
                  'Business',
                  'Investment',
                  'Salary',
                  'Student',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _accountPurpose = newValue;
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _initialDeposit,
                decoration: const InputDecoration(
                  labelText: 'Initial deposit amount',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'Less than ₹10,000',
                  '₹10,000 - ₹50,000',
                  '₹50,000 - ₹1,00,000',
                  'More than ₹1,00,000',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _initialDeposit = newValue;
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _monthlyTransactions,
                decoration: const InputDecoration(
                  labelText: 'Expected monthly transactions',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'Less than 10',
                  '10-25',
                  '25-50',
                  'More than 50',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _monthlyTransactions = newValue;
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _accountUsage,
                decoration: const InputDecoration(
                  labelText: 'How will you use this account?',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'Regular salary deposits',
                  'Personal savings',
                  'Business transactions',
                  'Investment purposes',
                  'Student expenses',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _accountUsage = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _accountPurpose != null && _initialDeposit != null && 
                            _monthlyTransactions != null && _accountUsage != null
                      ? _analyzeAccountPreferences
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Get Account Recommendation'),
                ),
              ),
              if (_recommendedAccount != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recommended Account Type:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _recommendedAccount!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Based on your preferences, this account type would be most suitable for your needs.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scheduleNextPendingStepNotification();
    super.dispose();
  }

  void _scheduleNextPendingStepNotification() {
    final module = widget.module;
    if (module.instructions == null || module.instructions!.isEmpty) return;
    for (int i = 0; i < _checkedSteps.length; i++) {
      final stepIndex = _checkedSteps[i].indexWhere((checked) => !checked);
      if (stepIndex != -1) {
        // Found the next pending step
        final stepTitle = module.instructions![i].title;
        final stepText = module.instructions![i].steps[stepIndex];
        // Schedule notification 1 hour from now
        final scheduledTime = DateTime.now().add(const Duration(hours: 1));
        NotificationService().scheduleNotification(
          id: (module.title + i.toString() + stepIndex.toString()).hashCode,
          title: 'Reminder: ${module.title}',
          body: 'Next step: $stepTitle - $stepText',
          scheduledTime: scheduledTime,
        );
        break;
      }
    }
  }

  Widget _buildSavingsMethodSurvey() {
    // State for survey
    String? _goal, _depositFrequency, _risk, _amount, _duration, _recommendation, _reason;
    bool _loading = false;
    final _formKey = GlobalKey<FormState>();

    return StatefulBuilder(
      builder: (context, setState) {
        Future<void> _submit() async {
          if (!_formKey.currentState!.validate()) return;
          setState(() => _loading = true);
          // Get current language code
          String currentLang = Localizations.localeOf(context).languageCode;
          final response = await http.post(
            Uri.parse('http://192.168.1.2:5001/recommend_savings_method'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'goal': _goal,
              'amount': _amount,
              'duration': _duration,
              'deposit_frequency': _depositFrequency,
              'risk': _risk,
              'target_lang': currentLang, // <-- Add this line
            }),
          );
          final data = jsonDecode(response.body);
          setState(() {
            _recommendation = data['recommended_method'];
            _reason = data['reason'];
            _loading = false;
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text('Find the Best Savings Method for You', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _goal,
                    decoration: const InputDecoration(labelText: 'Savings Goal', border: OutlineInputBorder()),
                    items: ['Short-term', 'Long-term', 'Emergency', 'Retirement']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _goal = val),
                    validator: (val) => val == null ? 'Select a goal' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Amount (₹)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => _amount = val,
                    validator: (val) => val == null || val.isEmpty ? 'Enter amount' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Duration (months)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => _duration = val,
                    validator: (val) => val == null || val.isEmpty ? 'Enter duration' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _depositFrequency,
                    decoration: const InputDecoration(labelText: 'Deposit Frequency', border: OutlineInputBorder()),
                    items: ['Once', 'Monthly']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _depositFrequency = val),
                    validator: (val) => val == null ? 'Select frequency' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _risk,
                    decoration: const InputDecoration(labelText: 'Risk Preference', border: OutlineInputBorder()),
                    items: ['Low', 'Medium', 'High']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _risk = val),
                    validator: (val) => val == null ? 'Select risk' : null,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading ? const CircularProgressIndicator() : const Text('Get Savings Recommendation'),
                    ),
                  ),
                ],
              ),
            ),
            if (_recommendation != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: Colors.green[50],
                  child: ListTile(
                    title: Text('Recommended: ${_recommendation ?? ""}', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(_reason ?? ''),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final module = widget.module;
    return Scaffold(
      appBar: FinwiseAppBar(
        context: context,
        subtitle: module.title,
      ),
      endDrawer: const FinwiseDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                module.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                module.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              // --- FD Savings Method Survey Button ---
              if (module.title == 'Fixed Deposit (FD) Essentials')
                _buildSavingsMethodSurvey(),
              const SizedBox(height: 24),
              if (module.instructions != null && module.instructions!.isNotEmpty) ...[
                Text(
                  'Step-by-Step Instructions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: _selectedInstructionIndex,
                  decoration: const InputDecoration(
                    labelText: 'Select Action',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text(''),
                    ),
                    ...List.generate(module.instructions!.length, (i) => DropdownMenuItem(
                      value: i,
                      child: Text(module.instructions![i].title),
                    )),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedInstructionIndex = val;
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (_selectedInstructionIndex != null)
                  Builder(
                    builder: (context) {
                      final instructionSet = module.instructions![_selectedInstructionIndex!];
                      // If Fundamentals of Banking (heading) is selected, show key points and content
                      if (instructionSet.title == 'Fundamentals of Banking') {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Content', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...instructionSet.steps.map((step) => 
                              step.isEmpty 
                                ? const SizedBox(height: 8) 
                                : Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      step,
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  )
                            ),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            instructionSet.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          // Add account recommendation button for "How to Open a Bank Account"
                          if (instructionSet.title == 'How to Open a Bank Account') ...[
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 16),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _showAccountSurvey = !_showAccountSurvey;
                                  });
                                },
                                icon: const Icon(Icons.account_balance),
                                label: Text(_showAccountSurvey ? 'Hide Account Survey' : 'Check for Suitable Account Type'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            if (_showAccountSurvey) _buildAccountSurvey(),
                          ],
                          ...List.generate(instructionSet.steps.length, (j) {
                            return CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              value: _checkedSteps[_selectedInstructionIndex!][j],
                              onChanged: (val) {
                                setState(() {
                                  _checkedSteps[_selectedInstructionIndex!][j] = val ?? false;
                                });
                              },
                              title: Text(instructionSet.steps[j]),
                            );
                          }),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.duration(module.duration.toString()),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    module.category,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 