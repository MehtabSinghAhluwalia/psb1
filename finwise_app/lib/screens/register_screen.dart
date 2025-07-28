import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  Future<void> register() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
    });
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5001/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text,
      }),
    );
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      setState(() {
        successMessage = 'Registration successful! Please log in.';
      });
      // Optionally, navigate to login screen automatically:
      // Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() {
        errorMessage = jsonDecode(response.body)['error'] ?? 'Registration failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
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
            if (successMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(successMessage!, style: TextStyle(color: Colors.green)),
              ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: register,
                    child: Text('Register'),
                  ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
