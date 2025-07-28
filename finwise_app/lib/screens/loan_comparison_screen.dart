import 'package:flutter/material.dart';
import 'package:finwise_app/widgets/finwise_app_bar.dart';

class LoanComparisonScreen extends StatelessWidget {
  const LoanComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FinwiseAppBar(
        context: context,
        subtitle: 'Loan Comparison',
      ),
      body: const Center(child: Text('Loan Comparison Coming Soon!')),
    );
  }
} 