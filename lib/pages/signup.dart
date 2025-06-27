// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  File? profilePhoto;

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool showPassword = false;
  bool showConfirmPassword = false;
  bool isLoading = false;
  String? errorMessage;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickPhoto(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        profilePhoto = File(picked.path);
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final uri = Uri.parse('http://10.55.57.66:8000/api/register');

    final request = http.MultipartRequest('POST', uri)
      ..fields['name'] = name
      ..fields['email'] = email
      ..fields['password'] = password
      ..fields['password_confirmation'] = confirmPassword;

    if (profilePhoto != null) {
      request.files.add(await http.MultipartFile.fromPath('profile_picture', profilePhoto!.path));
    }

    try {
      final response = await request.send();
      final resBody = await response.stream.bytesToString();
      final resJson = jsonDecode(resBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', resJson['token']); // Assuming signup also returns a token

        // Save user name
        await prefs.setString('name', resJson['user']['name']); // Assuming signup returns user data

        // Save profile picture if it exists in the signup response
        if (resJson['user'] != null && resJson['user'].containsKey('profile_picture')) {
          await prefs.setString('profile_picture', resJson['user']['profile_picture']);
        }

        // Save therapist_id if present in the signup response
        if (resJson.containsKey('therapist_id')) {
          await prefs.setInt('therapist_id', resJson['therapist_id']);
        } else {
          // Handle case where therapist ID is not in response
        }

        Navigator.pushReplacementNamed(context, '/');
      } else {
        setState(() {
          errorMessage = resJson['message'] ?? 'Registration failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Something went wrong. Please check your connection.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildTextField({
    required String label,
    required IconData icon,
    required bool obscure,
    required void Function(String?) onSaved,
    required String? Function(String?) validator,
    bool isPasswordToggle = false,
    VoidCallback? onToggle,
    String? toggleIcon,
    TextEditingController? controller,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: isPasswordToggle
            ? IconButton(
                icon: Icon(toggleIcon == 'show' ? Icons.visibility : Icons.visibility_off),
                onPressed: onToggle,
              )
            : null,
        border: const OutlineInputBorder(),
      ),
      onSaved: onSaved,
      validator: validator,
    );
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        automaticallyImplyLeading: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 6, 128, 209), Color.fromARGB(255, 119, 212, 231)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          'Join Mind Haven',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 12, 80, 140),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create your account to get started',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        const SizedBox(height: 24),
                        if (errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(child: Text(errorMessage!)),
                              ],
                            ),
                          ),
                        buildTextField(
                          label: 'Full Name',
                          icon: Icons.person,
                          obscure: false,
                          onSaved: (v) => name = v!.trim(),
                          validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 12),
                        buildTextField(
                          label: 'Email',
                          icon: Icons.email,
                          obscure: false,
                          onSaved: (v) => email = v!.trim(),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Email is required';
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        buildTextField(
                          label: 'Password',
                          icon: Icons.lock,
                          obscure: !showPassword,
                          controller: passwordController,
                          onSaved: (v) => password = v!,
                          validator: (v) => v == null || v.length < 8
                              ? 'Password must be at least 8 characters'
                              : null,
                          isPasswordToggle: true,
                          onToggle: () => setState(() => showPassword = !showPassword),
                          toggleIcon: showPassword ? 'show' : 'hide',
                        ),
                        const SizedBox(height: 12),
                        buildTextField(
                          label: 'Confirm Password',
                          icon: Icons.lock_outline,
                          obscure: !showConfirmPassword,
                          controller: confirmPasswordController,
                          onSaved: (v) => confirmPassword = v!,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Confirm your password';
                            if (v != passwordController.text) return 'Passwords must match';
                            return null;
                          },
                          isPasswordToggle: true,
                          onToggle: () => setState(() => showConfirmPassword = !showConfirmPassword),
                          toggleIcon: showConfirmPassword ? 'show' : 'hide',
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => _pickPhoto(ImageSource.gallery),
                          icon: const Icon(Icons.camera_alt),
                          label: Text(profilePhoto == null ? 'Upload Profile Picture' : 'Photo Selected'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 12, 80, 140),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            backgroundColor: const Color.fromARGB(255, 12, 80, 140),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Sign Up', style: TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                          child: const Text(
                            'Already have an account? Log In',
                            style: TextStyle(color: Color.fromARGB(255, 12, 80, 140), fontWeight: FontWeight.w600),
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