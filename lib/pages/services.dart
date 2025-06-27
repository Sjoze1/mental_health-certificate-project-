import 'package:flutter/material.dart';
import 'package:mental_health_flutter/Widgets/appbar.dart';
import 'package:mental_health_flutter/Widgets/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  bool isAuthenticated = false;
  bool isAdmin = false;
  String userName = '';
  String profilePhoto = '';
  String backgroundImage = '';
  String? authToken;

  static const String backendUrl = 'http://10.55.57.66:8000';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('token');

    if (authToken == null) {
      _resetUserData();
      return;
    }

    final url = Uri.parse('$backendUrl/api/user');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $authToken', 'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        setState(() {
          userName = userData['name'] ?? '';
          profilePhoto = userData['profile_picture'] ?? '';
          backgroundImage = userData['background_image'] ?? '';
          isAuthenticated = true;
          isAdmin = userData['is_admin'] ?? false;
        });
      } else {
        _resetUserData();
      }
    } catch (e) {
      _resetUserData();
    }
  }

  void _resetUserData() {
    setState(() {
      isAuthenticated = false;
      isAdmin = false;
      userName = '';
      profilePhoto = '';
      backgroundImage = '';
    });
  }

  Widget _buildBackgroundImage({required double height}) {
    return Stack(
      children: [
        Image.network(
          backgroundImage.isNotEmpty
              ? backgroundImage
              : 'https://i.pinimg.com/736x/cc/6c/43/cc6c43f49d1841ccb64121d73e0a302a.jpg',
          fit: BoxFit.cover,
          height: height,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return SizedBox(
              height: height,
              width: double.infinity,
              child: const Center(child: Text('Failed to load image')),
            );
          },
        ),
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Get help today! Connect with a therapist now.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget get _cardContent {
    const Color primaryBlue = Color(0xFF1976D2);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 30, color: primaryBlue),
            SizedBox(width: 10),
            Text(
              'Book an Appointment',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        const Text(
          'Ready to improve your mental wellness?\nBook a session with a therapist today!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/appointment');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
          child: const Text('Book Now'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color lightBlueBg = Color(0xFFE3F2FD);

    return Scaffold(
      appBar: CustomAppBar(
        isAuthenticated: isAuthenticated,
        isAdmin: isAdmin,
        userName: userName,
        profilePhoto: profilePhoto,
        backendUrl: backendUrl,
      ),
      drawer: CustomDrawer(
        isAuthenticated: isAuthenticated,
        isAdmin: isAdmin,
        userName: userName,
        profilePhoto: profilePhoto,
        backendUrl: backendUrl,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          return isMobile
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildBackgroundImage(height: 350),
                      Container(
                        color: const Color.fromARGB(255, 189, 205, 220),
                        padding: const EdgeInsets.all(24),
                        child: _buildCardWrapper(isMobile: true),
                      ),
                    ],
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildBackgroundImage(height: double.infinity),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: lightBlueBg,
                        padding: const EdgeInsets.all(48),
                        child: _buildCardWrapper(isMobile: false),
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }

  Widget _buildCardWrapper({required bool isMobile}) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/appointment'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isMobile ? double.infinity : 350,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _cardContent,
      ),
    );
  }
}