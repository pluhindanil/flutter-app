class Users {
  final String email;
  final String username;
  final String image; // Add this field

  Users({
    required this.email,
    required this.username,
    required this.image, // Initialize it in the constructor
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'image': image, // Include avatarUrl in the JSON data
    };
  }
}
