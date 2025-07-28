import 'package:flutter/material.dart';
import 'package:finwise_app/widgets/finwise_app_bar.dart';
import 'package:finwise_app/widgets/finwise_drawer.dart';

class HelpContactScreen extends StatefulWidget {
  const HelpContactScreen({super.key});

  @override
  State<HelpContactScreen> createState() => _HelpContactScreenState();
}

class _HelpContactScreenState extends State<HelpContactScreen> {
  String? _selectedBank;

  final Map<String, String> _bankContacts = {
    'Punjab & Sind Bank': '1800-419-8300',
    'State Bank of India': '1800-1234',
    'HDFC Bank': '1800-202-6161',
    'ICICI Bank': '1800-1080',
    'Axis Bank': '1800-419-5959',
    'Bank of Baroda': '1800-102-4455',
    'Punjab National Bank': '1800-180-2222',
    'Canara Bank': '1800-425-0018',
    'Union Bank of India': '1800-22-2244',
    'Bank of India': '1800-220-229',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FinwiseAppBar(
        context: context,
        subtitle: 'Help & Contact',
      ),
      endDrawer: const FinwiseDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'In case of any query and fraud please connect to your bank via toll free number',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _selectedBank,
              decoration: const InputDecoration(
                labelText: 'Select your bank',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Select your bank'),
                ),
                ..._bankContacts.keys.map((bank) => DropdownMenuItem(
                  value: bank,
                  child: Text(bank),
                )),
              ],
              onChanged: (val) {
                setState(() {
                  _selectedBank = val;
                });
              },
            ),
            const SizedBox(height: 24),
            if (_selectedBank != null && _bankContacts[_selectedBank!] != null)
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${_selectedBank!} Toll Free: ${_bankContacts[_selectedBank!]}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 