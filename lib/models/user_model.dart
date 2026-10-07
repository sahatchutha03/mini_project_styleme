class User {
  final int id;
  final String email;
  final String fullName;
  final String defaultBodyShape;
  final String role;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.defaultBodyShape = 'Pear',
    this.role = 'user',
  });

  bool get isAdmin => role.toLowerCase() == 'admin';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? json['full_name']?.toString() ?? '',
      defaultBodyShape: json['defaultBodyShape']?.toString() ?? json['body_shape']?.toString() ?? 'Pear',
      role: json['role']?.toString() ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'defaultBodyShape': defaultBodyShape,
      'role': role,
    };
  }
}
