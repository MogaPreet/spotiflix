import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api/appwrite_service.dart';
import '../services/session_manager.dart';

class AuthController extends ChangeNotifier {
  final AppwriteService _appwriteService;
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthController(this._appwriteService);

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // First try to clear any existing sessions
      try {
        await _appwriteService.checkAndDeleteExistingSession();
      } catch (e) {
        debugPrint('Session check failed, continuing anyway: $e');
      }
      
      // Now attempt to create a new session
      final session = await _appwriteService.createSession(email, password);
      
      // Get user details
      final user = await _appwriteService.getUserAccount();
      
      // Store session data in secure storage - with proper error handling
      try {
        await SessionManager.saveSession(session, user);
      } catch (e) {
        debugPrint('Warning: Failed to save session locally: $e');
        // Continue because the session is still valid with Appwrite
        // We'll handle session restoration differently if needed
      }
      
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      
      // Handle specific errors
      if (e.toString().contains('user_session_already_exists')) {
        _error = "You are already logged in. Please restart the app or try again.";
      } else if (e.toString().contains('user_invalid_credentials')) {
        _error = "Invalid email or password. Please try again.";
      } else if (e.toString().contains('Converting object to an encodable object')) {
        _error = "Login successful but couldn't save session data locally. Some features may not work properly.";
        // You could return true here as login technically worked
        return true;
      } else {
        _error = "Login failed: ${e.toString()}";
      }
      
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Create account with Appwrite
      final user = await _appwriteService.createAccount(name, email, password);
      
      return user != null;
    } catch (e) {
      debugPrint('Signup error: $e');
      _error = e.toString();
      rethrow; // Rethrow to handle specific error messages in UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signupAndLogin(String name, String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Step 1: Create account with Appwrite
      final user = await _appwriteService.createAccount(name, email, password);
      
      if (user == null) {
        _error = "Failed to create account";
        return false;
      }
      
      // Step 2: Login with the newly created credentials
      final loginSuccess = await login(email, password);
      
      return loginSuccess;
    } catch (e) {
      debugPrint('Signup and login error: $e');
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> logout() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      try {
        // First check if there's an active session before trying to delete it
        final session = await SessionManager.getSession();
        
        if (session != null) {
          // Only try to delete the session if we have one
          await _appwriteService.deleteSession();
          debugPrint('Session deleted successfully');
        } else {
          debugPrint('No active session found to delete');
        }
      } catch (e) {
        // If Appwrite session deletion fails, just log it
        debugPrint('Appwrite session deletion failed: $e');
        // Continue with logout process anyway
      }
      
      // Clear local session data regardless of whether Appwrite deletion succeeded
      await SessionManager.clearSession();
      
      return true;
    } catch (e) {
      debugPrint('Logout error: $e');
      
      // Even if there's an error, try to clear the local session
      try {
        await SessionManager.clearSession();
        debugPrint('Local session cleared despite error');
      } catch (clearError) {
        debugPrint('Failed to clear local session: $clearError');
      }
      
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<UserModel?> getCurrentUser() async {
    try {
      final userData = await SessionManager.getUser();
      if (userData == null) return null;
      
      return UserModel.fromJson(userData);
    } catch (e) {
      print('Get user error: $e');
      return null;
    }
  }
}