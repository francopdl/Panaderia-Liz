enum UserRole {
  admin,
  employee,
}

class User {
  final String id;
  final String username;
  final String password;
  final UserRole role;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      username: map['username'] as String,
      password: map['password'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == (map['role'] as String),
        orElse: () => UserRole.employee,
      ),
      createdAt: DateTime.parse(map['created_at'] as String? ?? map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'role': role.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'User(id: $id, username: $username, role: $role)';
}
