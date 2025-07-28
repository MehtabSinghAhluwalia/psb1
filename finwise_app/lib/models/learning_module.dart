class LearningModuleStep {
  final String title;
  final List<String> steps;

  LearningModuleStep({required this.title, required this.steps});
}

class LearningModule {
  final String title;
  final String description;
  final String content;
  final String category;
  final int duration; // in minutes
  final String difficulty;
  final List<String> keyPoints;
  final List<LearningModuleStep>? instructions; // Optional step-by-step instructions

  LearningModule({
    required this.title,
    required this.description,
    required this.content,
    required this.category,
    required this.duration,
    required this.difficulty,
    required this.keyPoints,
    this.instructions,
  });

  static List<LearningModule> getSampleModules() {
    return [
      LearningModule(
        title: 'Understanding Banking Basics',
        description: 'Learn the fundamental concepts of banking and how to manage your accounts effectively.',
        content: '',
        category: 'Banking Basics',
        duration: 15,
        difficulty: 'Beginner',
        keyPoints: [],
        instructions: [
          LearningModuleStep(
            title: 'Fundamentals of Banking',
            steps: [
              'Different types of bank accounts and their purposes',
              'Essential banking services and how to use them',
              'Best practices for account management',
              'Security measures to protect your accounts',
              '',
              'Banking is an essential part of our financial lives. Understanding the basics helps you make better financial decisions.',
              '',
              'Key Concepts:',
              '1. Types of Bank Accounts',
              '   - Savings Accounts',
              '   - Current Accounts',
              '   - Fixed Deposits',
              '   - Recurring Deposits',
              '',
              '2. Banking Services',
              '   - Online Banking',
              '   - Mobile Banking',
              '   - ATM Services',
              '   - Fund Transfers',
              '',
              '3. Account Management',
              '   - Maintaining Minimum Balance',
              '   - Understanding Interest Rates',
              '   - Bank Statements',
              '   - Transaction Records',
              '',
              '4. Security Measures',
              '   - PIN and Password Protection',
              '   - Two-Factor Authentication',
              '   - Regular Statement Review',
              '   - Safe Banking Practices',
            ],
          ),
          LearningModuleStep(
            title: 'How to Open a Bank Account',
            steps: [
              'Choose the type of account you want to open (savings, current, etc.).',
              'Visit the bank branch or go to the bank’s website.',
              'Fill out the account opening form.',
              'Submit required documents (ID, address proof, photos).',
              'Deposit the minimum required balance.',
              'Collect your passbook, cheque book, and debit card.',
            ],
          ),
          LearningModuleStep(
            title: 'How to Apply for a Cheque Book',
            steps: [
              'Log in to your bank’s online portal or visit the branch.',
              'Go to the cheque book request section.',
              'Select the account for which you need the cheque book.',
              'Enter the number of cheque leaves required.',
              'Submit your request.',
              'Collect the cheque book from the branch or receive it by post.',
            ],
          ),
          LearningModuleStep(
            title: 'How to Use a Cheque',
            steps: [
              'Write the date on the cheque.',
              'Write the payee’s name (the person or company you are paying).',
              'Write the amount in words and figures.',
              'Sign the cheque as per your bank records.',
              'If needed, write your account number on the back.',
              'Hand over the cheque to the payee or deposit it in the bank.',
            ],
          ),
          LearningModuleStep(
            title: 'How to Update KYC (Know Your Customer)',
            steps: [
              'Collect the required KYC documents (ID proof, address proof, photo).',
              'Visit your bank branch or log in to the bank’s online portal.',
              'Fill out the KYC update form.',
              'Submit the form along with the documents.',
              'Bank staff will verify your documents.',
              'Receive confirmation of KYC update from the bank.',
            ],
          ),
        ],
      ),
      LearningModule(
        title: 'Investment Fundamentals',
        description: 'Discover the basics of investing and how to grow your wealth over time.',
        content: '''
Investing is a powerful tool for wealth creation. Understanding investment fundamentals helps you make informed decisions.

Key Concepts:
1. Investment Types
   - Stocks
   - Bonds
   - Mutual Funds
   - Fixed Deposits

2. Risk and Return
   - Risk Assessment
   - Expected Returns
   - Diversification
   - Investment Horizon

3. Investment Planning
   - Setting Goals
   - Asset Allocation
   - Regular Review
   - Rebalancing

4. Investment Strategies
   - Long-term Investing
   - Systematic Investment Plans
   - Dollar-Cost Averaging
   - Portfolio Management
''',
        category: 'Investments',
        duration: 20,
        difficulty: 'Intermediate',
        keyPoints: [
          'Understanding different investment options',
          'Relationship between risk and return',
          'Creating an investment plan',
          'Implementing investment strategies',
        ],
        instructions: [
          LearningModuleStep(
            title: 'How to Start Investing',
            steps: [
              'Set your investment goals.',
              'Assess your risk tolerance.',
              'Choose investment products (stocks, mutual funds, FDs, etc.).',
              'Open an investment account or demat account.',
              'Make your first investment.',
              'Monitor and review your investments regularly.',
            ],
          ),
        ],
      ),
      LearningModule(
        title: 'Fixed Deposit (FD) Essentials',
        description: 'Understand what Fixed Deposits are, how they work, their benefits, and how to make the most of them.',
        content: '''
A Fixed Deposit (FD) is a financial instrument provided by banks or NBFCs which offers investors a higher rate of interest than a regular savings account, until the given maturity date.

Key Concepts:
1. What is a Fixed Deposit?
   - Lump sum deposit for a fixed tenure
   - Higher interest rates than savings accounts
   - Safe and low-risk investment

2. How Interest is Calculated
   - Simple vs. Compound Interest
   - Interest payout options: monthly, quarterly, or at maturity
   - Premature withdrawal penalties

3. Tax Implications
   - Interest earned is taxable as per your income slab
   - TDS (Tax Deducted at Source) if interest exceeds threshold
   - Form 15G/15H to avoid TDS for eligible individuals

4. Benefits of Fixed Deposits
   - Capital protection
   - Assured returns
   - Flexible tenure options
   - Loan against FD facility

5. Tips for Choosing an FD
   - Compare interest rates across banks
   - Check for premature withdrawal rules
   - Consider laddering FDs for liquidity
   - Evaluate tax-saving FDs (5-year lock-in)
''',
        category: 'Investments',
        duration: 12,
        difficulty: 'Beginner',
        keyPoints: [
          'What is a Fixed Deposit and how it works',
          'How interest is calculated and paid',
          'Taxation rules for FD interest',
          'Benefits and safety of FDs',
          'Tips for maximizing FD returns',
        ],
        instructions: [
          LearningModuleStep(
            title: 'How to Make a Fixed Deposit',
            steps: [
              'Visit your bank branch or log in to your bank’s online portal.',
              'Choose the Fixed Deposit option.',
              'Enter the deposit amount and select the tenure.',
              'Choose the interest payout option (monthly, quarterly, or at maturity).',
              'Review the interest rate and terms.',
              'Confirm and submit your application.',
              'Deposit the amount (if offline) or authorize the transaction (if online).',
              'Collect or download the FD receipt/certificate.',
            ],
          ),
          LearningModuleStep(
            title: 'How to Withdraw a Fixed Deposit',
            steps: [
              'Log in to your bank’s online portal or visit the branch.',
              'Go to the Fixed Deposit section.',
              'Select the FD you wish to withdraw.',
              'Choose premature or maturity withdrawal as per your need.',
              'Review any penalties (for premature withdrawal).',
              'Submit the withdrawal request.',
              'The amount will be credited to your linked account.',
              'Download or collect the closure receipt.',
            ],
          ),
        ],
      ),
      LearningModule(
        title: 'Digital Banking Security',
        description: 'Learn how to protect yourself while using digital banking services.',
        content: '''
Digital banking offers convenience but requires proper security measures. This module covers essential security practices.

Key Concepts:
1. Digital Banking Security
   - Strong Passwords
   - Two-Factor Authentication
   - Secure Networks
   - Device Security

2. Common Threats
   - Phishing Attacks
   - Malware
   - Social Engineering
   - Identity Theft

3. Safe Practices
   - Regular Password Updates
   - Secure Login Methods
   - Transaction Monitoring
   - Account Alerts

4. Emergency Response
   - Reporting Fraud
   - Account Freezing
   - Recovery Procedures
   - Customer Support
''',
        category: 'Security',
        duration: 15,
        difficulty: 'Beginner',
        keyPoints: [
          'Essential security measures for digital banking',
          'Identifying and avoiding common threats',
          'Implementing safe banking practices',
          'Responding to security incidents',
        ],
        instructions: [
          LearningModuleStep(
            title: 'How to Stay Safe with Digital Banking',
            steps: [
              'Set strong, unique passwords for your accounts.',
              'Enable two-factor authentication.',
              'Avoid using public Wi-Fi for banking.',
              'Regularly update your banking app.',
              'Monitor your account for suspicious activity.',
              'Report any unauthorized transactions immediately.',
            ],
          ),
        ],
      ),
    ];
  }
} 