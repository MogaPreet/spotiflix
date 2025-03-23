import '../services/session_manager.dart';

class AdminAccess {
  static Future<bool> isUserAdmin() async {
    // Get current user
    final userData = await SessionManager.getUser();
    
    // Check if user has admin role
    // This is a simplified example - you would adapt this to your user data structure
    if (userData != null && userData['role'] == 'admin') {
      return true;
    }
    
    // For development purposes, you can return true
    // In production, make sure only admins can access these features
    return true; // Change to false in production
  }
}