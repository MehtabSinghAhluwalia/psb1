import 'package:flutter/material.dart';
import 'package:finwise_app/widgets/finwise_app_bar.dart';
import 'package:finwise_app/widgets/finwise_drawer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FinwiseAppBar(
        context: context,
        subtitle: 'About',
      ),
      endDrawer: const FinwiseDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('About Punjab & Sind Bank App', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Version: 1.0.0'),
            const SizedBox(height: 16),
            Text(
              'This app was developed for Punjab & Sind Bank (PSB) in collaboration with Punjab Technical University (PTU) as part of a hackathon initiative.\n',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Text(
              'Punjab & Sind Bank App is designed to empower users with financial knowledge and tools. It helps users learn about banking, manage their finances, set and track financial goals, calculate investments, and stay secure with fraud awareness modules. The app features interactive learning modules, calculators for loans, savings, and investments, and provides practical tips for safe and smart banking.\n\nWhether you are new to banking or looking to improve your financial literacy, Punjab & Sind Bank App offers a comprehensive platform to support your financial journey.',
            ),
            const SizedBox(height: 16),
            Text('Developed in collaboration with Punjab & Sind Bank and Punjab Technical University (PTU).'),
            const SizedBox(height: 24),
            Center(
              child: Image.asset(
                'assets/images/ptu logo.png',
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            Center(child: Text('© 2024 Punjab & Sind Bank App. All rights reserved.')),
          ],
        ),
      ),
    );
  }
} 