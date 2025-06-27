import 'comment.dart';

class Message {
  final int id;
  final int userId;
  final String text;
  int upvotes;
  bool isUpvoted;
  final List<Comment> comments;
  String? userName;
  String? userProfilePhoto; // Add this field

  Message({
    required this.id,
    required this.userId,
    required this.text,
    required this.upvotes,
    required this.isUpvoted,
    required this.comments,
    this.userName,
    this.userProfilePhoto,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      text: json['text'] as String,
      upvotes: json['upvotes'] ?? 0,
      isUpvoted: json['is_upvoted'] ?? false,
      comments: (json['comments'] as List<dynamic>?)
              ?.map((c) => Comment.fromJson(c as Map<String, dynamic>))
              .toList()
          ?? [],
      userName: json['user_name'] as String?,
      userProfilePhoto: json['user_profile_photo'] as String?, // Add parsing for profile photo
    );
  }

  Message copyWith({
    int? id,
    int? userId,
    String? text,
    int? upvotes,
    bool? isUpvoted,
    List<Comment>? comments,
    String? userName,
    String? userProfilePhoto,
  }) {
    return Message(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      text: text ?? this.text,
      upvotes: upvotes ?? this.upvotes,
      isUpvoted: isUpvoted ?? this.isUpvoted,
      comments: comments ?? this.comments,
      userName: userName ?? this.userName,
      userProfilePhoto: userProfilePhoto ?? this.userProfilePhoto,
    );
  }
}