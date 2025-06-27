import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  String? selectedTherapist;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  List<Map<String, dynamic>> therapists = [];

  bool isLoading = false;

  final String baseUrl = 'http://10.55.57.66:8000/api';

  @override
  void initState() {
    super.initState();
    fetchTherapists();

    _phoneController.addListener(() => setState(() {}));
    _reasonController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  // AUTH + FETCH METHODS

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchTherapists() async {
    setState(() => isLoading = true);
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/therapists'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          therapists = data.map((t) => {
                'id': t['id'].toString(),
                'name': t['name'],
              }).toList();
        });
      } else {
        showError('Failed to load therapists');
      }
    } catch (e) {
      showError('Network error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // SEND MESSAGE TO THERAPIST

  Future<void> bookAppointment() async {
    if (selectedTherapist == null ||
        _phoneController.text.isEmpty ||
        _reasonController.text.isEmpty) {
      showError('Please fill in all fields');
      return;
    }

    await sendMessageToTherapist();
  }

  Future<void> sendMessageToTherapist() async {
    setState(() => isLoading = true);

    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/appointments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: json.encode({
          'therapist_id': selectedTherapist,
          'payment_method': 'Direct',
          'phone': _phoneController.text,
          'reason': _reasonController.text,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Appointment sent!')),
        );
        setState(() {
          selectedTherapist = null;
          _phoneController.clear();
          _reasonController.clear();
        });
      } else {
        String errorMessage = 'Failed to send message';
        try {
          final decoded = json.decode(response.body);
          if (decoded is Map<String, dynamic> && decoded['message'] != null) {
            errorMessage = decoded['message'];
          }
        } catch (_) {
          // fallback if decoding fails
          errorMessage = response.body;
        }

        showError(errorMessage);
      }
    } catch (e) {
      showError('Network error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // UI

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Message to Therapist'),
        backgroundColor: const Color.fromARGB(255, 71, 119, 154),
      ),
      backgroundColor: const Color.fromARGB(255, 164, 195, 221),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 12, offset: Offset(0, 4)),
            ],
          ),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        'Contact a Therapist',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 71, 119, 154),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Choose a therapist and provide your contact and message.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 20),

                      // Therapist Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedTherapist,
                        decoration: const InputDecoration(
                          labelText: 'Select a Therapist',
                          filled: true,
                          fillColor: Color(0xFFE3F2FD),
                          border: OutlineInputBorder(),
                        ),
                        items: therapists.map((therapist) {
                          return DropdownMenuItem<String>(
                            value: therapist['id'],
                            child: Text(therapist['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTherapist = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Phone Number Input
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          filled: true,
                          fillColor: Color(0xFFE3F2FD),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Reason for Booking Input
                      TextFormField(
                        controller: _reasonController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Your Message / Reason for Contact',
                          alignLabelWithHint: true,
                          filled: true,
                          fillColor: Color(0xFFE3F2FD),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Send Button
                      ElevatedButton(
                        onPressed: (selectedTherapist != null &&
                                _phoneController.text.isNotEmpty &&
                                _reasonController.text.isNotEmpty)
                            ? bookAppointment
                            : null,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: const Color(0xFF1E3A8A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Send Message',
                            style: TextStyle(fontSize: 16)),
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}