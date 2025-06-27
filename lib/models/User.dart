class User {
  final int id;
  final String name;
  final String? profilePhoto;

  User({required this.id, required this.name, this.profilePhoto});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      profilePhoto: json['profile_picture'], // Use 'profile_picture' here as well
    );
  }
}