import 'dart:math';
import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_theme.dart';
import '../../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Use ValueNotifier instead of setState for these values
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _errorMessageNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<bool> _obscurePasswordNotifier = ValueNotifier<bool>(true);
  
  // Animation controllers for simple fade in
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    _isLoadingNotifier.dispose();
    _errorMessageNotifier.dispose();
    _obscurePasswordNotifier.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Validate inputs
    if (_emailController.text.trim().isEmpty) {
      _errorMessageNotifier.value = "Please enter your email";
      return;
    }

    if (_passwordController.text.isEmpty) {
      _errorMessageNotifier.value = "Please enter your password";
      return;
    }
    
    _errorMessageNotifier.value = null;
    _isLoadingNotifier.value = true;

    try {
      final authController = Provider.of<AuthController>(context, listen: false);
      final success = await authController.login(
        _emailController.text.trim(), 
        _passwordController.text.trim(),
      );
      
      if (success) {
        // Navigate to home screen on successful login
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        _errorMessageNotifier.value = "Invalid email or password. Please try again.";
      }
    } catch (e) {
      _errorMessageNotifier.value = e.toString().contains('Invalid credentials')
          ? "Invalid email or password. Please try again."
          : "Login failed. Please check your connection and try again.";
    } finally {
      if (mounted) {
        _isLoadingNotifier.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.1),
                  
                  // Logo and App name
                  const AppBranding(),
                  
                  SizedBox(height: size.height * 0.08),
                  
                  // Login form with glass effect
                  LoginFormGlass(
                    emailController: _emailController,
                    passwordController: _passwordController,
                    isLoadingNotifier: _isLoadingNotifier,
                    errorMessageNotifier: _errorMessageNotifier,
                    obscurePasswordNotifier: _obscurePasswordNotifier,
                    onLogin: _login,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Sign up option
                  const SignUpOption(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Extracted widgets

class AppBranding extends StatefulWidget {
  const AppBranding({Key? key}) : super(key: key);

  @override
  State<AppBranding> createState() => _AppBrandingState();
}

class _AppBrandingState extends State<AppBranding> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );
    
    _rotateAnimation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          // Animated logo
         
          // App name with fade animation
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Column(
                  children: [
                    // Animated logo text with gradient
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.textPrimaryColor,
                          AppTheme.secondaryColor,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ).createShader(bounds),
                      child: Text(
                        'SPOTIFLIX',
                        style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          letterSpacing: 3,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Tagline with typing effect
                    DefaultTextStyle(
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Colors.grey[400],
                        letterSpacing: 0.5,
                      ),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            'Your Ultimate Entertainment Companion',
                            speed: const Duration(milliseconds: 80),
                          ),
                        ],
                        isRepeatingAnimation: false,
                        totalRepeatCount: 1,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class LoginFormGlass extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final ValueNotifier<bool> isLoadingNotifier;
  final ValueNotifier<String?> errorMessageNotifier;
  final ValueNotifier<bool> obscurePasswordNotifier;
  final VoidCallback onLogin;

  const LoginFormGlass({
    Key? key,
    required this.emailController,
    required this.passwordController,
    required this.isLoadingNotifier,
    required this.errorMessageNotifier,
    required this.obscurePasswordNotifier,
    required this.onLogin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Sign in to continue',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 30),
          
          // Email field
          LoginTextField(
            controller: emailController,
            hintText: 'Email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          
          // Password field
          ValueListenableBuilder<bool>(
            valueListenable: obscurePasswordNotifier,
            builder: (context, obscurePassword, _) {
              return LoginTextField(
                controller: passwordController,
                hintText: 'Password',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                obscureText: obscurePassword,
                onVisibilityToggle: () {
                  obscurePasswordNotifier.value = !obscurePassword;
                },
              );
            },
          ),
          const SizedBox(height: 12),
          
          // Forgot password
          const ForgotPasswordButton(),
          const SizedBox(height: 8),
          
          // Error message
          ValueListenableBuilder<String?>(
            valueListenable: errorMessageNotifier,
            builder: (context, errorMessage, _) {
              if (errorMessage == null) return const SizedBox.shrink();
              
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.errorColor.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppTheme.errorColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage,
                        style: TextStyle(
                          color: AppTheme.errorColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Login button
          ValueListenableBuilder<bool>(
            valueListenable: isLoadingNotifier,
            builder: (context, isLoading, _) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('SIGN IN'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onVisibilityToggle;
  final TextInputType? keyboardType;

  const LoginTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.obscureText = false,
    this.onVisibilityToggle,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(
            prefixIcon,
            color: Colors.grey[400],
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[400],
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

class ForgotPasswordButton extends StatelessWidget {
  const ForgotPasswordButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // Navigate to forgot password screen
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(50, 30),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class SignUpOption extends StatelessWidget {
  const SignUpOption({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account?",
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/signup');
            },
            child: Text(
              'Sign Up',
              style: TextStyle(
                color: AppTheme.secondaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for floating particles effect - unchanged
class ParticlesPainter extends CustomPainter {
  final Animation<double> animation;
  final particlesCount = 30;
  final List<Offset> positions = [];
  final List<double> sizes = [];
  final List<Color> colors = [];
  
  ParticlesPainter(this.animation) : super(repaint: animation) {
    final random = Random();
    
    for (int i = 0; i < particlesCount; i++) {
      positions.add(
        Offset(
          random.nextDouble() * 400, 
          random.nextDouble() * 800,
        ),
      );
      sizes.add(random.nextDouble() * 4 + 1);
      colors.add(
        Color.lerp(
          AppTheme.primaryColor.withOpacity(random.nextDouble() * 0.4), 
          AppTheme.secondaryColor.withOpacity(random.nextDouble() * 0.4),
          random.nextDouble(),
        ) ?? AppTheme.primaryColor.withOpacity(0.3),
      );
    }
  }
  
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < particlesCount; i++) {
      final paint = Paint()..color = colors[i];
      final position = Offset(
        (positions[i].dx + animation.value * 10) % size.width,
        (positions[i].dy + animation.value * 5) % size.height,
      );
      canvas.drawCircle(position, sizes[i], paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}