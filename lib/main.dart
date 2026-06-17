import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'theme_provider.dart';

void main() {
  // Ensured Flutter engine bindings are initialized before app launch
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Defining a static seed color makes it easy to change your branding globally
  static const Color _brandSeedColor = Colors.indigo;

  @override
  Widget build(BuildContext context) {
    // Using context.watch is cleaner and syntax-consistent with context.read
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "MultiSense AI",

      // 1. Polished Light Theme Configuration
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _brandSeedColor,
          brightness: Brightness.light,
        ),
        // Giving all app bars a consistent layout style globally
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        // Softening card styles globally to look unified across screens
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      // 2. Polished Dark Theme Configuration
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _brandSeedColor,
          brightness: Brightness.dark,
          // Tweaks dark surface backgrounds slightly so cards layer beautifully
          surface: Colors.grey[900],
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.grey[900],
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      themeMode: themeProvider.themeMode,
      home: const HomeScreen(),
    );
  }
}