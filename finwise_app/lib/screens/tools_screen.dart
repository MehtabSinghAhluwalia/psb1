import 'package:flutter/material.dart';
import 'emi_calculator_screen.dart';
import 'goals_screen.dart';
import 'package:finwise_app/theme/app_theme.dart';
import 'budget_calculator_screen.dart';
import 'investment_calculator_screen.dart';
import 'tax_calculator_screen.dart';
import 'retirement_planner_screen.dart';
import 'loan_comparison_screen.dart';
import 'credit_score_simulator_screen.dart';
import 'insurance_premium_calculator_screen.dart';
import 'profile_screen.dart';
import 'package:finwise_app/l10n/app_localizations.dart';
import 'package:finwise_app/screens/settings_screen.dart';
import 'package:finwise_app/widgets/finwise_drawer.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        leading: null,
        title: Row(
          children: [
            Image.asset(
              'assets/images/newlogo.png',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.bankName,
                    style: TextStyle(
                      color: AppTheme.secondaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    AppLocalizations.of(context)!.financialTools,
                    style: TextStyle(
                      color: AppTheme.secondaryColor,
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text(AppLocalizations.of(context)!.profileClicked)),
              );
            },
          ),
        ],
      ),
      endDrawer: const FinwiseDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildToolCard(
            context,
            AppLocalizations.of(context)!.budgetCalculator,
            AppLocalizations.of(context)!.budgetCalculatorDesc,
            Icons.account_balance_wallet,
            Colors.blue,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BudgetCalculatorScreen(),
              ),
            ),
          ),
          _buildToolCard(
            context,
            AppLocalizations.of(context)!.investmentCalculator,
            AppLocalizations.of(context)!.investmentCalculatorDesc,
            Icons.trending_up,
            Colors.green,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const InvestmentCalculatorScreen(),
              ),
            ),
          ),
          _buildToolCard(
            context,
            AppLocalizations.of(context)!.emiCalculator,
            AppLocalizations.of(context)!.emiCalculatorDesc,
            Icons.calculate,
            Colors.orange,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EMICalculatorScreen(),
              ),
            ),
          ),
          _buildToolCard(
            context,
            AppLocalizations.of(context)!.taxCalculator,
            AppLocalizations.of(context)!.taxCalculatorDesc,
            Icons.account_balance,
            Colors.purple,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TaxCalculatorScreen(),
              ),
            ),
          ),
          _buildToolCard(
            context,
            AppLocalizations.of(context)!.retirementPlanner,
            AppLocalizations.of(context)!.retirementPlannerDesc,
            Icons.work,
            Colors.red,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RetirementPlannerScreen(),
              ),
            ),
          ),
          _buildToolCard(
            context,
            AppLocalizations.of(context)!.loanComparison,
            AppLocalizations.of(context)!.loanComparisonDesc,
            Icons.compare_arrows,
            Colors.teal,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LoanComparisonScreen(),
              ),
            ),
          ),
          _buildToolCard(
            context,
            AppLocalizations.of(context)!.savingsGoalTracker,
            AppLocalizations.of(context)!.savingsGoalTrackerDesc,
            Icons.flag,
            Colors.amber,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GoalsScreen(),
              ),
            ),
          ),
          _buildToolCard(
            context,
            AppLocalizations.of(context)!.creditScoreSimulator,
            AppLocalizations.of(context)!.creditScoreSimulatorDesc,
            Icons.score,
            Colors.indigo,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreditScoreSimulatorScreen(),
              ),
            ),
          ),
          _buildToolCard(
            context,
            AppLocalizations.of(context)!.insurancePremiumCalculator,
            AppLocalizations.of(context)!.insurancePremiumCalculatorDesc,
            Icons.health_and_safety,
            Colors.pink,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const InsurancePremiumCalculatorScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
