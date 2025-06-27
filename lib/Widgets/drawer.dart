import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final bool isAuthenticated;
  final bool isAdmin;
  final String userName;
  final String profilePhoto;
  final String backendUrl;

  const CustomDrawer({
    super.key,
    required this.isAuthenticated,
    required this.isAdmin,
    required this.userName,
    required this.profilePhoto,
    required this.backendUrl,
  });

  @override
  Widget build(BuildContext context) {
    print('CustomDrawer - profilePhoto: $profilePhoto');
    print('CustomDrawer - backendUrl: $backendUrl');

    final fullImageUrl = profilePhoto.startsWith('users/')
        ? '$backendUrl/storage/$profilePhoto'
        : '$backendUrl/storage/users/$profilePhoto';

    final allPaths = [
      {'icon': Icons.home, 'text': 'Home', 'route': '/', 'public': true},
      {'icon': Icons.lock, 'text': 'Login', 'route': '/login', 'showWhenLoggedOut': true},
      {'icon': Icons.self_improvement, 'text': 'Meditation', 'route': '/meditation', 'requiresAuth': true},
      {'icon': Icons.info, 'text': 'Services', 'route': '/services', 'requiresAuth': true},
      {'icon': Icons.calendar_today, 'text': 'Book Appointment', 'route': '/appointment', 'requiresAuth': true},
      {'icon': Icons.history, 'text': 'My Appointments', 'route': '/userappointment', 'requiresAuth': true},
      {'icon': Icons.group, 'text': 'Community', 'route': '/community', 'requiresAuth': true},
      {'icon': Icons.schedule, 'text': 'Timetable', 'route': '/timetable', 'requiresAuth': true},
      {'icon': Icons.person_add, 'text': 'Sign Up', 'route': '/signup', 'showWhenLoggedOut': true},
      {'icon': Icons.admin_panel_settings, 'text': 'Admin Dashboard', 'route': '/admin', 'requiresAuth': true},
    ];

    final filteredPaths = allPaths.where((path) {
      if (path['public'] == true) return true;
      if (path['showWhenLoggedOut'] == true && !isAuthenticated) return true;
      if (path['requiresAuth'] == true && isAuthenticated) {
        if (path['requiresAdmin'] == true) return isAdmin;
        return true;
      }
      return false;
    }).toList();

    return Drawer(
      child: Container(
        color: const Color.fromARGB(255, 15, 81, 125),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 15, 81, 125),
              ),
              accountName: Text(userName),
              accountEmail: null,
              currentAccountPicture: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[300],
                foregroundImage: profilePhoto.isNotEmpty
                    ? NetworkImage(fullImageUrl)
                    : null,
                child: profilePhoto.isNotEmpty
                    ? null
                    : const Icon(Icons.account_circle, size: 60),
              ),
            ),
            ...filteredPaths.map((path) {
              return ListTile(
                leading: Icon(path['icon'] as IconData?, color: Colors.white),
                title: Text(path['text'] as String, style: const TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pushNamed(context, path['route'] as String);
                },
              );
            }),
            if (isAuthenticated)
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text('Logout', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
          ],
        ),
      ),
    );
  }
}
