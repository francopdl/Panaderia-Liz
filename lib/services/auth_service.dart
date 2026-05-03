import 'package:panaderia_liz/models/index.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  // Mock users database
  final List<User> _users = [
    User(
      id: '1',
      username: 'admin',
      password: 'admin123',
      role: UserRole.admin,
      createdAt: DateTime.now(),
    ),
    User(
      id: '2',
      username: 'empleado',
      password: '1234',
      role: UserRole.employee,
      createdAt: DateTime.now(),
    ),
  ];

  User? _currentUser;
  
  User? get currentUser => _currentUser;
  
  bool get isAuthenticated => _currentUser != null;
  
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  
  bool get isEmployee => _currentUser?.role == UserRole.employee;

  /// Authenticate user with username and password
  Future<bool> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

    try {
      final user = _users.firstWhere(
        (u) => u.username == username && u.password == password,
      );
      _currentUser = user;
      return true;
    } catch (e) {
      _currentUser = null;
      return false;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  /// Get all users (admin only)
  List<User> getAllUsers() {
    return List.from(_users);
  }

  /// Add a new user (admin only)
  Future<User> addUser(
    String username,
    String password,
    UserRole role,
  ) async {
    final newUser = User(
      id: const Uuid().v4(),
      username: username,
      password: password,
      role: role,
      createdAt: DateTime.now(),
    );
    _users.add(newUser);
    return newUser;
  }

  /// Delete a user (admin only)
  Future<bool> deleteUser(String userId) async {
    final userIndex = _users.indexWhere((u) => u.id == userId);
    if (userIndex != -1) {
      _users.removeAt(userIndex);
      return true;
    }
    return false;
  }
}
