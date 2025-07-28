import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:finwise_app/screens/home_screen.dart';
import 'package:finwise_app/screens/savings_calculator_screen.dart';
import 'package:finwise_app/screens/budget_calculator_screen.dart';
import 'package:finwise_app/screens/learning_modules_screen.dart';
import 'package:finwise_app/screens/fraud_awareness_screen.dart';
import 'package:finwise_app/screens/emi_calculator_screen.dart';
import 'package:finwise_app/screens/profile_screen.dart';
import 'package:finwise_app/screens/tools_screen.dart';
import 'package:finwise_app/screens/login_screen.dart';
import 'package:finwise_app/screens/settings_screen.dart';
import 'package:finwise_app/providers/goals_provider.dart';
import 'package:finwise_app/theme/app_theme.dart';
import 'package:finwise_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/learning_modules_screen.dart';
import 'screens/fraud_awareness_screen.dart';
import 'screens/emi_calculator_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/tools_screen.dart';
import 'screens/login_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/goals_provider.dart';
import 'theme/app_theme.dart';
import 'package:finwise_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/savings_calculator_screen.dart';
import 'screens/budget_calculator_screen.dart';
import 'models/app_state.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
// Temporarily disabled for APK build
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
import 'package:finwise_app/providers/language_provider.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Notification Service Singleton - Temporarily disabled for APK build
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    // Temporarily disabled
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // Temporarily disabled
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    // Temporarily disabled
  }
}

Future<List<Map<String, dynamic>>> fetchLoans() async {
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'jwt_token');
  final userId = await storage.read(key: 'user_id');
  final response = await http.get(
    Uri.parse('http://127.0.0.1:5001/get_loans/$userId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to fetch loans');
  }
}

Future<void> showAddLoanDialog(BuildContext context, VoidCallback onLoanAdded) async {
  final loanTypeController = TextEditingController();
  final amountController = TextEditingController();
  final interestController = TextEditingController();
  final tenureController = TextEditingController();
  bool isLoading = false;
  String? error;

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add Loan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: loanTypeController, decoration: InputDecoration(labelText: 'Loan Type')),
              TextField(controller: amountController, decoration: InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
              TextField(controller: interestController, decoration: InputDecoration(labelText: 'Interest Rate (%)'), keyboardType: TextInputType.number),
              TextField(controller: tenureController, decoration: InputDecoration(labelText: 'Tenure (years)'), keyboardType: TextInputType.number),
              if (error != null) Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(error!, style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setState(() => isLoading = true);
                      final storage = FlutterSecureStorage();
                      final token = await storage.read(key: 'jwt_token');
                      final response = await http.post(
                        Uri.parse('http://127.0.0.1:5001/add_loan'),
                        headers: {
                          'Content-Type': 'application/json',
                          'Authorization': 'Bearer $token',
                        },
                        body: jsonEncode({
                          'loan_type': loanTypeController.text,
                          'amount': double.tryParse(amountController.text) ?? 0,
                          'interest_rate': double.tryParse(interestController.text) ?? 0,
                          'tenure_years': int.tryParse(tenureController.text) ?? 0,
                        }),
                      );
                      setState(() => isLoading = false);
                      if (response.statusCode == 200) {
                        Navigator.pop(context);
                        onLoanAdded();
                      } else {
                        setState(() {
                          error = jsonDecode(response.body)['error'] ?? 'Failed to add loan';
                        });
                      }
                    },
              child: isLoading ? CircularProgressIndicator() : Text('Add'),
            ),
          ],
        ),
      );
    },
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // tz.initializeTimeZones(); // Temporarily disabled
  await NotificationService().init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return MaterialApp(
      title: 'Finwise App',
        theme: ThemeData(
        primarySwatch: Colors.blue,
        ),
        home: const SplashScreen(),
      routes: {
        '/savings-calculator': (context) => SavingsCalculatorScreen(),
        '/budget-calculator': (context) => BudgetCalculatorScreen(),
        // Add other named routes as needed
      },
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('hi'),
          Locale('pa'),
        ],
      locale: languageProvider.locale,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 160,
                height: 160,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 32),
              Text(
                'Punjab & Sind Bank',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryColor,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black26,
                      offset: Offset(1, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '(A Govt. of India Undertaking)',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
            Text(
                'Where service is a way of life',
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.w600,
                ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void setSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _screens = [
    HomeScreen(),
    LearningModulesScreen(),
    FraudAwarenessScreen(),
    ToolsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Learn',
          ),
          NavigationDestination(
            icon: Icon(Icons.security_outlined),
            selectedIcon: Icon(Icons.security),
            label: 'Security',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'Tools',
          ),
        ],
      ),
    );
  }
}

Future<void> exportGoalFeasibilityData(AppState appState) async {
  final List<Map<String, dynamic>> data = [];
  for (final goal in appState.goals) {
    final achieved = (goal.currentAmount / goal.targetAmount) > 0.95 ? 1 : 0;
    data.add({
      'income': appState.taxProfile?.income ?? 0,
      'total_loans': appState.loans.fold(0.0, (sum, l) => sum + l.principal),
      'total_investments': appState.investments.fold(0.0, (sum, i) => sum + i.amount),
      'goal_amount': goal.targetAmount,
      'goal_priority': goal.priority,
      'goal_time_months': goal.targetDate.difference(DateTime.now()).inDays ~/ 30,
      'achieved': achieved,
    });
  }

  // Get the app's document directory
  final dir = await getApplicationDocumentsDirectory();
  final filePath = '${dir.path}/goal_training_data.json';
  final file = File(filePath);
  await file.writeAsString(jsonEncode(data));
  print('Exported goal feasibility data to $filePath');
}
