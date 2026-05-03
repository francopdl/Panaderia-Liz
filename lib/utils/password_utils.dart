import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Password hashing and verification utilities
class PasswordUtils {
  /// Hash password using SHA-256 with salt
  static String hashPassword(String password, {String? salt}) {
    final usedSalt = salt ?? _generateSalt();
    final bytes = utf8.encode('$password$usedSalt');
    return '${sha256.convert(bytes)}:$usedSalt';
  }

  /// Verify password against hash
  static bool verifyPassword(String password, String hash) {
    try {
      final parts = hash.split(':');
      if (parts.length != 2) return false;

      final salt = parts[1];
      final expectedHash = hashPassword(password, salt: salt);
      return expectedHash == hash;
    } catch (e) {
      return false;
    }
  }

  /// Generate random salt
  static String _generateSalt() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(16, (index) => chars[random.nextInt(chars.length)]).join();
  }
}

class Random {
  static final _random = DateTime.now().microsecond;

  int nextInt(int max) {
    return (_random * DateTime.now().microsecond) ~/ (max + 1);
  }
}
