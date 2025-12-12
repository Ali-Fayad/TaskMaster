/// ============================================
/// MAIN. DART - Application Entry Point
/// ============================================
/// This is the main entry point of the TaskMaster application.
/// It initializes the Flutter app, sets up the theme, and
/// defines the home route.
/// ============================================

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'data/database_helper.dart';

/// Main function - Entry point of the application
void main() async {
  // Ensure Flutter bindings are initialized before using platform channels
  // This is required because we're using async operations before runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database before starting the app
  // This creates tables and inserts default categories if needed
  await DatabaseHelper.instance.database;

  // Run the application
  runApp(const TaskMasterApp());
}

/// TaskMasterApp - Root widget of the application
/// This widget sets up the MaterialApp with theme configuration
class TaskMasterApp extends StatelessWidget {
  const TaskMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App title shown in task switcher
      title: 'TaskMaster',

      // Disable the debug banner in the top right corner
      debugShowCheckedModeBanner: false,

      // ========================================
      // THEME CONFIGURATION
      // ========================================
      // Using Material Design 3 with indigo color scheme
      // Add the following inside ThemeData(...) in main.dart

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.light),

        // Global input decoration theme (labels/hints/filled color)
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.black87),
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIconColor: Colors.black54,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),

        // Cursor & general text style can be influenced via textTheme
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
          bodyLarge: TextStyle(color: Colors.black87),
        ),

        // other theme configurations...
      ),

      // Set HomeScreen as the default/home route
      home: const HomeScreen(),
    );
  }
}
