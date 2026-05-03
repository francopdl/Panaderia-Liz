import 'package:panaderia_liz/config/constants.dart';

/// Input validators for forms
class Validators {
  /// Validate username
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'El usuario es requerido';
    }
    if (value.length < AppConstants.minUsernameLength) {
      return 'El usuario debe tener al menos ${AppConstants.minUsernameLength} caracteres';
    }
    if (value.length > AppConstants.maxUsernameLength) {
      return 'El usuario no puede exceder ${AppConstants.maxUsernameLength} caracteres';
    }
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value)) {
      return 'El usuario solo puede contener letras, números, guiones y guiones bajos';
    }
    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'La contraseña debe tener al menos ${AppConstants.minPasswordLength} caracteres';
    }
    if (value.length > AppConstants.maxPasswordLength) {
      return 'La contraseña no puede exceder ${AppConstants.maxPasswordLength} caracteres';
    }
    return null;
  }

  /// Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un email válido';
    }
    return null;
  }

  /// Validate price
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'El precio es requerido';
    }
    final price = double.tryParse(value);
    if (price == null) {
      return 'Ingresa un precio válido';
    }
    if (price < AppConstants.minPrice) {
      return 'El precio no puede ser negativo';
    }
    if (price > AppConstants.maxPrice) {
      return 'El precio excede el máximo permitido';
    }
    return null;
  }

  /// Validate quantity
  static String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'La cantidad es requerida';
    }
    final quantity = int.tryParse(value);
    if (quantity == null) {
      return 'Ingresa una cantidad válida';
    }
    if (quantity < AppConstants.minQuantity) {
      return 'La cantidad mínima es ${AppConstants.minQuantity}';
    }
    if (quantity > AppConstants.maxQuantity) {
      return 'La cantidad máxima es ${AppConstants.maxQuantity}';
    }
    return null;
  }

  /// Validate product name
  static String? validateProductName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre del producto es requerido';
    }
    if (value.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    if (value.length > 100) {
      return 'El nombre no puede exceder 100 caracteres';
    }
    return null;
  }

  /// Validate not empty
  static String? validateNotEmpty(String? value, {String label = 'Este campo'}) {
    if (value == null || value.isEmpty) {
      return '$label es requerido';
    }
    return null;
  }

  /// Validate match passwords
  static String? validatePasswordMatch(String? value, String password) {
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  /// Check if password is strong
  static bool isStrongPassword(String password) {
    // At least one uppercase, one lowercase, one number, one special char
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return hasUppercase && hasLowercase && hasDigits && hasSpecialChars;
  }

  /// Get password strength percentage (0-1)
  static double getPasswordStrength(String password) {
    double strength = 0;

    if (password.isEmpty) return 0;

    // Length check
    if (password.length >= 8) strength += 0.25;
    if (password.length >= 12) strength += 0.1;

    // Character variety
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.15;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.15;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.15;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;

    return strength.clamp(0, 1);
  }
}
