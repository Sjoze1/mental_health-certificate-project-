import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
          IconButton(
            icon: const Icon(Icons.self_improvement),
            onPressed: () {
              Navigator.pushNamed(context, '/meditation');
            },
          ),
          IconButton(
            icon: const Icon(Icons.health_and_safety),
            onPressed: () {
              Navigator.pushNamed(context, '/services');
            },
          ),
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: () {
              Navigator.pushNamed(context, '/community');
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
