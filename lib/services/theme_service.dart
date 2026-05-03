import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themePrefKey = 'isDarkMode';
  
  bool _isDarkMode = false;
  late SharedPreferences _prefs;
  bool _initialized = false;

  bool get isDarkMode => _isDarkMode;

  /// Inicializar el servicio y cargar preferencia guardada
  Future<void> initialize() async {
    if (_initialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs.getBool(_themePrefKey) ?? false;
    _initialized = true;
    notifyListeners();
  }

  /// Cambiar entre tema claro y oscuro
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool(_themePrefKey, _isDarkMode);
    notifyListeners();
  }

  /// Establecer tema específico
  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode == isDark) return;
    
    _isDarkMode = isDark;
    await _prefs.setBool(_themePrefKey, _isDarkMode);
    notifyListeners();
  }
}
