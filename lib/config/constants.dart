import 'package:flutter/material.dart';

/// App-wide constants
class AppConstants {
  // App metadata
  static const String appName = 'Panadería Liz TPV';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Sistema de Punto de Venta para Panadería Liz';

  // Timeouts
  static const Duration dbTimeout = Duration(seconds: 10);
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Database
  static const String dbName = 'panaderia_liz.db';
  static const int dbVersion = 1;

  // Roles
  static const String roleAdmin = 'admin';
  static const String roleEmployee = 'employee';
  static const String roleGuest = 'guest';

  // UI Sizes
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 12.0;
  static const double borderRadius = 8.0;
  static const double buttonHeight = 48.0;

  // Validation
  static const int minPasswordLength = 4;
  static const int maxPasswordLength = 50;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;

  // Colors
  static const Color primaryColor = Color(0xFFDE5B35); // Deep Orange
  static const Color primaryLight = Color(0xFFE67E50);
  static const Color primaryDark = Color(0xFFC84B25);
  static const Color accentColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color warningColor = Color(0xFFFFA500);
  static const Color successColor = Color(0xFF388E3C);

  // Strings
  static const String appTitle = 'Panadería Liz';
  static const String loginTitle = 'Iniciar Sesión';
  static const String homeTitle = 'Panel de Control';
  static const String tpvTitle = 'Punto de Venta';
  static const String salesHistoryTitle = 'Historial de Ventas';
  static const String productsTitle = 'Productos';
  static const String settingsTitle = 'Configuración';
  static const String usersTitle = 'Usuarios';

  // Error messages
  static const String errorGeneric = 'Ocurrió un error. Intenta de nuevo.';
  static const String errorConnection = 'Error de conexión. Verifica tu conexión a internet.';
  static const String errorDatabase = 'Error en la base de datos.';
  static const String errorAuthentication = 'Credenciales inválidas.';
  static const String errorNotFound = 'No encontrado.';
  static const String errorPermissionDenied = 'No tienes permiso para realizar esta acción.';

  // Success messages
  static const String successLogin = 'Sesión iniciada correctamente.';
  static const String successLogout = 'Sesión cerrada.';
  static const String successCreated = 'Creado exitosamente.';
  static const String successUpdated = 'Actualizado exitosamente.';
  static const String successDeleted = 'Eliminado exitosamente.';
  static const String successSaved = 'Guardado exitosamente.';

  // Empty states
  static const String emptyNoSales = 'No hay ventas registradas';
  static const String emptyNoProducts = 'No hay productos disponibles';
  static const String emptyNoUsers = 'No hay usuarios registrados';
  static const String emptyNoResults = 'No se encontraron resultados';

  // Numbers
  static const double minPrice = 0.0;
  static const double maxPrice = 9999.99;
  static const int minQuantity = 1;
  static const int maxQuantity = 999;

  // API Keys (if needed in future)
  // static const String apiBaseUrl = 'https://api.example.com';
  // static const String apiKey = 'your-api-key';

  // Preferences keys
  static const String prefTheme = 'theme_mode';
  static const String prefLanguage = 'language';
  static const String prefLastUser = 'last_user';
  static const String prefRememberMe = 'remember_me';
  static const String prefDarkMode = 'dark_mode';
}
