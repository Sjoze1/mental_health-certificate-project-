import 'package:flutter/material.dart';
import 'package:mental_health_flutter/models/user.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController messageController;
  final String newMessageText;
  final User? currentUser; // You might need this for context
  final Future<void> Function(User) onSendMessage;
  final Function(String) onTextChanged;

  const MessageInput({
    super.key,
    required this.messageController,
    required this.newMessageText,
    required this.currentUser,
    required this.onSendMessage,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              onChanged: onTextChanged,
              decoration: const InputDecoration(
                labelText: 'Type your message...',
              ),
              onSubmitted: (value) => currentUser != null ? onSendMessage(currentUser!) : null,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: newMessageText.isNotEmpty && currentUser != null ? () => onSendMessage(currentUser!) : null,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}