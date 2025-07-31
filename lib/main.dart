import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_screen.dart';
import 'services/sqlite_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SQLiteService.initDatabase(); // ← fix the method if this errors
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  // Load saved theme preference
  void _loadThemePreference() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      });
    } catch (e) {
      // If SharedPreferences fails, default to light mode
      setState(() {
        _isDarkMode = false;
      });
    }
  }

  // Toggle and save theme preference
  void _toggleDarkMode(bool value) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _isDarkMode = value;
      });
      await prefs.setBool('isDarkMode', value);
    } catch (e) {
      // If saving fails, just update the UI
      setState(() {
        _isDarkMode = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Electricity Bill Manager',

      // 🌅 LIGHT THEME
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        brightness: Brightness.light,

        // AppBar theme for light mode
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),

        // Card theme for light mode
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.grey.withOpacity(0.1),
        ),

        // Text theme for light mode
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
        ),

        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
        ),
      ),

      // 🌙 DARK THEME
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF121212),
        brightness: Brightness.dark,

        // AppBar theme for dark mode
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          foregroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),

        // Card theme for dark mode
        cardTheme: const CardThemeData(color: Color(0xFF1E1E1E), elevation: 4),

        // Text theme for dark mode
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white70),
          bodyMedium: TextStyle(color: Colors.white70),
        ),

        // Input decoration theme for dark mode
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF404040)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue),
          ),
        ),

        // Switch theme for dark mode
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.blue;
            }
            return Colors.grey[600]!;
          }),
          trackColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.blue.withOpacity(0.5);
            }
            return Colors.grey[800]!;
          }),
        ),

        // Icon theme for dark mode
        iconTheme: const IconThemeData(color: Colors.white70),

        // Drawer theme for dark mode (sidebar)
        drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF1E293B)),
      ),

      // 🎯 THEME MODE CONTROLLER
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // Pass theme state to MainScreen
      home: MainScreen(
        isDarkMode: _isDarkMode,
        onThemeChanged: _toggleDarkMode,
      ),
    );
  }
}
