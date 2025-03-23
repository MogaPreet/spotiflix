import 'dart:convert';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionManager {
  static const _storage = FlutterSecureStorage();
  static const _sessionKey = 'appwrite_session';
  static const _userKey = 'appwrite_user';

  // Update saveSession to handle all Appwrite model types properly
  static Future<void> saveSession(dynamic session, [dynamic user]) async {
    try {
      // Process session data
      if (session != null) {
        Map<String, dynamic> sessionData;
        
        if (session is models.Session) {
          // Extract necessary fields from Session model
          sessionData = {
            'id': session.$id,
            'userId': session.userId,
            'provider': session.provider,
            'providerUid': session.providerUid,
            'expire': session.$createdAt,
            'current': true,
          };
        } else if (session is Map) {
          sessionData = Map<String, dynamic>.from(session);
        } else {
          // For any other type, try to serialize it safely
          sessionData = {'data': session.toString()};
        }
        
        await _storage.write(key: _sessionKey, value: jsonEncode(sessionData));
        debugPrint('Session data saved successfully');
      }
      
      // Process user data
      if (user != null) {
        Map<String, dynamic> userData;
        
        if (user is models.User) {
          // Handle the User model specifically
          userData = {
            'id': user.$id,
            'name': user.name,
            'email': user.email,
            // Convert Preferences to a simple Map
            'prefs': _preferencesToMap(user.prefs),
            'status': user.status,
            'createdAt': user.$createdAt,
            'updatedAt': user.$updatedAt,
          };
        } else if (user is Map) {
          userData = Map<String, dynamic>.from(user);
          // Check if there's a preferences object and handle it
          if (userData.containsKey('prefs') && userData['prefs'] is! Map) {
            userData['prefs'] = _preferencesToMap(userData['prefs']);
          }
        } else {
          // For any other type, try to serialize it safely
          userData = {'data': user.toString()};
        }
        
        await _storage.write(key: _userKey, value: jsonEncode(userData));
        debugPrint('User data saved successfully');
      }
    } catch (e) {
      debugPrint('Error saving session: $e');
      throw e;  // Rethrow so the error can be handled upstream
    }
  }

  // Helper method to convert Preferences object to a simple Map
  static Map<String, dynamic> _preferencesToMap(dynamic prefs) {
    if (prefs == null) return {};
    
    try {
      if (prefs is models.Preferences) {
        // Access the data property of Preferences which contains the actual preference values
        return prefs.data;
      } else if (prefs is Map) {
        return Map<String, dynamic>.from(prefs);
      } else {
        // If we can't handle it properly, return an empty map
        debugPrint('Unable to convert preferences to map: $prefs');
        return {};
      }
    } catch (e) {
      debugPrint('Error converting preferences: $e');
      return {};
    }
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUser() async {
    try {
      final userData = await _storage.read(key: _userKey);
      if (userData == null) return null;
      return jsonDecode(userData) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  // Get session data
  static Future<Map<String, dynamic>?> getSession() async {
    try {
      final sessionData = await _storage.read(key: _sessionKey);
      if (sessionData == null) return null;
      return jsonDecode(sessionData) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error getting session data: $e');
      return null;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final sessionData = await getSession();
      return sessionData != null;
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return false;
    }
  }

  // Clear all stored data
  static Future<void> clearSession() async {
    try {
      // Delete the session key if it exists
      await _storage.delete(key: _sessionKey);
      // Delete the user key if it exists
      await _storage.delete(key: _userKey);
      debugPrint('Session cleared successfully');
    } catch (e) {
      debugPrint('Error clearing session: $e');
      // Rethrow to allow handling upstream
      throw e;
    }
  }
}