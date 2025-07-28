import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../models/app_state.dart';
import '../utils/tool_integration_template.dart';
import '../utils/export_data.dart';
import 'package:finwise_app/widgets/finwise_app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finwise_app/providers/language_provider.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  Map<String, dynamic>? _recommendations;
  bool _isTranslating = false;
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  Locale? _lastLocale;

  @override
  void initState() {
    super.initState();
    // Generate recommendations when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateRecommendations();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLocale = Provider.of<LanguageProvider>(context).locale;
    if (_lastLocale != currentLocale) {
      _lastLocale = currentLocale;
      _generateRecommendations();
    }
  }

  Future<String> _getCurrentLanguage() async {
    // Use the provider's locale for current language
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    return langProvider.locale.languageCode;
  }

  Future<String> _translateText(String text, String targetLang) async {
    // Use LAN IP if running on device/simulator, fallback to localhost for web
    const backendUrl = String.fromEnvironment('BACKEND_URL', defaultValue: 'http://127.0.0.1:5001');
    final url = Uri.parse('$backendUrl/translate');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text, 'target_lang': targetLang}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['translated_text'] ?? text;
    } else {
      return text;
    }
  }

  Future<void> _generateRecommendations() async {
    setState(() { _isTranslating = true; });
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      List<String> recommendations = [];
      List<String> warnings = [];
      List<String> insights = [];
      if (appState.goals.isNotEmpty) {
        // Calculate total goal requirements
        double totalGoalAmount = appState.goals.map((g) => g.targetAmount - g.currentAmount).reduce((a, b) => a + b);
        double totalCurrentAmount = appState.goals.map((g) => g.currentAmount).reduce((a, b) => a + b);
        double totalTargetAmount = appState.goals.map((g) => g.targetAmount).reduce((a, b) => a + b);
        
        // Calculate total investments and loans
        double totalInvestments = appState.investments.isNotEmpty ? appState.investments.map((i) => i.amount).reduce((a, b) => a + b) : 0.0;
        double totalEMI = appState.loans.isNotEmpty ? appState.loans.map((l) => l.emiAmount).reduce((a, b) => a + b) : 0.0;

        // Goal feasibility analysis
        if (appState.taxProfile != null) {
          double monthlyIncome = appState.taxProfile!.income / 12;
          double monthlyGoalSavings = totalGoalAmount / 12; // Simplified calculation
          double goalSavingsRatio = (monthlyGoalSavings / monthlyIncome) * 100;
          
          if (goalSavingsRatio > 50) {
            warnings.add('⚠️ Your goals require ${goalSavingsRatio.toStringAsFixed(1)}% of monthly income - consider prioritizing or extending timelines');
          } else if (goalSavingsRatio > 30) {
            recommendations.add('✅ Goal savings requirement (${goalSavingsRatio.toStringAsFixed(1)}% of income) is manageable');
          } else {
            recommendations.add('✅ Goal savings requirement is conservative and achievable');
          }
        }

        // Goal prioritization analysis
        var highPriorityGoals = appState.goals.where((g) => g.priority <= 3).toList();
        if (highPriorityGoals.length > 3) {
          warnings.add('⚠️ You have ${highPriorityGoals.length} high-priority goals - consider focusing on fewer goals for better success');
        } else {
          recommendations.add('✅ Good goal prioritization with ${highPriorityGoals.length} high-priority goals');
        }

        // Timeline analysis
        var shortTermGoals = appState.goals.where((g) => g.targetDate.difference(DateTime.now()).inDays < 365).toList();
        if (shortTermGoals.isNotEmpty) {
          double shortTermAmount = shortTermGoals.map((g) => g.targetAmount - g.currentAmount).reduce((a, b) => a + b);
          insights.add('💡 You have ${shortTermGoals.length} short-term goals requiring ₹${_currencyFormat.format(shortTermAmount)}');
        }

        // Investment vs Goal alignment
        if (totalInvestments > 0) {
          double investmentToGoalRatio = (totalInvestments / totalTargetAmount) * 100;
          if (investmentToGoalRatio > 100) {
            recommendations.add('✅ Your investments exceed your goal requirements - excellent financial planning!');
          } else if (investmentToGoalRatio > 50) {
            insights.add('💡 Your investments cover ${investmentToGoalRatio.toStringAsFixed(1)}% of your goal requirements');
          } else {
            warnings.add('⚠️ Your investments cover only ${investmentToGoalRatio.toStringAsFixed(1)}% of your goal requirements');
          }
        }

        // EMI impact on goals
        if (totalEMI > 0 && appState.taxProfile != null) {
          double monthlyIncome = appState.taxProfile!.income / 12;
          double emiToIncomeRatio = (totalEMI / monthlyIncome) * 100;
          double availableForGoals = monthlyIncome - totalEMI;
          double goalSavingsNeeded = totalGoalAmount / 12;
          
          if (goalSavingsNeeded > availableForGoals * 0.8) {
            warnings.add('⚠️ Your EMI commitments may limit your ability to save for goals');
          } else {
            insights.add('💡 After EMI payments, you have sufficient income for goal savings');
          }
        }

        // Goal completion analysis
        double overallProgress = (totalCurrentAmount / totalTargetAmount) * 100;
        if (overallProgress > 50) {
          recommendations.add('🎉 Excellent progress! You\'ve completed ${overallProgress.toStringAsFixed(1)}% of your goals');
        } else if (overallProgress > 25) {
          insights.add('💪 Good progress with ${overallProgress.toStringAsFixed(1)}% goal completion');
        } else {
          insights.add('📈 You\'re ${overallProgress.toStringAsFixed(1)}% towards your goals - keep going!');
        }

        // Category diversification
        var categories = appState.goals.map((g) => g.category).toSet();
        if (categories.length >= 3) {
          recommendations.add('✅ Well-diversified goals across ${categories.length} categories');
        } else {
          insights.add('💡 Consider diversifying your goals across more categories');
        }

        final lang = await _getCurrentLanguage();
        print('DEBUG: Current language for translation: $lang');
        if (lang != 'en') {
          try {
            recommendations = await Future.wait(recommendations.map((r) async {
              final t = await _translateText(r, lang);
              print('DEBUG: Translated "$r" to "$t"');
              return t;
            }));
            warnings = await Future.wait(warnings.map((w) async {
              final t = await _translateText(w, lang);
              print('DEBUG: Translated "$w" to "$t"');
              return t;
            }));
            insights = await Future.wait(insights.map((i) async {
              final t = await _translateText(i, lang);
              print('DEBUG: Translated "$i" to "$t"');
              return t;
            }));
          } catch (e) {
            print('ERROR: Translation failed: $e');
            recommendations.add('Translation failed. Showing English.');
          }
        }
        setState(() {
          _recommendations = {
            'recommendations': recommendations,
            'warnings': warnings,
            'insights': insights,
            'totalGoalAmount': totalGoalAmount,
            'totalCurrentAmount': totalCurrentAmount,
            'totalTargetAmount': totalTargetAmount,
            'totalInvestments': totalInvestments,
            'totalEMI': totalEMI,
            'overallProgress': overallProgress,
          };
        });
      } else {
        setState(() {
          _recommendations = {
            'recommendations': [],
            'warnings': [],
            'insights': [],
          };
        });
      }
    } catch (e) {
      print('ERROR: Failed to generate recommendations: $e');
      setState(() {
        _recommendations = {
          'recommendations': ['Error generating recommendations.'],
          'warnings': [],
          'insights': [],
        };
      });
    } finally {
      setState(() { _isTranslating = false; });
    }
  }

  void _logGoalInteraction(String action, Map<String, dynamic> goalData) {
    final appState = Provider.of<AppState>(context, listen: false);
    final financialSnapshot = appState.getUserFinancialSnapshot();
    
    final interactionLog = {
      'timestamp': DateTime.now().toIso8601String(),
      'tool': 'goals_screen',
      'action': action,
      'input': goalData,
      'output': {
        'totalGoals': appState.goals.length,
        'totalGoalAmount': appState.goals.isNotEmpty ? appState.goals.map((g) => g.targetAmount).reduce((a, b) => a + b) : 0.0,
        'goalCategories': appState.goals.map((g) => g.category).toSet().length,
      },
      'userFinancialSnapshot': financialSnapshot,
      'recommendations': _recommendations,
    };

    print('ML/AI Training Data: ${jsonEncode(interactionLog)}');
  }

  void _showAddGoalDialog() {
    final titleController = TextEditingController();
    final targetAmountController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 365));
    final categoryController = TextEditingController();
    final priorityController = TextEditingController();

    // Pre-fill with existing goal data if available
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.goals.isNotEmpty) {
      final lastGoal = appState.goals.last;
      titleController.text = 'New ${lastGoal.category} Goal';
      categoryController.text = lastGoal.category;
      priorityController.text = (lastGoal.priority + 1).toString();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Goal'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Goal Title'),
              ),
              TextField(
                controller: targetAmountController,
                decoration: const InputDecoration(labelText: 'Target Amount'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Target Date'),
                subtitle: Text(selectedDate.toString().split(' ')[0]),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (date != null) {
                    setState(() => selectedDate = date);
                  }
                },
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextField(
                controller: priorityController,
                decoration: const InputDecoration(labelText: 'Priority (1-5, 1=highest)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  targetAmountController.text.isNotEmpty &&
                  categoryController.text.isNotEmpty &&
                  priorityController.text.isNotEmpty) {
                final goal = Goal(
                  id: const Uuid().v4(),
                  title: titleController.text,
                  targetAmount: double.parse(targetAmountController.text),
                  currentAmount: 0,
                  targetDate: selectedDate,
                  category: categoryController.text,
                  priority: int.parse(priorityController.text),
                );
                
                // Log the goal addition
                _logGoalInteraction('add_goal', {
                  'title': goal.title,
                  'targetAmount': goal.targetAmount,
                  'category': goal.category,
                  'priority': goal.priority,
                  'targetDate': goal.targetDate.toIso8601String(),
                });
                
                Provider.of<AppState>(context, listen: false).addGoal(goal);
                
                // Regenerate recommendations after adding goal
                _generateRecommendations();
                
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final goals = appState.goals;
    
    return Scaffold(
      appBar: FinwiseAppBar(
        context: context,
        subtitle: 'Financial Goals',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddGoalDialog,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export Goal Data',
            onPressed: () async {
              print('Export button pressed');
              await exportGoalFeasibilityData(appState, 'goal_training_data.json');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exported goal_training_data.json')),
                );
          }
            },
          ),
        ],
      ),
      body: _isTranslating
          ? const Center(child: CircularProgressIndicator())
          : goals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.flag,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No goals yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _showAddGoalDialog,
                    child: const Text('Add Your First Goal'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Financial Overview Card
                  ToolIntegrationTemplate.buildFinancialOverviewCard(context),
                  const SizedBox(height: 16),
                  
                  // Recommendations Section
                  if (_recommendations != null) ...[
                    ToolIntegrationTemplate.buildRecommendationsCard(context, _recommendations!),
                    const SizedBox(height: 24),
                  ],
                  
                  // Goals List
                  Text('Your Goals:', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  ...goals.map((goal) => Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(
                    Icons.savings,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                                      goal.category,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                                '${(goal.currentAmount / goal.targetAmount * 100).toInt()}% Complete',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                Text(
                                '${_currencyFormat.format(goal.currentAmount)} / ${_currencyFormat.format(goal.targetAmount)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
                          const SizedBox(height: 8.0),
                          Text('Priority: ${goal.priority}'),
                          Text('Target Date: ${goal.targetDate.toLocal().toString().split(' ')[0]}'),
                        ],
                      ),
                    ),
                  )).toList(),
          ],
        ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddGoalDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Goal'),
      ),
    );
  }
} 
