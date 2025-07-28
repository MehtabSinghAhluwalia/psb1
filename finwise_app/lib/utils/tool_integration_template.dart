// Template for integrating AppState data flow into any tool
// This shows the pattern used in EMI Calculator that can be applied to other tools

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../models/app_state.dart';

/*
TEMPLATE FOR TOOL INTEGRATION WITH APPSTATE DATA FLOW

This template shows how to integrate any tool with the unified AppState data flow
for recommendations, analysis, and predictions.

Key Components:
1. Pre-fill forms with existing data
2. Generate recommendations using AppState data
3. Show cross-tool insights
4. Log interactions for ML/AI training
5. Prepare data for backend ML/AI models

Example Implementation Pattern:
*/

class ToolIntegrationTemplate {
  
  // 1. PRE-FILL FORM WITH EXISTING DATA
  static void prefillFormWithExistingData(BuildContext context, Map<String, TextEditingController> controllers) {
    final appState = Provider.of<AppState>(context, listen: false);
    
    // Example: Pre-fill with existing data from AppState
    if (appState.goals.isNotEmpty) {
      // Pre-fill goal-related fields
    }
    if (appState.loans.isNotEmpty) {
      // Pre-fill loan-related fields
    }
    // ... etc for other data types
  }

  // 2. GENERATE RECOMMENDATIONS USING APPSTATE DATA
  static Map<String, dynamic> generateRecommendations(BuildContext context, Map<String, dynamic> toolInput) {
    final appState = Provider.of<AppState>(context, listen: false);
    final financialSnapshot = appState.getUserFinancialSnapshot();
    
    List<String> recommendations = [];
    List<String> warnings = [];
    List<String> insights = [];

    // Example analysis patterns:
    
    // A. Income-based analysis
    if (appState.taxProfile != null) {
      double monthlyIncome = appState.taxProfile!.income / 12;
      // Analyze tool input against income
    }

    // B. Goal impact analysis
    if (appState.goals.isNotEmpty) {
      double totalGoalAmount = appState.goals
          .map((g) => g.targetAmount - g.currentAmount)
          .reduce((a, b) => a + b);
      // Analyze how tool affects goals
    }

    // C. Investment comparison
    if (appState.investments.isNotEmpty) {
      double avgReturn = appState.investments
          .map((i) => i.expectedReturn)
          .reduce((a, b) => a + b) / appState.investments.length;
      // Compare with investment returns
    }

    // D. Loan commitment analysis
    if (appState.loans.isNotEmpty) {
      double totalEMI = appState.loans
          .map((l) => l.emiAmount)
          .reduce((a, b) => a + b);
      // Analyze against existing commitments
    }

    return {
      'recommendations': recommendations,
      'warnings': warnings,
      'insights': insights,
      'financialSnapshot': financialSnapshot,
    };
  }

  // 3. LOG INTERACTION FOR ML/AI TRAINING
  static void logInteraction(BuildContext context, String toolName, String action, 
      Map<String, dynamic> input, Map<String, dynamic> output, Map<String, dynamic> recommendations) {
    
    final appState = Provider.of<AppState>(context, listen: false);
    final financialSnapshot = appState.getUserFinancialSnapshot();
    
    final interactionLog = {
      'timestamp': DateTime.now().toIso8601String(),
      'tool': toolName,
      'action': action,
      'input': input,
      'output': output,
      'userFinancialSnapshot': financialSnapshot,
      'recommendations': recommendations,
    };

    // In production, send this to your ML/AI backend
    print('ML/AI Training Data: ${jsonEncode(interactionLog)}');
  }

  // 4. PREPARE DATA FOR BACKEND ML/AI MODELS
  static Map<String, dynamic> prepareDataForML(BuildContext context, Map<String, dynamic> toolSpecificData) {
    final appState = Provider.of<AppState>(context, listen: false);
    
    return {
      'toolData': toolSpecificData,
      'userProfile': {
        'income': appState.taxProfile?.income,
        'age': appState.retirementPlan?.currentAge,
        'riskProfile': _determineRiskProfile(appState),
        'financialGoals': appState.goals.length,
        'existingCommitments': appState.loans.length,
        'investmentExperience': appState.investments.length,
      },
      'financialSummary': {
        'totalGoals': appState.goals.isNotEmpty ? appState.goals.map((g) => g.targetAmount).reduce((a, b) => a + b) : 0.0,
        'totalLoans': appState.loans.isNotEmpty ? appState.loans.map((l) => l.principal).reduce((a, b) => a + b) : 0.0,
        'totalInvestments': appState.investments.isNotEmpty ? appState.investments.map((i) => i.amount).reduce((a, b) => a + b) : 0.0,
        'monthlyEMI': appState.loans.isNotEmpty ? appState.loans.map((l) => l.emiAmount).reduce((a, b) => a + b) : 0.0,
      },
      'goals': appState.goals.map((g) => {
        'title': g.title,
        'targetAmount': g.targetAmount,
        'currentAmount': g.currentAmount,
        'category': g.category,
        'priority': g.priority,
      }).toList(),
      'loans': appState.loans.map((l) => {
        'type': l.type,
        'principal': l.principal,
        'emiAmount': l.emiAmount,
        'interestRate': l.interestRate,
      }).toList(),
      'investments': appState.investments.map((i) => {
        'type': i.type,
        'amount': i.amount,
        'expectedReturn': i.expectedReturn,
        'riskProfile': i.riskProfile,
      }).toList(),
    };
  }

  // 5. UI COMPONENTS FOR SHOWING RECOMMENDATIONS
  static Widget buildRecommendationsCard(BuildContext context, Map<String, dynamic> recommendations) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Our Recommendations & Analysis',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 16),
            if ((recommendations['recommendations'] as List).isNotEmpty) ...[
              Text('✅ Recommendations:', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...(recommendations['recommendations'] as List<String>)
                  .map((rec) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• $rec'),
                      ))
                  .toList(),
              const SizedBox(height: 16),
            ],
            if ((recommendations['warnings'] as List).isNotEmpty) ...[
              Text('⚠️ Warnings:', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
              const SizedBox(height: 8),
              ...(recommendations['warnings'] as List<String>)
                  .map((warning) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• $warning', style: const TextStyle(color: Colors.orange)),
                      ))
                  .toList(),
            ],
            if ((recommendations['insights'] as List).isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('💡 Insights:', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(height: 8),
              ...(recommendations['insights'] as List<String>)
                  .map((insight) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• $insight', style: const TextStyle(color: Colors.blue)),
                      ))
                  .toList(),
            ],
          ],
        ),
      ),
    );
  }

  // 6. FINANCIAL OVERVIEW CARD
  static Widget buildFinancialOverviewCard(BuildContext context) {
    final appState = context.watch<AppState>();
    
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Financial Overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Active Loans: ${appState.loans.length}'),
            Text('Total Goals: ${appState.goals.length}'),
            Text('Total Investments: ${appState.investments.length}'),
            if (appState.taxProfile != null)
              Text('Monthly Income: ₹${(appState.taxProfile!.income / 12).toStringAsFixed(0)}'),
          ],
        ),
      ),
    );
  }

  // Helper method to determine user's risk profile
  static String _determineRiskProfile(AppState appState) {
    if (appState.investments.isEmpty) return 'Conservative';
    
    double avgReturn = appState.investments
        .map((i) => i.expectedReturn)
        .reduce((a, b) => a + b) / appState.investments.length;
    
    if (avgReturn > 12) return 'Aggressive';
    if (avgReturn > 8) return 'Moderate';
    return 'Conservative';
  }
}

/*
IMPLEMENTATION STEPS FOR ANY TOOL:

1. Add to initState():
   WidgetsBinding.instance.addPostFrameCallback((_) {
     ToolIntegrationTemplate.prefillFormWithExistingData(context, controllers);
   });

2. After calculation/action:
   final recommendations = ToolIntegrationTemplate.generateRecommendations(context, toolInput);
   ToolIntegrationTemplate.logInteraction(context, 'tool_name', 'action_name', input, output, recommendations);

3. In build method, add:
   ToolIntegrationTemplate.buildFinancialOverviewCard(context),
   ToolIntegrationTemplate.buildRecommendationsCard(context, recommendations),

4. For ML/AI backend calls:
   final mlData = ToolIntegrationTemplate.prepareDataForML(context, toolSpecificData);
   // Send mlData to your backend API

This pattern ensures consistent data flow, recommendations, and ML/AI integration across all tools.
*/ 