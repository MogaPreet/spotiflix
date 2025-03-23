import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';
import '../../config/constants.dart';

class AppwriteService {
  late Client client;
  late Account account;
  late Databases databases;
  late Storage storage;

  AppwriteService() {
    _init();
  }

  void _init() {
    client = Client()
        .setEndpoint(AppConstants.appwriteEndpoint)
        .setProject(AppConstants.appwriteProjectId);
    
    // Only set self-signed in debug mode
    
      client.setSelfSigned(status: true);
    

    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
  }

  // Authentication methods
  Future<models.User?> createAccount(String name, String email, String password) async {
    try {
      final result = await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      return result;
    } catch (e) {
      debugPrint('Create account error: $e');
      rethrow;
    }
  }

  Future<models.Session> createSession(String email, String password) async {
    try {
      return await account.createEmailPasswordSession(
        email: email, 
        password: password
      );
    } catch (e) {
      debugPrint('Create session error: $e');
      rethrow;
    }
  }

  Future<models.User> getUserAccount() async {
    try {
      return await account.get();
    } catch (e) {
      debugPrint('Get user account error: $e');
      rethrow;
    }
  }

  // Update the deleteSession method to handle potential null cases
  Future<void> deleteSession([String? sessionId]) async {
    try {
      // If sessionId is provided, use it; otherwise, use 'current'
      final targetSessionId = sessionId ?? 'current';
      
      // Try to delete the session
      await account.deleteSession(sessionId: targetSessionId);
    } catch (e) {
      // Check for specific error types
      if (e.toString().contains('Session not found')) {
        // Session already expired or doesn't exist - not an error for logout
        debugPrint('Session already expired or not found');
        return; // Return normally as this is expected during logout
      }
      
      debugPrint('Delete session error: $e');
      throw e; // Rethrow other unexpected errors
    }
  }

  // Add this new method to check and delete existing sessions
  Future<void> checkAndDeleteExistingSession() async {
    try {
      // Try to get the current session
      final currentSession = await account.getSession(sessionId: 'current');
      
      // If we can get the session, delete it
      if (currentSession.$id.isNotEmpty) {
        await account.deleteSession(sessionId: 'current');
        debugPrint('Deleted existing session');
      }
    } catch (e) {
      // If error is "Session not found", that's fine - there's no active session
      // For other errors, we might want to log them but still proceed
      debugPrint('No active session found or error checking session: $e');
      // We don't rethrow here as this is a preparatory step
    }
  }
}