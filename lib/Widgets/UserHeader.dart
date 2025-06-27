import 'package:flutter/material.dart';

class UserHeader extends StatelessWidget {
  final String userName;
  final String? profilePhoto;
  final String backendUrl;

  const UserHeader({
    Key? key,
    required this.userName,
    this.profilePhoto,
    required this.backendUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = (profilePhoto != null && profilePhoto!.isNotEmpty)
        ? (profilePhoto!.startsWith('users/')
            ? '$backendUrl/storage/$profilePhoto'
            : '$backendUrl/storage/users/$profilePhoto')
        : null;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey[300],
            backgroundImage:
                imageUrl != null ? NetworkImage(imageUrl) : null,
            child: imageUrl == null
                ? const Icon(Icons.account_circle, size: 56)
                : null,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back,',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
