import 'package:flutter/foundation.dart';
import 'package:panaderia_liz/models/index.dart';
import 'package:panaderia_liz/services/firestore_service.dart';

class AuthServiceDB {
  static final AuthServiceDB _instance = AuthServiceDB._internal();

  factory AuthServiceDB() => _instance;

  AuthServiceDB._internal();

  final FirestoreService _fs = FirestoreService();

  User? _currentUser;

  // In-memory users storage for web fallback
  static final Map<String, User> _webUsers = {
    'admin': User(
      id: 'admin-001',
      username: 'admin',
      password: 'admin123',
      role: UserRole.admin,
      createdAt: DateTime.now(),
    ),
    'empleado': User(
      id: 'employee-001',
      username: 'empleado',
      password: '1234',
      role: UserRole.employee,
      createdAt: DateTime.now(),
    ),
  };

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isEmployee => _currentUser?.role == UserRole.employee;

  Future<User?> login(String username, String password) async {
    try {
      if (username.isEmpty || password.isEmpty) return null;

      // On web, use in-memory users
      if (kIsWeb) {
        final user = _webUsers[username];
        if (user != null && user.password == password) {
          _currentUser = user;
          return _currentUser;
        }
        return null;
      }

      final data = await _fs.getUserByUsername(username);
      if (data == null) return null;

      if (data['password'] != password) return null;

      final roleStr = data['role'] as String? ?? 'employee';
      final role = roleStr == 'admin' ? UserRole.admin : UserRole.employee;

      _currentUser = User(
        id: data['id'] as String,
        username: data['username'] as String,
        password: data['password'] as String,
        role: role,
        createdAt: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
      );
      return _currentUser;
    } catch (e) {
      print('Login error: $e');
      _currentUser = null;
      return null;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
  }

  Future<List<User>> getAllUsers() async {
    try {
      if (_currentUser?.role != UserRole.admin) return [];

      // On web, return in-memory users
      if (kIsWeb) {
        return _webUsers.values.toList();
      }

      final users = await _fs.getAllUsers();
      return users.map((data) {
        final roleStr = data['role'] as String? ?? 'employee';
        final role = roleStr == 'admin' ? UserRole.admin : UserRole.employee;
        return User(
          id: data['id'] as String,
          username: data['username'] as String,
          password: data['password'] as String,
          role: role,
          createdAt: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('Get all users error: $e');
      return [];
    }
  }

  Future<User?> addUser(
    String id,
    String username,
    String password,
    UserRole role,
  ) async {
    try {
      if (_currentUser?.role != UserRole.admin) {
        throw Exception('Solo administradores pueden crear usuarios');
      }
      if (username.isEmpty || password.isEmpty) {
        throw Exception('Usuario y contraseña son requeridos');
      }

      // Check if username already exists
      if (kIsWeb) {
        if (_webUsers.containsKey(username)) {
          throw Exception('El usuario ya existe');
        }
      }

      final newUser = User(
        id: id,
        username: username,
        password: password,
        role: role,
        createdAt: DateTime.now(),
      );

      if (kIsWeb) {
        _webUsers[username] = newUser;
        return newUser;
      }

      final roleStr = role == UserRole.admin ? 'admin' : 'employee';
      await _fs.addUser(id, username, password, roleStr);

      return newUser;
    } catch (e) {
      print('Add user error: $e');
      rethrow;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      if (_currentUser?.role != UserRole.admin) return false;

      if (kIsWeb) {
        _webUsers.removeWhere((key, user) => user.id == userId);
        return true;
      }

      return await _fs.deleteUser(userId);
    } catch (e) {
      print('Delete user error: $e');
      return false;
    }
  }

  Future<bool> updateUser(User user) async {
    try {
      if (_currentUser?.role != UserRole.admin && _currentUser?.id != user.id) {
        return false;
      }

      if (kIsWeb) {
        _webUsers[user.username] = user;
        return true;
      }

      return await _fs.updateUser(user.id, {
        'username': user.username,
        'password': user.password,
        'role': user.role == UserRole.admin ? 'admin' : 'employee',
      });
    } catch (e) {
      print('Update user error: $e');
      return false;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      if (_currentUser == null || newPassword.isEmpty) return false;
      if (_currentUser!.password != oldPassword) return false;

      if (kIsWeb) {
        _currentUser = _currentUser!.copyWith(password: newPassword);
        _webUsers[_currentUser!.username] = _currentUser!;
        return true;
      }

      final success = await _fs.updateUser(_currentUser!.id, {
        'password': newPassword,
      });

      if (success) {
        _currentUser = _currentUser!.copyWith(password: newPassword);
      }
      return success;
    } catch (e) {
      print('Change password error: $e');
      return false;
    }
  }
}

extension UserCopyWith on User {
  User copyWith({
    String? id,
    String? username,
    String? password,
    UserRole? role,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
