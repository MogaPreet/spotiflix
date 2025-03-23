import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_theme.dart';
import '../../controllers/auth_controller.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  // Use ValueNotifier instead of setState for these values
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _errorMessageNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<bool> _obscurePasswordNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _obscureConfirmPasswordNotifier = ValueNotifier<bool>(true);
  
  // Animation controller for fade in
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    _isLoadingNotifier.dispose();
    _errorMessageNotifier.dispose();
    _obscurePasswordNotifier.dispose();
    _obscureConfirmPasswordNotifier.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Reset error message
    _errorMessageNotifier.value = null;
    
    // Validate inputs
    if (_nameController.text.trim().isEmpty) {
      _errorMessageNotifier.value = "Please enter your name";
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _errorMessageNotifier.value = "Please enter your email";
      return;
    }

    if (!_isValidEmail(_emailController.text.trim())) {
      _errorMessageNotifier.value = "Please enter a valid email address";
      return;
    }

    if (_passwordController.text.isEmpty) {
      _errorMessageNotifier.value = "Please enter a password";
      return;
    }
    
    if (_passwordController.text.length < 8) {
      _errorMessageNotifier.value = "Password must be at least 8 characters";
      return;
    }
    
    if (_confirmPasswordController.text.isEmpty) {
      _errorMessageNotifier.value = "Please confirm your password";
      return;
    }
    
    if (_passwordController.text != _confirmPasswordController.text) {
      _errorMessageNotifier.value = "Passwords do not match";
      return;
    }
    
    _isLoadingNotifier.value = true;

    try {
      final authController = context.read<AuthController>();
      
      // Use the combined method for signup and auto-login
      final success = await authController.signupAndLogin(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (success) {
        if (mounted) {
          _showSuccessAndNavigate();  // This is the method that shows success and navigates to home
        }
      } else {
        _errorMessageNotifier.value = authController.error ?? "Registration failed";
      }
    } catch (e) {
      // Error handling...
    } finally {
      if (mounted) {
        _isLoadingNotifier.value = false;
      }
    }
  }
  
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  void _showSuccessAndNavigate() {
    // Display success overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.greenAccent,
                    size: 80,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome to Spotiflix!',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your account has been created successfully.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    
    // Navigate to home after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop(); // Close dialog
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
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
                  SizedBox(height: size.height * 0.05),
                  
                  // App branding with smaller size for signup
                  const AppBrandingCompact(),
                  
                  SizedBox(height: size.height * 0.04),
                  
                  // Signup form with glass effect
                  SignupFormGlass(
                    nameController: _nameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                    isLoadingNotifier: _isLoadingNotifier,
                    errorMessageNotifier: _errorMessageNotifier,
                    obscurePasswordNotifier: _obscurePasswordNotifier,
                    obscureConfirmPasswordNotifier: _obscureConfirmPasswordNotifier,
                    onSignup: _signup,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Login option
                  const LoginOption(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Compact version of app branding for signup page
class AppBrandingCompact extends StatelessWidget {
  const AppBrandingCompact({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
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
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                letterSpacing: 3,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your account',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Colors.grey[400],
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class SignupFormGlass extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final ValueNotifier<bool> isLoadingNotifier;
  final ValueNotifier<String?> errorMessageNotifier;
  final ValueNotifier<bool> obscurePasswordNotifier;
  final ValueNotifier<bool> obscureConfirmPasswordNotifier;
  final VoidCallback onSignup;

  const SignupFormGlass({
    Key? key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isLoadingNotifier,
    required this.errorMessageNotifier,
    required this.obscurePasswordNotifier,
    required this.obscureConfirmPasswordNotifier,
    required this.onSignup,
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
            'Sign Up',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Join millions of viewers today',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          
          // Name field
          LoginTextField(
            controller: nameController,
            hintText: 'Full Name',
            prefixIcon: Icons.person_outline,
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 16),
          
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
          const SizedBox(height: 16),
          
          // Confirm Password field
          ValueListenableBuilder<bool>(
            valueListenable: obscureConfirmPasswordNotifier,
            builder: (context, obscureConfirmPassword, _) {
              return LoginTextField(
                controller: confirmPasswordController,
                hintText: 'Confirm Password',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                obscureText: obscureConfirmPassword,
                onVisibilityToggle: () {
                  obscureConfirmPasswordNotifier.value = !obscureConfirmPassword;
                },
              );
            },
          ),
          const SizedBox(height: 12),
          
          // Password strength indicator or requirements (optional)
          // Terms and conditions
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'By signing up, you agree to our Terms and Privacy Policy',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
          
          // Sign Up button
          ValueListenableBuilder<bool>(
            valueListenable: isLoadingNotifier,
            builder: (context, isLoading, _) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onSignup,
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
                      : const Text('CREATE ACCOUNT'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class LoginOption extends StatelessWidget {
  const LoginOption({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Already have an account?",
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: Text(
              'Log In',
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

// Reusing the TextField component from login page
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