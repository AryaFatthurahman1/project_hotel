class User {
  final String id;
  final String fullName;
  final String email;
  final String password; // In a real app, never store plain text password!
  final String? phone;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'password': password,
      'phone': phone,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      phone: map['phone'],
    );
  }
}

