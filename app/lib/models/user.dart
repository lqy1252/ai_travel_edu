class User {
  final int id;
  final String username;
  final String role;
  final String token;

  User({
    required this.id,
    required this.username,
    required this.role,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json, String token) {
    return User(
      id: json['id'],
      username: json['username'],
      role: json['role'],
      token: token,
    );
  }

  bool get isAdmin => role == 'admin';
}
