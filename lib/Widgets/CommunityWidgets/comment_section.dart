import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mental_health_flutter/models/comment.dart';
import 'package:mental_health_flutter/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommentSection extends StatefulWidget {
  final int messageId;
  final String backendUrl;
  final User? currentUser;

  const CommentSection({
    super.key,
    required this.messageId,
    required this.backendUrl,
    required this.currentUser,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _controller = TextEditingController();
  List<Comment> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return;
    }

    final url = Uri.parse('${widget.backendUrl}/api/messages/${widget.messageId}/comments');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _comments = List<Comment>.from(data.map((json) => Comment.fromJson(json)));
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _submitComment(String text) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    final url = Uri.parse('${widget.backendUrl}/api/messages/${widget.messageId}/comments');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'text': text,
          'user_id': widget.currentUser?.id,
          'message_id': widget.messageId,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _controller.clear();
        _fetchComments();
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _upvoteComment(Comment comment) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    final url = Uri.parse('${widget.backendUrl}/api/comments/${comment.id}/upvote');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          comment.isUpvoted = !comment.isUpvoted;
          comment.upvotes += comment.isUpvoted ? 1 : -1;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Widget _buildCommentTile(Comment comment) {
    final photoPath = comment.userProfilePhoto;
    final imageUrl = (photoPath != null && photoPath.isNotEmpty)
        ? '${widget.backendUrl}/storage/$photoPath'
        : null;

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
        child: imageUrl == null ? const Icon(Icons.person) : null,
      ),
      title: Text(comment.userName ?? 'Unknown'),
      subtitle: Text(comment.text),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _upvoteComment(comment),
            icon: Icon(
              comment.isUpvoted ? Icons.thumb_up : Icons.thumb_up_outlined,
              color: comment.isUpvoted ? Colors.blue : Colors.grey,
            ),
          ),
          const SizedBox(width: 4),
          Text(comment.upvotes.toString()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_comments.isEmpty)
          const Text('No comments yet.')
        else
          ListView.builder(
            shrinkWrap: true,
            itemCount: _comments.length,
            itemBuilder: (context, index) {
              final comment = _comments[index];
              return _buildCommentTile(comment);
            },
          ),
        const SizedBox(height: 10),
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Write a comment...',
            border: OutlineInputBorder(),
          ),
          maxLines: null,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () {
              final text = _controller.text.trim();
              if (text.isNotEmpty) {
                _submitComment(text);
              }
            },
            child: const Text('Submit'),
          ),
        ),
      ],
    );
  }
}