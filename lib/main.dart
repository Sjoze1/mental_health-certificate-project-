import 'package:flutter/material.dart';
import 'package:mental_health_flutter/pages/Meditation.dart';
import 'package:mental_health_flutter/pages/appointment.dart' as appointment; // Import with alias
import 'package:mental_health_flutter/pages/myhomepage.dart';
import 'package:mental_health_flutter/pages/login.dart';
import 'package:mental_health_flutter/pages/community.dart';
import 'package:mental_health_flutter/pages/services.dart';
import 'package:mental_health_flutter/pages/signup.dart';
import 'package:mental_health_flutter/pages/timetable.dart';
import 'package:mental_health_flutter/pages/AdminDashboard.dart';
import 'package:mental_health_flutter/pages/UserAppointment.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mental Wellness App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(
              title: 'Mental Wellness App',
              isAuthenticated: false, // Provide initial value
              isAdmin: false,       // Provide initial value
            ),
        '/login': (context) => const LoginPage(),
        '/appointment': (context) => const appointment.AppointmentPage(), //  Simple route definition
        '/community': (context) => CommunityChatPage(),
        '/signup': (context) => const SignupPage(),
        '/meditation': (context) => const MeditationPage(),
        '/timetable': (context) => const TherapistAppointmentsPage(),
        '/admin': (context) => const AdminDashboardPage(),
        '/userappointment': (context) => const UserAppointmentPage(),
        '/drawer/community': (context) => CommunityChatPage(),
        '/drawer/appointment': (context) => const appointment.AppointmentPage(), // Simple route
        '/services': (context) => const ServicesPage(),
      },
    );
  }
}
