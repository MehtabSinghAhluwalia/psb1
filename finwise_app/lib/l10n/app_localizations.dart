import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_pa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('pa')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Punjab & Sind Bank'**
  String get appName;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @slogan.
  ///
  /// In en, this message translates to:
  /// **'Where service is a way of life'**
  String get slogan;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @learn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learn;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @tools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tools;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @restartRequired.
  ///
  /// In en, this message translates to:
  /// **'Please restart the app for changes to take effect'**
  String get restartRequired;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'Punjab & Sind Bank'**
  String get bankName;

  /// No description provided for @financialTools.
  ///
  /// In en, this message translates to:
  /// **'Financial Tools'**
  String get financialTools;

  /// No description provided for @helpContact.
  ///
  /// In en, this message translates to:
  /// **'Help & Contact'**
  String get helpContact;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @settingsClicked.
  ///
  /// In en, this message translates to:
  /// **'Settings clicked'**
  String get settingsClicked;

  /// No description provided for @helpContactClicked.
  ///
  /// In en, this message translates to:
  /// **'Help & Contact clicked'**
  String get helpContactClicked;

  /// No description provided for @aboutClicked.
  ///
  /// In en, this message translates to:
  /// **'About clicked'**
  String get aboutClicked;

  /// No description provided for @budgetCalculator.
  ///
  /// In en, this message translates to:
  /// **'Budget Calculator'**
  String get budgetCalculator;

  /// No description provided for @budgetCalculatorDesc.
  ///
  /// In en, this message translates to:
  /// **'Plan your monthly budget'**
  String get budgetCalculatorDesc;

  /// No description provided for @investmentCalculator.
  ///
  /// In en, this message translates to:
  /// **'Investment Calculator'**
  String get investmentCalculator;

  /// No description provided for @investmentCalculatorDesc.
  ///
  /// In en, this message translates to:
  /// **'Calculate potential returns'**
  String get investmentCalculatorDesc;

  /// No description provided for @emiCalculator.
  ///
  /// In en, this message translates to:
  /// **'EMI Calculator'**
  String get emiCalculator;

  /// No description provided for @emiCalculatorDesc.
  ///
  /// In en, this message translates to:
  /// **'Calculate loan EMIs'**
  String get emiCalculatorDesc;

  /// No description provided for @taxCalculator.
  ///
  /// In en, this message translates to:
  /// **'Tax Calculator'**
  String get taxCalculator;

  /// No description provided for @taxCalculatorDesc.
  ///
  /// In en, this message translates to:
  /// **'Estimate your tax liability'**
  String get taxCalculatorDesc;

  /// No description provided for @retirementPlanner.
  ///
  /// In en, this message translates to:
  /// **'Retirement Planner'**
  String get retirementPlanner;

  /// No description provided for @retirementPlannerDesc.
  ///
  /// In en, this message translates to:
  /// **'Plan for your retirement'**
  String get retirementPlannerDesc;

  /// No description provided for @loanComparison.
  ///
  /// In en, this message translates to:
  /// **'Loan Comparison'**
  String get loanComparison;

  /// No description provided for @loanComparisonDesc.
  ///
  /// In en, this message translates to:
  /// **'Compare different loan options'**
  String get loanComparisonDesc;

  /// No description provided for @savingsGoalTracker.
  ///
  /// In en, this message translates to:
  /// **'Savings Goal Tracker'**
  String get savingsGoalTracker;

  /// No description provided for @savingsGoalTrackerDesc.
  ///
  /// In en, this message translates to:
  /// **'Track your savings goals'**
  String get savingsGoalTrackerDesc;

  /// No description provided for @creditScoreSimulator.
  ///
  /// In en, this message translates to:
  /// **'Credit Score Simulator'**
  String get creditScoreSimulator;

  /// No description provided for @creditScoreSimulatorDesc.
  ///
  /// In en, this message translates to:
  /// **'Simulate your credit score'**
  String get creditScoreSimulatorDesc;

  /// No description provided for @insurancePremiumCalculator.
  ///
  /// In en, this message translates to:
  /// **'Insurance Premium Calculator'**
  String get insurancePremiumCalculator;

  /// No description provided for @insurancePremiumCalculatorDesc.
  ///
  /// In en, this message translates to:
  /// **'Calculate insurance premiums'**
  String get insurancePremiumCalculatorDesc;

  /// No description provided for @profileClicked.
  ///
  /// In en, this message translates to:
  /// **'Profile clicked'**
  String get profileClicked;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @financialOverview.
  ///
  /// In en, this message translates to:
  /// **'Financial Overview'**
  String get financialOverview;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// No description provided for @monthlySavings.
  ///
  /// In en, this message translates to:
  /// **'Monthly Savings'**
  String get monthlySavings;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @paymentToMerchant.
  ///
  /// In en, this message translates to:
  /// **'Payment to Merchant'**
  String get paymentToMerchant;

  /// No description provided for @salaryReceived.
  ///
  /// In en, this message translates to:
  /// **'Salary Received'**
  String get salaryReceived;

  /// No description provided for @todayAt.
  ///
  /// In en, this message translates to:
  /// **'Today, {time}'**
  String todayAt(Object time);

  /// No description provided for @currencyAmount.
  ///
  /// In en, this message translates to:
  /// **'{sign}₹{amount}'**
  String currencyAmount(Object amount, Object sign);

  /// No description provided for @financialEducation.
  ///
  /// In en, this message translates to:
  /// **'Financial Education'**
  String get financialEducation;

  /// No description provided for @financialEducationDesc.
  ///
  /// In en, this message translates to:
  /// **'Enhance your financial knowledge with our comprehensive learning modules'**
  String get financialEducationDesc;

  /// No description provided for @filterByCategory.
  ///
  /// In en, this message translates to:
  /// **'Filter by Category'**
  String get filterByCategory;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration: {duration} mins'**
  String duration(Object duration);

  /// No description provided for @keyPoints.
  ///
  /// In en, this message translates to:
  /// **'Key Points'**
  String get keyPoints;

  /// No description provided for @content.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get content;

  /// No description provided for @beginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// No description provided for @intermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediate;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @staySafe.
  ///
  /// In en, this message translates to:
  /// **'Stay Safe'**
  String get staySafe;

  /// No description provided for @fraudAwarenessDesc.
  ///
  /// In en, this message translates to:
  /// **'Learn about common fraud types and how to protect yourself'**
  String get fraudAwarenessDesc;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @preventionTips.
  ///
  /// In en, this message translates to:
  /// **'Prevention Tips'**
  String get preventionTips;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'hi', 'pa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'hi': return AppLocalizationsHi();
    case 'pa': return AppLocalizationsPa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
