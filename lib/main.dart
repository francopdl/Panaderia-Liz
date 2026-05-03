import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:panaderia_liz/firebase_options.dart';
import 'package:panaderia_liz/config/index.dart';
import 'package:panaderia_liz/services/index.dart';
import 'package:panaderia_liz/screens/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Seed Firestore with initial data if empty
  await FirestoreService().seedIfEmpty();

  // Initialize ThemeService
  final themeService = ThemeService();
  await themeService.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthServiceDB>(create: (_) => AuthServiceDB()),
        Provider<ProductServiceDB>(create: (_) => ProductServiceDB()),
        Provider<SalesServiceDB>(create: (_) => SalesServiceDB()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        ChangeNotifierProvider<CartNotifier>(create: (_) => CartNotifier()),
        ChangeNotifierProvider<ThemeService>(create: (_) => themeService),
        ChangeNotifierProvider<SalesNotifier>(
          create: (context) => SalesNotifier(SalesServiceDB()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return MaterialApp(
          title: 'Panadería Liz - TPV',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          debugShowCheckedModeBanner: false,
          home: const LoginScreen(),
          onGenerateRoute: AppRouter.generateRoute,
          initialRoute: AppRouter.login,
        );
      },
    );
  }
}
