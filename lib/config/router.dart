import 'package:flutter/material.dart';
import 'package:panaderia_liz/screens/index.dart';

class AppRouter {
  static const String login = '/login';
  static const String home = '/home';
  static const String tpv = '/tpv';
  static const String products = '/products';
  static const String salesHistory = '/sales-history';
  static const String settings = '/settings';
  static const String users = '/users';
  static const String factory = '/factory';
  static const String delivery = '/delivery';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      case tpv:
        return MaterialPageRoute(
          builder: (_) => const TPVScreen(),
          settings: settings,
        );
      case products:
        return MaterialPageRoute(
          builder: (_) => const ProductsManagementScreen(),
          settings: settings,
        );
      case salesHistory:
        return MaterialPageRoute(
          builder: (_) => const SalesHistoryScreen(),
          settings: settings,
        );
      case AppRouter.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );
      case users:
        return MaterialPageRoute(
          builder: (_) => const UsersManagementScreen(),
          settings: settings,
        );
      case AppRouter.factory:
        return MaterialPageRoute(
          builder: (_) => const FactoryScreen(),
          settings: settings,
        );
      case delivery:
        return MaterialPageRoute(
          builder: (_) => const DeliveryScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
    }
  }
}
