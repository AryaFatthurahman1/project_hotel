class User {
  int id;
  String? nim;
  String name;
  String email;
  String? role;
  int? roleId;
  String? apiToken;
  String? fotoProfil;
  String? phone;
  String? alamat;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.nim,
    this.role,
    this.roleId,
    this.apiToken,
    this.fotoProfil,
    this.phone,
    this.alamat,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: (json['name'] ?? json['nama_lengkap'] ?? json['nama']) ?? '',
      email: (json['email'] ?? '') as String,
      nim: json['nim']?.toString(),
      role: json['role'] ?? json['role_name'],
      roleId: json['role_id'] is int ? json['role_id'] : (json['role_id'] != null ? int.tryParse(json['role_id'].toString()) : null),
      apiToken: json['api_token'] ?? json['token'],
      fotoProfil: json['foto_profil'] ?? json['foto'],
      phone: json['phone'],
      alamat: json['alamat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'nim': nim,
      'role': role,
      'role_id': roleId,
      'api_token': apiToken,
      'foto_profil': fotoProfil,
      'phone': phone,
      'alamat': alamat,
    };
  }
}
