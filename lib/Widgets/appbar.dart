import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isAuthenticated;
  final bool isAdmin;
  final String? profilePhoto;
  final String userName;
  final bool showBackButton;
  final String backendUrl;

  const CustomAppBar({
    super.key,
    this.title = '',
    this.isAuthenticated = false,
    this.isAdmin = false,
    this.profilePhoto,
    this.userName = '',
    this.showBackButton = false,
    required this.backendUrl,
  });

  @override
  Widget build(BuildContext context) {
    final fullImageUrl = profilePhoto != null && profilePhoto!.isNotEmpty
        ? (profilePhoto!.startsWith('users/')
            ? '$backendUrl/storage/$profilePhoto'
            : '$backendUrl/storage/users/$profilePhoto')
        : null;

    return AppBar(
      backgroundColor: const Color.fromARGB(255, 71, 119, 154),
      centerTitle: true,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            )
          : Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
      title: isAuthenticated
          ? Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(title),
              ],
            )
          : Text(
              'Mind Haven',
              style: GoogleFonts.dancingScript(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
      actions: isAuthenticated
          ? [
              IconButton(
                icon: const Icon(Icons.notifications),
                color: Colors.white,
                onPressed: () {
                  // Handle notifications
                },
              ),
              IconButton(
                icon: const Icon(Icons.schedule),
                color: Colors.white,
                onPressed: () {
                  Navigator.pushNamed(context, '/userappointments');
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      fullImageUrl != null ? NetworkImage(fullImageUrl) : null,
                  child: fullImageUrl == null
                      ? const Icon(Icons.account_circle, size: 36)
                      : null,
                ),
              ),
            ]
          : showBackButton
              ? null
              : [
                  IconButton(
                    icon: const Icon(Icons.checklist),
                    color: Colors.white,
                    onPressed: () {
                      // Handle checklist
                    },
                  ),
                ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
