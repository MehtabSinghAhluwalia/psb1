import 'package:flutter/material.dart';
import 'package:finwise_app/theme/app_theme.dart';
import 'package:finwise_app/widgets/finwise_drawer.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Image.asset(
              'assets/images/logo.png',
              width: 32,
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Punjab & Sind Bank',
                  style: TextStyle(
                    color: AppTheme.secondaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Profile',
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
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {},
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: const FinwiseDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.person, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('User Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('This is a placeholder for user information.'),
          ],
        ),
      ),
    );
  }
} 