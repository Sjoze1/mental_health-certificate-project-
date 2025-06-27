class Community {
  final int id;
  final String name;
  final String profilePhoto;
  final String bannerImage;

  const Community({
    required this.id,
    required this.name,
    required this.profilePhoto,
    required this.bannerImage,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'] as int, // Explicit cast to int
      name: json['name'] as String, // Explicit cast to String
      profilePhoto: json['profile_photo'] as String, // Explicit cast to String
      bannerImage: json['banner_image'] as String, // Explicit cast to String
    );
  }
}
