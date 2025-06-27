import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Widgets
import 'package:mental_health_flutter/widgets/appbar.dart';
import 'package:mental_health_flutter/widgets/drawer.dart';
import 'package:mental_health_flutter/Widgets/CommunityWidgets/communitylist.dart';
import 'package:mental_health_flutter/Widgets/CommunityWidgets/message_input.dart';
import 'package:mental_health_flutter/Widgets/CommunityWidgets/message_list.dart';

// Models
import 'package:mental_health_flutter/models/user.dart';
import 'package:mental_health_flutter/models/community.dart';
import 'package:mental_health_flutter/models/message.dart';

class CommunityChatPage extends StatefulWidget {
  const CommunityChatPage({super.key});

  @override
  State<CommunityChatPage> createState() => _CommunityChatPageState();
}

class _CommunityChatPageState extends State<CommunityChatPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<User> userFuture;
  late Future<List<Community>> communitiesFuture;
  Community? selectedCommunity;
  List<Message> messages = [];
  String newMessageText = '';
  final String backendUrl = 'http://10.55.57.66:8000';
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    userFuture = fetchUserWithToken();
    communitiesFuture = fetchCommunitiesWithToken();
  }

  Future<User> fetchUserWithToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token not found');
    final url = Uri.parse('$backendUrl/api/user');
    final response = await http.get(url, headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body)); // Access nested 'user'
    } else {
      throw Exception('Failed to fetch user');
    }
  }

  Future<List<Community>> fetchCommunitiesWithToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token not found');
    final url = Uri.parse('$backendUrl/api/communities');
    final response = await http.get(url, headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Community.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch communities');
    }
  }

  Future<void> shareMessage(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || selectedCommunity == null || newMessageText.isEmpty) return;
    final url = Uri.parse('$backendUrl/api/communities/${selectedCommunity!.id}/messages');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'text': newMessageText}),
    );
    if (response.statusCode == 201) {
      await fetchMessages(selectedCommunity!.id);
      setState(() {
        newMessageText = '';
        _messageController.clear();
      });
    }
  }

  Future<void> fetchMessages(int communityId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;
    final url = Uri.parse('$backendUrl/api/communities/$communityId/messages');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      try {
        final decodedBody = jsonDecode(response.body);
        List<dynamic> data;
        if (decodedBody is List) {
          data = decodedBody;
        } else if (decodedBody is Map<String, dynamic> && decodedBody.containsKey('data')) {
          data = decodedBody['data'];
        } else {
          throw Exception('Unexpected response format');
        }
        setState(() {
          messages = data.map((json) => Message.fromJson(json)).toList();
        });
      } catch (e) {
        setState(() {
          messages = [];
        });
      }
    } else {
      setState(() {
        messages = [];
      });
    }
  }

  Future<void> upvoteMessage(Message message) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;
    final url = Uri.parse('$backendUrl/api/messages/${message.id}/upvote');
    final response = await http.post(url, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      try {
        final decodedBody = jsonDecode(response.body);
        final updatedUpvotes = decodedBody['upvotes'] as int;
        setState(() {
          message.upvotes = updatedUpvotes;
          final index = messages.indexWhere((msg) => msg.id == message.id);
          if (index != -1) {
            messages[index] = messages[index].copyWith(upvotes: updatedUpvotes);
          }
        });
      } catch (e) {
        // Handle error
      }
    }
  }

  Future<void> deleteMessage(int messageId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;
    final url = Uri.parse('$backendUrl/api/messages/$messageId');
    final response = await http.delete(url, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 204) {
      setState(() {
        messages.removeWhere((msg) => msg.id == messageId);
      });
    }
  }

  Future<void> reportMessage(int messageId, String reason) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || reason.isEmpty) return;
    final url = Uri.parse('$backendUrl/api/reports/messages');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'message_id': messageId, 'reason': reason}),
    );
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message reported successfully!')),
      );
    }
  }

  void selectCommunity(Community community) async {
    setState(() {
      selectedCommunity = community;
      messages.clear();
    });
    await fetchMessages(community.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: userFuture,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (userSnapshot.hasError) {
          return Scaffold(body: Center(child: Text('Failed to load user: ${userSnapshot.error}')));
        } else if (userSnapshot.hasData) {
          final user = userSnapshot.data!;
          return Scaffold(
            key: _scaffoldKey,
            appBar: CustomAppBar(
              isAuthenticated: true,
              isAdmin: false,
              userName: user.name,
              profilePhoto: user.profilePhoto ?? '',
              backendUrl: backendUrl,
            ),
            drawer: CustomDrawer(
              isAuthenticated: true,
              isAdmin: false,
              userName: user.name,
              profilePhoto: user.profilePhoto ?? '', // Use correct parameter name here
              backendUrl: backendUrl,
            ),
            body: Row(
              children: [
                CommunityList(
                  communitiesFuture: communitiesFuture,
                  onCommunitySelected: selectCommunity,
                  selectedCommunity: selectedCommunity,
                  backendUrl: backendUrl,
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Column(
                    children: [
                      if (selectedCommunity != null)
                        Image.network(
                          '$backendUrl/storage/${selectedCommunity!.bannerImage}',
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120,
                              color: Colors.grey[300],
                              child: const Center(child: Text('Failed to load banner')),
                            );
                          },
                        )
                      else
                        Container(
                          height: 60,
                          color: Colors.white,
                          child: const Center(
                            child: Text(
                              'Select a Community',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Expanded( // Wrap MessageList with Expanded
                        child: Container(
                          color: const Color.fromARGB(255, 189, 205, 220),
                          child: selectedCommunity != null
                              ? MessageList(
                                  initialMessages: messages,
                                  currentUser: user,
                                  backendUrl: backendUrl,
                                  onUpvote: upvoteMessage,
                                  onDelete: deleteMessage,
                                  onReport: reportMessage,
                                )
                              : const Center(child: Text('No community selected')),
                        ),
                      ),
                      if (selectedCommunity != null)
                        MessageInput(
                          messageController: _messageController,
                          newMessageText: newMessageText,
                          currentUser: user,
                          onSendMessage: shareMessage,
                          onTextChanged: (text) {
                            setState(() {
                              newMessageText = text;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return const Scaffold(body: Center(child: Text('Failed to load user')));
        }
      },
    );
  }
}