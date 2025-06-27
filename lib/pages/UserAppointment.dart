import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserAppointmentPage extends StatefulWidget {
  const UserAppointmentPage({super.key});

  @override
  State<UserAppointmentPage> createState() => _UserAppointmentPageState();
}

class _UserAppointmentPageState extends State<UserAppointmentPage> {
  List<dynamic> appointments = [];
  bool isLoading = false;

  final String baseUrl = 'http://10.55.57.66:8000/api';

  @override
  void initState() {
    super.initState();
    fetchUserAppointments();
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchUserAppointments() async {
    setState(() => isLoading = true);
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/user/appointments'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          appointments = data;
        });
      } else {
        showError('Failed to load your appointments.');
      }
    } catch (e) {
      showError('Network error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green.shade100;
      case 'cancelled':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Icon getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'cancelled':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.hourglass_empty, color: Colors.grey);
    }
  }

  String? getCustomMessage(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'The appointment you booked for has been approved. The therapist will reach out to you via SMS with a Google Meet link and the scheduled time.';
      case 'cancelled':
        return 'Due to unforeseen circumstances, we are unable to schedule this meeting. Please try again later or choose another therapist.';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: const Color.fromARGB(255, 71, 119, 154),
      ),
      backgroundColor: const Color.fromARGB(255, 237, 245, 250),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : appointments.isEmpty
              ? const Center(child: Text('You have no appointments.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appt = appointments[index];
                    final status = appt['status'] ?? 'pending';

                    return Card(
                      color: getStatusColor(status),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                getStatusIcon(status),
                                const SizedBox(width: 8),
                                Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: status == 'cancelled'
                                        ? const Color.fromARGB(255, 232, 118, 110)
                                        : status == 'approved'
                                            ? Colors.green
                                            : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Therapist: ${appt['therapist_name'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 16),
                                const SizedBox(width: 4),
                                Text(appt['phone'] ?? 'N/A'),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Reason:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(appt['reason'] ?? 'No reason provided'),
                            const SizedBox(height: 12),
                            if (getCustomMessage(status) != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: status == 'approved'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                child: Text(
                                  getCustomMessage(status)!,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
