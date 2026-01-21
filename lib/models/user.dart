class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String apiToken;

  User({
    required this.id, 
    required this.name, 
    required this.email, 
    required this.role,
    required this.apiToken
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      apiToken: json['api_token'] ?? json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'api_token': apiToken,
    };
  }
}
