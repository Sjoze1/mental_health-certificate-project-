import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mental_health_flutter/models/message.dart';
import 'package:mental_health_flutter/models/user.dart';
import 'package:mental_health_flutter/widgets/communityWidgets/comment_section.dart';

class MessageList extends StatefulWidget {
  final List<Message> initialMessages;
  final User? currentUser;
  final String backendUrl;
  final Future<void> Function(Message) onUpvote;
  final Future<void> Function(int) onDelete;
  final Future<void> Function(int, String) onReport;

  const MessageList({
    super.key,
    required this.initialMessages,
    required this.currentUser,
    required this.backendUrl,
    required this.onUpvote,
    required this.onDelete,
    required this.onReport,
  });

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  late List<Message> _messages;
  final Map<int, bool> _showCommentField = {}; // messageId -> isShown

  @override
  void initState() {
    super.initState();
    _messages = List.from(widget.initialMessages);
  }

  @override
  void didUpdateWidget(covariant MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialMessages != widget.initialMessages) {
      setState(() {
        _messages = List.from(widget.initialMessages);
      });
    }
  }

  Future<void> _handleUpvote(Message message) async {
    setState(() {
      if (message.isUpvoted) {
        message.upvotes--;
        message.isUpvoted = false;
      } else {
        message.upvotes++;
        message.isUpvoted = true;
      }
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        _messages[index] = message.copyWith(
          upvotes: message.upvotes,
          isUpvoted: message.isUpvoted,
        );
      }
    });
    await widget.onUpvote(message);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          _showCommentField.putIfAbsent(message.id, () => false);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey[300],
                        foregroundImage: (message.userProfilePhoto?.isNotEmpty ?? false)
                            ? NetworkImage('${widget.backendUrl}/storage/${message.userProfilePhoto}')
                            : null,
                        child: (message.userProfilePhoto == null || message.userProfilePhoto!.isEmpty)
                            ? const Icon(Icons.person, size: 20)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          message.userName ?? 'Unknown Sender',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message.text,
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _handleUpvote(message),
                        icon: Icon(
                          message.isUpvoted ? Icons.thumb_up : Icons.thumb_up_outlined,
                          color: message.isUpvoted ? const Color.fromARGB(255, 18, 97, 162) : Colors.grey,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showCommentField[message.id] = !_showCommentField[message.id]!;
                          });
                        },
                        icon: const Icon(Icons.comment_outlined),
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: '${widget.backendUrl}/messages/${message.id}'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Link copied to clipboard!')),
                          );
                        },
                        icon: const Icon(Icons.link_outlined),
                      ),
                      if (message.userId == widget.currentUser?.id)
                        IconButton(
                          onPressed: () async {
                            await widget.onDelete(message.id);
                            setState(() {
                              _messages.removeWhere((m) => m.id == message.id);
                            });
                          },
                          icon: const Icon(Icons.delete, color: Color.fromARGB(255, 244, 164, 158)),
                        ),
                      IconButton(
                        onPressed: () async {
                          final reason = await showDialog<String>(
                            context: context,
                            builder: (context) {
                              String reason = '';
                              return AlertDialog(
                                title: const Text('Report Message'),
                                content: TextField(
                                  onChanged: (value) {
                                    reason = value;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Reason',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(reason);
                                    },
                                    child: const Text('Submit'),
                                  ),
                                ],
                              );
                            },
                          );
                          if (reason != null && reason.isNotEmpty) {
                            await widget.onReport(message.id, reason);
                          }
                        },
                        icon: const Icon(Icons.report_outlined),
                      ),
                    ],
                  ),
                  if (_showCommentField[message.id]!)
                    CommentSection(
                      messageId: message.id,
                      backendUrl: widget.backendUrl,
                      currentUser: widget.currentUser,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}