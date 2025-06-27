import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mental_health_flutter/Widgets/appbar.dart';
import 'package:mental_health_flutter/Widgets/drawer.dart';
import 'package:mental_health_flutter/models/user.dart'; // Assuming you have a User model

class MeditationPage extends StatefulWidget {
  const MeditationPage({super.key});

  @override
  _MeditationPageState createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _currentlyPlayingIndex;
  bool _isPaused = false;
  bool isLoading = true;
  bool songsLoading = true;

  final bool isAuthenticated = true;
  final bool isAdmin = false;
  final bool isTherapist = true;
  String userName = "";
  String profilePhoto = "";

  List<Map<String, String>> songs = [];
  late Future<User> userFuture;
  final String backendUrl = 'http://10.55.57.66:8000';

  @override
  void initState() {
    super.initState();
    fetchSongs();
    userFuture = fetchUserWithToken();
  }

  Future<User> fetchUserWithToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception('Token not found');
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
          return User.fromJson(userData);
        } catch (e) {
          return User(id: -1, name: '', profilePhoto: null);
        }
      } else {
        return User(id: -1, name: '', profilePhoto: null);
      }
    } catch (e) {
      return User(id: -1, name: '', profilePhoto: null);
    }
  }

  Future<void> fetchSongs() async {
    final Uri url = Uri.parse('$backendUrl/api/meditation-tracks');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          songs = data.map<Map<String, String>>((track) => {
            'title': (track['title'] ?? '').toString(),
            'artist': (track['artist'] ?? '').toString(),
            'url': (track['url'] ?? '').toString(),
          }).toList();
          songsLoading = false;
        });
      } else {
        setState(() {
          songsLoading = false;
        });
        throw Exception('Failed to load meditation tracks - Status Code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        songsLoading = false;
      });
      throw Exception('Failed to load meditation tracks - Exception: $e');
    }
  }

  void playSong(int index) async {
    if (_currentlyPlayingIndex == index && _isPaused) {
      await _audioPlayer.resume();
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(songs[index]['url']!));
    }

    setState(() {
      _currentlyPlayingIndex = index;
      _isPaused = false;
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _currentlyPlayingIndex = null;
        _isPaused = false;
      });
    });
  }

  void togglePlayPause(int index) async {
    if (_currentlyPlayingIndex == index) {
      if (_isPaused) {
        await _audioPlayer.resume();
      } else {
        await _audioPlayer.pause();
      }
      setState(() {
        _isPaused = !_isPaused;
      });
    } else {
      playSong(index);
    }
  }

  bool isPlaying(int index) => _currentlyPlayingIndex == index && !_isPaused;

  DataRow buildSongRow(int index) {
    final song = songs[index];
    final bool playing = isPlaying(index);

    return DataRow(
      cells: [
        DataCell(Text(
          (index + 1).toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        )),
        DataCell(Text(
          song['title']!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        )),
        DataCell(Text(song['artist']!)),
        DataCell(
          IconButton(
            icon: Icon(
              playing ? Icons.pause_circle : Icons.play_circle,
              color: playing ? Colors.orange : Colors.green,
            ),
            onPressed: () => togglePlayPause(index),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF003366), Color(0xFF90CAF9)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Meditation Playlist',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Calm your mind and soul with these soothing tunes.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 32),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: songsLoading
                          ? const CircularProgressIndicator()
                          : songs.isEmpty
                              ? const Text('No meditation tracks available.')
                              : DataTable(
                                  columnSpacing: 16,
                                  columns: const [
                                    DataColumn(
                                      label: Text(
                                        '',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Title',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Artist',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataColumn(label: Text('Actions')),
                                  ],
                                  rows: List.generate(songs.length, buildSongRow),
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}