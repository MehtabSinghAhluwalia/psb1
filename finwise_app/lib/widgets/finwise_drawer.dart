import 'package:flutter/material.dart';
import 'package:finwise_app/theme/app_theme.dart';
import 'package:finwise_app/screens/settings_screen.dart';
import 'package:finwise_app/l10n/app_localizations.dart';
import 'package:finwise_app/screens/help_contact_screen.dart';
import 'package:finwise_app/screens/about_screen.dart';

class FinwiseDrawer extends StatelessWidget {
  const FinwiseDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 100,
                          height: 60,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context)?.bankName ?? 'Punjab & Sind Bank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text(AppLocalizations.of(context)?.settings ?? 'Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: Text(AppLocalizations.of(context)?.helpContact ?? 'Help & Contact'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HelpContactScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: Text(AppLocalizations.of(context)?.about ?? 'About'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text(
                    'In collaboration with',
                    style: TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Image.asset(
                    'assets/images/ptu logo.png',
                    height: 48,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 