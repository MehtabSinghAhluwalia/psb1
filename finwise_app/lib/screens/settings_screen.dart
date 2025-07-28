import 'package:flutter/material.dart';
import 'package:finwise_app/theme/app_theme.dart';
import 'package:finwise_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:finwise_app/providers/language_provider.dart';
import 'package:finwise_app/widgets/finwise_app_bar.dart';
import 'package:finwise_app/widgets/finwise_drawer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLanguage = prefs.getString('language') ?? 'en';
    });
  }

  Future<void> _changeLanguage(String languageCode) async {
    Provider.of<LanguageProvider>(context, listen: false).setLocale(languageCode);
    setState(() {
      _currentLanguage = languageCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FinwiseAppBar(
        context: context,
        subtitle: AppLocalizations.of(context)!.settings,
      ),
      endDrawer: const FinwiseDrawer(),
      body: ListView(
        children: [
          ListTile(
            title: Text(AppLocalizations.of(context)!.language),
            subtitle: Text(_getLanguageName(_currentLanguage)),
            leading: const Icon(Icons.language),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(AppLocalizations.of(context)!.selectLanguage),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLanguageOption('en', 'English'),
                      _buildLanguageOption('hi', 'हिंदी'),
                      _buildLanguageOption('pa', 'ਪੰਜਾਬੀ'),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: Text(AppLocalizations.of(context)!.notifications),
            leading: const Icon(Icons.notifications),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Handle notifications toggle
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(AppLocalizations.of(context)!.darkMode),
            leading: const Icon(Icons.dark_mode),
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // Handle dark mode toggle
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String code, String name) {
    return ListTile(
      title: Text(name),
      trailing: _currentLanguage == code
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () {
        _changeLanguage(code);
        Navigator.pop(context);
      },
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिंदी';
      case 'pa':
        return 'ਪੰਜਾਬੀ';
      default:
        return 'English';
    }
  }
} 