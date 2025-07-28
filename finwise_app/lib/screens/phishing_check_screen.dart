import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:finwise_app/providers/language_provider.dart';
import 'package:provider/provider.dart';

class PhishingCheckScreen extends StatefulWidget {
  const PhishingCheckScreen({Key? key}) : super(key: key);

  @override
  _PhishingCheckScreenState createState() => _PhishingCheckScreenState();
}

class _PhishingCheckScreenState extends State<PhishingCheckScreen> {
  final TextEditingController _urlController = TextEditingController();
  String? _result;
  Map<String, dynamic>? _details;
  bool _loading = false;

  Future<String> _translateText(String text, String targetLang) async {
    const backendUrl = String.fromEnvironment('BACKEND_URL', defaultValue: 'http://127.0.0.1:5001');
    final url = Uri.parse('$backendUrl/translate');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text, 'target_lang': targetLang}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['translated_text'] ?? text;
    } else {
      return text;
    }
  }

  Future<void> checkPhishing() async {
    setState(() {
      _loading = true;
      _result = null;
      _details = null;
    });
    final url = 'http://192.168.1.2:5001/api/check'; // Updated for mobile access
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': _urlController.text}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String resultText = data['is_phishing'] ? 'Phishing Detected!' : 'Safe Link';
        // Multilingual translation logic
        final lang = Provider.of<LanguageProvider>(context, listen: false).locale.languageCode;
        if (lang != 'en') {
          resultText = await _translateText(resultText, lang);
        }
        setState(() {
          _result = resultText;
          _details = data;
        });
      } else {
        setState(() {
          _result = 'Error: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color? resultColor;
    IconData? resultIcon;
    if (_result != null) {
      if (_result == 'Phishing Detected!') {
        resultColor = Colors.red[100];
        resultIcon = Icons.warning_amber_rounded;
      } else if (_result == 'Safe Link') {
        resultColor = Colors.green[100];
        resultIcon = Icons.check_circle_outline;
      } else {
        resultColor = Colors.grey[200];
        resultIcon = Icons.info_outline;
      }
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Phishing URL Checker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Enter URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : checkPhishing,
                icon: const Icon(Icons.search),
                label: const Text('Check for Phishing'),
              ),
            ),
            const SizedBox(height: 24),
            if (_loading)
              const Center(child: CircularProgressIndicator()),
            if (_result != null && !_loading) ...[
              Card(
                color: resultColor,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Icon(resultIcon, size: 40, color: resultColor == Colors.red[100] ? Colors.red : Colors.green),
                  title: Text(
                    _result!,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: resultColor == Colors.red[100] ? Colors.red[900] : Colors.green[900],
                    ),
                  ),
                  subtitle: _details != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Confidence: ${_details!['confidence']}%'),
                              if (_details!['rule_confidence'] != null)
                                Text('Rule-based: ${_details!['rule_confidence']}%'),
                              if (_details!['ml_confidence'] != null)
                                Text('ML-based: ${_details!['ml_confidence']}%'),
                              const SizedBox(height: 8),
                              Text('Details:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ..._details!['features'].entries.map((e) => Text('${e.key}: ${e.value}')).toList(),
                            ],
                          ),
                        )
                      : null,
                ),
              ),
            ],
            if (_result != null && _result!.startsWith('Error'))
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _result!,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 