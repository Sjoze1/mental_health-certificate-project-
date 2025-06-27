// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool showPassword = false;
  bool rememberMe = false;
  bool isLoading = false;
  bool hoverBtn = false;
  String? error;

  void handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.55.57.66:8000/api/login'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save token and therapist_id locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);

        // Save user name
        await prefs.setString('name', data['user']['name']); // Save user name

        // Save profile picture if it exists
        if (data['user'] != null) {
          await prefs.setString('profile_picture', data['user']['profile_picture']);
        }

        // Save therapist_id if present at top level
        if (data.containsKey('therapist_id')) {
          await prefs.setInt('therapist_id', data['therapist_id']);
        } else {
          // Handle case where therapist ID is not in response
        }

        // Navigate
        Navigator.pushReplacementNamed(context, '/');
      } else {
        setState(() {
          error = data['message'] ?? 'Invalid login credentials';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Login failed. Please check your connection.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF003366), Color(0xFF6A8D9B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                color: Colors.white.withOpacity(0.9),
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Icon(Icons.favorite, color: Color(0xFF2B7ABB), size: 40),
                        const SizedBox(height: 12),
                        const Text(
                          'Welcome to Your Mental Health Hub',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2980B9),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Log in to your Mental Health & Psychosocial Support account',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF95A5A6)),
                        ),
                        const SizedBox(height: 20),

                        if (error != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              error!,
                              style: const TextStyle(color: Color(0xFFE74C3C)),
                            ),
                          ),

                        const SizedBox(height: 16),
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Email is required';
                            final regex = RegExp(r'.+@.+\..+');
                            if (!regex.hasMatch(value)) return 'Email must be valid';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: passwordController,
                          obscureText: !showPassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => showPassword = !showPassword),
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Password is required' : null,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: rememberMe,
                                  onChanged: (val) => setState(() => rememberMe = val ?? false),
                                  activeColor: const Color(0xFF2B7ABB),
                                ),
                                const Text('Remember me'),
                              ],
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(color: Color(0xFF2B7ABB)),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        MouseRegion(
                          onEnter: (_) => setState(() => hoverBtn = true),
                          onExit: (_) => setState(() => hoverBtn = false),
                          child: ElevatedButton(
                            onPressed: isLoading ? null : handleLogin,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor: hoverBtn
                                  ? const Color(0xFF3498DB)
                                  : const Color(0xFF2B7ABB),
                              foregroundColor: Colors.white,
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Log In', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Color(0xFF2B7ABB),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}