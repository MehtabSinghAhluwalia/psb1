class FraudCase {
  final String title;
  final String description;
  final String preventionTips;
  final String category;
  final String severity;

  FraudCase({
    required this.title,
    required this.description,
    required this.preventionTips,
    required this.category,
    required this.severity,
  });

  static List<FraudCase> getSampleCases() {
    return [
      FraudCase(
        title: 'Phishing Scams',
        description: 'Phishing is a cyber attack where fraudsters impersonate legitimate organizations to steal your personal information, especially banking credentials.\n\nKey Concepts:\n1. What is Phishing?\n   - Fake emails and messages\n   - Impersonation of banks and companies\n   - Urgent or threatening language\n   - Requests for personal information\n\n2. Common Phishing Tactics\n   - Fake login pages\n   - Suspicious links\n   - Urgent account verification\n   - Prize or reward scams\n   - Tax refund scams\n\n3. Red Flags to Watch For\n   - Poor grammar and spelling\n   - Generic greetings\n   - Suspicious sender addresses\n   - Urgent deadlines\n   - Requests for passwords or PINs',
        preventionTips: 'Prevention Tips:\n- Never share banking credentials\n- Banks never ask for passwords via email\n- Always verify sender email addresses\n- Use official bank websites\n- Enable two-factor authentication',
        category: 'Online Banking',
        severity: 'High',
      ),
      FraudCase(
        title: 'ATM Skimming',
        description: 'Criminals install devices on ATMs to steal card information and PINs.',
        preventionTips: 'Check for unusual devices on ATMs. Cover the keypad while entering PIN. Use ATMs in well-lit, secure locations.',
        category: 'Physical Security',
        severity: 'High',
      ),
      FraudCase(
        title: 'Investment Scams',
        description: 'Fraudsters offer fake investment opportunities promising high returns with low risk.',
        preventionTips: 'Be skeptical of guaranteed high returns. Research investment opportunities thoroughly. Verify the company\'s registration.',
        category: 'Investments',
        severity: 'Medium',
      ),
      FraudCase(
        title: 'SIM Swap Fraud',
        description: 'Criminals transfer your phone number to their SIM card to intercept OTPs and access your accounts.',
        preventionTips: 'Enable SIM lock PIN. Monitor your phone for unexpected loss of service. Use additional authentication methods.',
        category: 'Mobile Banking',
        severity: 'High',
      ),
      FraudCase(
        title: 'UPI Fraud',
        description: 'Scammers trick victims into making UPI payments or sharing UPI PIN.',
        preventionTips: 'Never share UPI PIN. Verify payment requests carefully. Use UPI apps with additional security features.',
        category: 'Digital Payments',
        severity: 'High',
      ),
      FraudCase(
        title: 'Credit Card Fraud',
        description: 'Credit card fraud involves unauthorized use of your credit card information to make purchases or withdraw funds.\n\nHow it happens:\n- Identity theft: Stealing your personal information to open new cards in your name.\n- Card skimming: Copying card data from ATMs or POS machines.\n- Phishing: Tricking you into revealing card details online.\n- Lost/stolen cards: Physical theft of your card.\n- Data breaches: Hackers accessing card databases.\n',
        preventionTips: 'Prevention Tips:\n- Never share your card details or OTPs.\n- Regularly check your credit card statements.\n- Use cards only on trusted websites.\n- Enable transaction alerts.\n- Report lost or stolen cards immediately.\n- Set strong PINs and change them regularly.\n- Shred old statements and cards.',
        category: 'Credit Card',
        severity: 'High',
      ),
    ];
  }
} 