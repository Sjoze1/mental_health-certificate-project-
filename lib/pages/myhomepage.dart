import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mental_health_flutter/Widgets/appbar.dart';
import 'package:mental_health_flutter/Widgets/drawer.dart';
import 'package:mental_health_flutter/Widgets/bottombar.dart';
import 'package:mental_health_flutter/Widgets/UserHeader.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final String title;
  final bool isAuthenticated;
  final bool isAdmin;

  const HomePage({
    super.key,
    required this.title,
    required this.isAuthenticated,
    required this.isAdmin,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? expandedCard;
  String userName = "";
  String profilePhoto = "";
  final String backendUrl = 'http://10.55.57.66:8000';

  final List<Map<String, String>> cards = [
    {
      'title': 'Self-Care Routines',
      'description': 'Calm your mind and soul with these soothing tunes.',
      'detailedText':
          'Discover guided routines that help you stay grounded, reduce stress, and maintain emotional balance throughout your day.',
      'image': './assets/images/Meditation.jpeg',
      'lottieSrc': './assets/Lottie/Meditation-lottie.json',
    },
    {
      'title': 'Expert Advice',
      'description': 'Connect with licensed therapists and coaches.',
      'detailedText':
          'Get professional support from certified experts who understand your journey and can guide you with personalized strategies.',
      'image': 'assets/images/VirtualCare.jpeg',
      'lottieSrc': './assets/Lottie/Therapist-lottie.json',
    },
    {
      'title': 'Community Support',
      'description': 'Join groups that resonate with your experience.',
      'detailedText':
          'Be part of a safe space where you can share, listen, and grow alongside others who truly understand what you’re going through.',
      'image': 'assets/images/HappyCelebration.jpeg',
      'lottieSrc': './assets/Lottie/Guychat-lottie.json',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserWithToken(); // Call the fetch method here
  }

  Future<void> _fetchUserWithToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      return; // Or handle the error as needed
    }
    final url = Uri.parse('$backendUrl/api/user');
    try {
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        try {
          final userData = jsonDecode(response.body);
          setState(() {
            userName = userData['name'] ?? '';
            profilePhoto = userData['profile_picture'] ?? '';
          });
          // You might not need to return a User object here if you're just updating state
        } catch (e) {
          // Handle JSON decoding error
        }
      } else {
        // Handle unsuccessful fetch
      }
    } catch (e) {
      // Handle HTTP request error
    }
  }

  void toggleCard(int index) {
    setState(() {
      expandedCard = expandedCard == index ? null : index;
    });
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _handleNavigation(int index) {
    if (!widget.isAuthenticated) {
      _navigateToLogin();
      return;
    }
    if (index == 2) {
      Navigator.pushNamed(context, '/community');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/services');
    } else if (index == 0) {
      Navigator.pushNamed(context, '/meditation');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        isAuthenticated: widget.isAuthenticated,
        isAdmin: widget.isAdmin,
        userName: userName, // Use the state variable
        profilePhoto: profilePhoto, // Use the state variable
        backendUrl: backendUrl,
      ),
      drawer: CustomDrawer(
        isAuthenticated: widget.isAuthenticated,
        isAdmin: widget.isAdmin,
        userName: userName, // Use the state variable
        profilePhoto: profilePhoto, // Use the state variable
        backendUrl: backendUrl,
      ),
      backgroundColor: const Color.fromARGB(255, 164, 195, 221),
      bottomNavigationBar: BottomBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            UserHeader(
              userName: userName, // Use the state variable
              profilePhoto: profilePhoto, // Use the state variable
              backendUrl: backendUrl,
            ),
            const SizedBox(height: 10),
            CarouselSlider(
              options: CarouselOptions(
                height: 250.0,
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
                viewportFraction: 0.8,
              ),
              items: [
                {'image': 'assets/images/HappyCelebration.jpeg', 'caption': 'Community support enhancing interaction and esteem'},
                {'image': 'assets/images/Meditation.jpeg', 'caption': 'Mindfulness and Meditation for Everyday Life'},
                {'image': 'assets/images/VirtualCare.jpeg', 'caption': 'Virtual Care That Feels Human'},
              ].map((item) {
                return Builder(
                  builder: (BuildContext context) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            item['image']!,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              color: Colors.black.withOpacity(0.5),
                              child: Text(
                                item['caption']!,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Explore more of our services and features designed to support your mental wellness journey!",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            Column(
              children: List.generate(cards.length, (index) {
                final card = cards[index];
                final isExpanded = expandedCard == index;

                return GestureDetector(
                  onTap: () => toggleCard(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    constraints: BoxConstraints(
                      minHeight: 130,
                      maxHeight: isExpanded ? 450 : 200,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: isExpanded
                          ? DecorationImage(
                              image: AssetImage(card['image']!),
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            )
                          : null,
                      color: isExpanded ? Colors.transparent : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Stack(
                      children: [
                        if (!isExpanded)
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
                              child: Transform.scale(
                                scale: 1.4,
                                child: Lottie.asset(
                                  card['lottieSrc']!,
                                  height: 100,
                                ),
                              ),
                            ),
                          ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isExpanded ? Colors.black.withOpacity(0.4) : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                card['title']!,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isExpanded ? Colors.white : Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                card['description']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isExpanded ? Colors.white70 : Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (isExpanded) ...[
                                const SizedBox(height: 16),
                                Text(
                                  card['detailedText']!,
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              const Spacer(),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () => _handleNavigation(index),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                  ),
                                  child: const Text("Get Started"),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Icon(
                                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                color: isExpanded ? Colors.white : Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}