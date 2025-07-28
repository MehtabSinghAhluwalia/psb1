import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final storage = FlutterSecureStorage();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  Future<void> login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5001/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': emailController.text.trim(),
        'password': passwordController.text,
      }),
    );
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'jwt_token', value: data['access_token']);
      await storage.write(key: 'user_id', value: data['user_id'].toString());
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        errorMessage = jsonDecode(response.body)['error'] ?? 'Login failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(errorMessage!, style: TextStyle(color: Colors.red)),
              ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: login,
                    child: Text('Login'),
                  ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/register');
              },
              child: Text('Don\'t have an account? Register'),
            ),
          ],
        ),
      ),
    );
  }
} 