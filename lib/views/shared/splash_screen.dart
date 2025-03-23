import 'package:flutter/material.dart';
import '../../config/theme/app_theme.dart';
import '../../services/session_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
    
    _controller.forward();
    
    // Check login status after animation starts
    Future.delayed(const Duration(milliseconds: 500), () {
      _checkLoginStatus();
    });
  }
  
  Future<void> _checkLoginStatus() async {
    try {
      final isLoggedIn = await SessionManager.isLoggedIn();
      
      if (mounted) {
        // Navigate to appropriate screen after a short delay
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(
              isLoggedIn ? '/home' : '/login',
            );
          }
        });
      }
    } catch (e) {
      // If there's any error checking login, go to login screen
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          Navigator.of(context).pushReplacementNamed('/login');
        });
      }
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  
                  
                ),
                child: Image.asset('assets/images/spotiflix_logo.png',
                
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'SPOTIFLIX',
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
