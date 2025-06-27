class Therapist {
  final String id;
  final String name;
  final String avatarUrl;

  Therapist({required this.id, required this.name, required this.avatarUrl});

  factory Therapist.fromJson(Map<String, dynamic> json) {
    return Therapist(
      id: json['id'].toString(), // Convert 'id' to a string if it's an integer
      name: json['name'],
      avatarUrl: json['avatar_url'] ?? 'default_avatar_url',
    );
  }
}
