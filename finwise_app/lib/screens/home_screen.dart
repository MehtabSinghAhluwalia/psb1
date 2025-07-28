import 'package:flutter/material.dart';
import 'package:finwise_app/theme/app_theme.dart';
import 'package:finwise_app/main.dart';
import 'package:finwise_app/l10n/app_localizations.dart';
import 'package:finwise_app/screens/settings_screen.dart';
import 'package:finwise_app/screens/profile_screen.dart';
import 'package:finwise_app/widgets/finwise_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Row(
          children: [
            Image.asset(
              'assets/images/newlogo.png',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.appName,
                  style: TextStyle(
                    color: AppTheme.secondaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.slogan,
                  style: TextStyle(
                    color: AppTheme.secondaryColor,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      endDrawer: const FinwiseDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  _buildFinancialOverview(context),
                  const SizedBox(height: 24),
                  _buildRecentTransactions(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.quickActions,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionButton(
              context,
              AppLocalizations.of(context)!.learn,
              Icons.school,
              AppTheme.primaryColor,
              () => _navigateToScreen(context, 1),
            ),
            _buildActionButton(
              context,
              AppLocalizations.of(context)!.security,
              Icons.security,
              AppTheme.secondaryColor,
              () => _navigateToScreen(context, 2),
            ),
            _buildActionButton(
              context,
              AppLocalizations.of(context)!.tools,
              Icons.calculate,
              AppTheme.accentColor,
              () => _navigateToScreen(context, 3),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildFinancialOverview(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.financialOverview,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOverviewItem(
                    context,
                    AppLocalizations.of(context)!.totalBalance,
                    '₹25,000',
                    Icons.account_balance_wallet,
                    AppTheme.primaryColor,
                  ),
                ),
                Expanded(
                  child: _buildOverviewItem(
                    context,
                    AppLocalizations.of(context)!.monthlySavings,
                    '₹5,000',
                    Icons.savings,
                    AppTheme.accentColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.recentTransactions,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {},
              child: Text(AppLocalizations.of(context)!.viewAll),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Icon(
                    index % 2 == 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    color: index % 2 == 0
                        ? AppTheme.errorColor
                        : AppTheme.accentColor,
                  ),
                ),
                title: Text(
                  index % 2 == 0
                      ? AppLocalizations.of(context)!.paymentToMerchant
                      : AppLocalizations.of(context)!.salaryReceived,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  AppLocalizations.of(context)!.todayAt(
                    '${index + 1}:00 PM',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                trailing: Text(
                  AppLocalizations.of(context)!.currencyAmount(
                    index % 2 == 0 ? '-' : '+',
                    ((index + 1) * 1000).toString(),
                  ),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: index % 2 == 0
                            ? AppTheme.errorColor
                            : AppTheme.accentColor,
                      ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _navigateToScreen(BuildContext context, int index) {
    if (context.mounted) {
      final MainScreenState? state =
          context.findAncestorStateOfType<MainScreenState>();
      state?.setSelectedIndex(index);
    }
  }
}
