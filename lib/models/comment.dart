class Comment {
  final int id;
  final String text;
  final int userId;
  final int messageId;
  int upvotes;
  String? userName;
  String? userProfilePhoto;
  bool isUpvoted;

  Comment({
    required this.id,
    required this.text,
    required this.userId,
    required this.messageId,
    required this.upvotes,
    this.userName,
    this.userProfilePhoto,
    this.isUpvoted = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      text: json['text'],
      userId: json['user_id'],
      messageId: json['message_id'],
      upvotes: json['upvotes'] ?? 0,
      userName: json['user_name'] as String?, // Directly from the top level
      userProfilePhoto: json['user_profile_photo'] as String?, // Directly from the top level
    );
  }
}