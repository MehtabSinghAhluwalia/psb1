import 'package:flutter/material.dart';
import 'package:finwise_app/theme/app_theme.dart';
import 'package:finwise_app/l10n/app_localizations.dart';

class FinwiseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final BuildContext context;
  final String? subtitle;
  final List<Widget>? actions;

  const FinwiseAppBar({
    Key? key,
    required this.context,
    this.subtitle,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(this.context)!;
    return AppBar(
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
                  localizations.bankName,
                  style: TextStyle(
                    color: AppTheme.secondaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle ?? '',
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
      actions: actions ??
          [
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
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(content: Text(localizations.profileClicked)),
                );
              },
            ),
          ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
