import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // 👈 added
import 'dart:convert';

// Custom AppBar and Drawer widgets
import 'package:mental_health_flutter/widgets/appbar.dart';
import 'package:mental_health_flutter/widgets/drawer.dart';
import 'package:mental_health_flutter/models/User.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List users = [];
  List therapists = [];
  List appointments = [];
  List payments = [];
  List reports = [];

  bool isLoading = true;

  int newReportsCount = 0;
  List lastSeenReports = [];

  final String baseUrl = 'http://10.55.57.66:8000/api/admin';

  String token = ''; // 👈 token is empty initially

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(handleTabChange);
    loadTokenAndFetchData(); // 👈 Load token first
    startPollingReports();
  }

  void handleTabChange() {
    if (_tabController.index == 4) {
      setState(() {
        newReportsCount = 0;
        lastSeenReports = List.from(reports);
      });
    }
  }

  void startPollingReports() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 10));
      await fetchReports();
      return mounted;
    });
  }

  Future<void> loadTokenAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');

    if (storedToken == null || storedToken.isEmpty) {
      return;
    }

    setState(() {
      token = storedToken;
    });

    await fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);

    try {
      await Future.wait([
        fetchUsers(),
        fetchTherapists(),
        fetchAppointments(),
        fetchPayments(),
        fetchReports(),
      ]);
    } catch (e) {
      // Handle error
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<http.Response> authenticatedGet(String endpoint) {
    return http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<void> fetchUsers() async {
    final res = await authenticatedGet('/users');

    if (res.statusCode == 200) {
      setState(() {
        users = jsonDecode(res.body);
      });
    }
  }

  Future<void> fetchTherapists() async {
    final res = await authenticatedGet('/therapists');

    if (res.statusCode == 200) {
      setState(() {
        therapists = jsonDecode(res.body);
      });
    }
  }

  Future<void> fetchAppointments() async {
    final res = await authenticatedGet('/appointments');

    if (res.statusCode == 200) {
      setState(() {
        appointments = jsonDecode(res.body);
      });
    }
  }

  Future<void> fetchPayments() async {
    final res = await authenticatedGet('/payments');

    if (res.statusCode == 200) {
      setState(() {
        payments = jsonDecode(res.body);
      });
    }
  }

  Future<void> fetchReports() async {
    final res = await authenticatedGet('/reports');

    if (res.statusCode == 200) {
      List newFetchedReports = jsonDecode(res.body);

      if (_tabController.index != 4) {
        int newCount = newFetchedReports.length - lastSeenReports.length;
        if (newCount > 0) {
          setState(() {
            newReportsCount = newCount;
          });
        }
      }

      setState(() {
        reports = newFetchedReports;
      });
    }
  }

  Widget buildList(List data, String label) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data.isEmpty) {
      return const Center(child: Text("No data available"));
    }

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(item['name'] ?? 'N/A'),
            subtitle: Text(jsonEncode(item)),
          ),
        );
      },
    );
  }

  Widget buildReportsList(List data) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data.isEmpty) {
      return const Center(child: Text("No reports available"));
    }

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final report = data[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text('Reported Message ID: ${report['message_id']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reason: ${report['reason']}'),
                const SizedBox(height: 4),
                Text(
                  'Reported by: ${report['user']['name'] ?? 'Unknown'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget reportsTabTitle() {
    if (newReportsCount == 0) {
      return const Text('Reports');
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Reports'),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 240, 93, 83),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$newReportsCount',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: fetchUserWithToken(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (userSnapshot.hasError) {
          return Scaffold(body: Center(child: Text('Failed to load user: ${userSnapshot.error}')));
        } else if (userSnapshot.hasData) {
          final user = userSnapshot.data!;
          return Scaffold(
            appBar: CustomAppBar(
              isAuthenticated: true,
              isAdmin: true,
              userName: user.name,
              profilePhoto: user.profilePhoto ?? '',
              backendUrl: baseUrl,
            ),
            drawer: CustomDrawer(
              isAuthenticated: true,
              isAdmin: true,
              userName: user.name,
              profilePhoto: user.profilePhoto ?? '',
              backendUrl: baseUrl,
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                buildList(users, 'User'),
                buildList(therapists, 'Therapist'),
                buildList(appointments, 'Appointment'),
                buildList(payments, 'Payment'),
                buildReportsList(reports),
              ],
            ),
          );
        } else {
          return const Scaffold(body: Center(child: Text('Failed to load user')));
        }
      },
    );
  }

  Future<User> fetchUserWithToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token not found');
    final url = Uri.parse('$baseUrl/api/user');
    final response = await http.get(url, headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body)['user']);
    } else {
      throw Exception('Failed to fetch user');
    }
  }
}