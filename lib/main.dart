import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appwrite/appwrite.dart';

import 'config/routes.dart';
import 'config/theme/app_theme.dart';
import 'controllers/auth_controller.dart';
import 'controllers/bottom_nav_provider.dart'; // Add this import
import 'services/api/appwrite_service.dart';
import 'services/session_manager.dart';
import 'views/authentication/login_page.dart';
import 'views/shared/app_scaffold.dart';
import 'views/shared/splash_screen.dart'; // Add a splash screen

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Add this to ensure initialization
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create service instances
    final appwriteService = AppwriteService();
    
    return MultiProvider(
      providers: [
        // Change from Provider to ChangeNotifierProvider
        ChangeNotifierProvider<AuthController>(
          create: (_) => AuthController(appwriteService),
        ),
        // Add other providers
        ChangeNotifierProvider<BottomNavProvider>(
          create: (_) => BottomNavProvider(),
        ),
        Provider<AppwriteService>.value(value: appwriteService),
      ],
      child: MaterialApp(
        title: 'Spotiflix',
        debugShowCheckedModeBanner: false,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark, // Default to dark theme
        
        // Use simpler pattern - start with splash screen
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          ...AppRoutes.routes,
        },
      ),
    );
  }
}

// Create this file: lib/views/shared/splash_screen.dart
// filepath: c:\Users\Team\Desktop\Flutter_UI\spotiflix\lib\views\shared\splash_screen.dart

// Also make sure you have a SessionManager.isLoggedIn method:
// filepath: c:\Users\Team\Desktop\Flutter_UI\spotiflix\lib\services\session_manager.dart
// Add this method to SessionManager class:

