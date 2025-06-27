import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TherapistAppointmentsPage extends StatefulWidget {
  const TherapistAppointmentsPage({super.key});

  @override
  State<TherapistAppointmentsPage> createState() => _TherapistAppointmentsPageState();
}

class _TherapistAppointmentsPageState extends State<TherapistAppointmentsPage> {
  List<dynamic> appointments = [];
  bool isLoading = false;

  final String baseUrl = 'http://10.55.57.66:8000/api';

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchAppointments() async {
    setState(() => isLoading = true);
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/therapist/appointments'),
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
        showError('Failed to load appointments');
      }
    } catch (e) {
      showError('Network error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _confirmStatusChange(String appointmentId, String status) async {
    final action = status == 'approved' ? 'approve' : 'cancel';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm $action'),
        content: Text('Are you sure you want to $action this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'approved' ? Colors.green : Colors.red,
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      updateAppointmentStatus(appointmentId, status);
    }
  }

  Future<void> deleteAppointment(String appointmentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this appointment?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final token = await getToken();
        final response = await http.delete(
          Uri.parse('$baseUrl/appointments/$appointmentId'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Appointment deleted.'),
            backgroundColor: Colors.red,
          ));
          fetchAppointments(); // Refresh the list after deletion
        } else {
          showError('Failed to delete appointment.');
        }
      } catch (e) {
        showError('Error: $e');
      }
    }
  }

  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      final token = await getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/appointments/$appointmentId/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Appointment $status successfully.'),
            backgroundColor: status == 'approved' ? Colors.green : Colors.red,
          ));
        }
        fetchAppointments(); // Refresh list
      } else {
        if (context.mounted) {
          showError('Failed to update status: ${response.body}');
        }
      }
    } catch (e) {
      if (context.mounted) {
        showError('Error: $e');
      }
    }
  }

  void showError(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _showApprovedAppointments() {
    final approved = appointments.where((a) => a['status'] == 'approved').toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: approved.isEmpty
            ? const Center(child: Text('No approved appointments.'))
            : ListView.builder(
                itemCount: approved.length,
                itemBuilder: (context, index) {
                  final appt = approved[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(appt['user_name'] ?? 'Unknown'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Phone: ${appt['phone'] ?? 'N/A'}'),
                          Text('Reason: ${appt['reason'] ?? 'None'}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteAppointment(appt['id'].toString()),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Bookings'),
        backgroundColor: const Color.fromARGB(255, 71, 119, 154),
        actions: [
          IconButton(
            icon: const Icon(Icons.checklist_outlined),
            tooltip: 'View Approved',
            onPressed: _showApprovedAppointments,
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 237, 245, 250),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : appointments.isEmpty
              ? const Center(child: Text('No bookings yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final booking = appointments[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking['user_name'] ?? 'Unknown User',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 14, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text(booking['phone'] ?? 'N/A', style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Reason:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              booking['reason'] ?? 'No reason provided.',
                              style: const TextStyle(color: Colors.black87, fontSize: 14),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () => _confirmStatusChange(booking['id'].toString(), 'cancelled'),
                                  icon: const Icon(Icons.cancel, color: Colors.red, size: 18),
                                  label: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.red, fontSize: 14),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _confirmStatusChange(booking['id'].toString(), 'approved'),
                                  icon: const Icon(Icons.check_circle, size: 18),
                                  label: const Text(
                                    'Approve',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                              ],
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