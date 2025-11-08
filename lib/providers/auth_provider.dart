import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../models/subscription_model.dart';
import '../services/api_service.dart';
import '../config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  UserModel? _user;
  SubscriptionModel? _activeSubscription;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  SubscriptionModel? get activeSubscription => _activeSubscription;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isEmailVerified => _user?.emailVerified ?? false;
  bool get isVip => _activeSubscription?.isActive ?? false;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // First, try to load user from storage (for quick restoration)
      await _loadUserFromStorage();

      // Then verify with server (cookies are automatically sent)
      try {
        final user = await _apiService.checkAuth();
        if (user != null) {
          // Server confirmed user is valid, update with latest data
          _user = user;
          await _loadActiveSubscription();
          await _saveUserToStorage();
          debugPrint('User authenticated and persisted: ${user.email}');
        } else {
          // Server says not authenticated - clear user
          debugPrint('User not authenticated, clearing stored user');
          _user = null;
          await _clearUserFromStorage();
        }
      } catch (e) {
        // Network error or server error
        debugPrint('Auth check failed: $e');
        // If we have a stored user, keep it for offline access
        // But if checkAuth returns 401/403, cookies are cleared by ApiService
        // So we should clear user if checkAuth explicitly fails with auth error
        if (_user != null) {
          debugPrint('Keeping stored user for offline access: ${_user!.email}');
        } else {
          await _clearUserFromStorage();
        }
      }
    } catch (e) {
      debugPrint('Auth initialization error: $e');
      _error = e.toString();
      // Don't clear user on initialization error, keep stored user
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    required String username,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _apiService.signup(
        email: email,
        password: password,
        username: username,
      );
      await _saveUserToStorage();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _user = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signin({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _apiService.signin(
        email: email,
        password: password,
      );
      await _loadActiveSubscription();
      await _saveUserToStorage();
      debugPrint('Signin successful: ${_user?.toJson()}');
      _error = null;
    } catch (e) {
      debugPrint('Signin error: $e');
      _error = e.toString();
      _user = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Try to sign out from server (but don't fail if network is down)
      try {
        await _apiService.signout();
      } catch (e) {
        debugPrint('Server signout failed (may be offline): $e');
        // Continue with local signout anyway
      }

      // Always clear local state
      _user = null;
      _activeSubscription = null;
      await _clearUserFromStorage();

      // Clear token is handled by ApiService.signout()
      debugPrint('User signed out successfully');
    } catch (e) {
      debugPrint('Signout error: $e');
      _error = e.toString();
      // Even if there's an error, clear local state
      _user = null;
      _activeSubscription = null;
      await _clearUserFromStorage();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyEmail(String token, String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.verifyEmail(token, email);
      if (_user != null) {
        _user = _user!.copyWith(emailVerified: true);
        await _saveUserToStorage();
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendVerification() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.resendVerification();
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.resetPassword(email);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadActiveSubscription() async {
    if (_user == null) return;

    try {
      _activeSubscription = await _apiService.getActiveSubscription(_user!.id);
      notifyListeners();
    } catch (e) {
      _activeSubscription = null;
    }
  }

  Future<void> refreshSubscription() async {
    await _loadActiveSubscription();
  }

  Future<void> _saveUserToStorage() async {
    if (_user == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(_user!.toJson());
      await prefs.setString(AppConfig.userDataKey, userJson);
      debugPrint('User saved to storage: ${_user!.email}');
    } catch (e) {
      debugPrint('Error saving user to storage: $e');
    }
  }

  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJsonString = prefs.getString(AppConfig.userDataKey);

      if (userJsonString != null && userJsonString.isNotEmpty) {
        try {
          final userJson = jsonDecode(userJsonString) as Map<String, dynamic>;
          _user = UserModel.fromJson(userJson);
          debugPrint('User loaded from storage: ${_user!.email}');

          // Also check if we have a token
          final token = prefs.getString(AppConfig.authTokenKey);
          if (token != null && token.isNotEmpty) {
            // User is persisted and should stay logged in
            debugPrint('Auth token found, user will remain logged in');
          } else {
            // No token, but user data exists - might be stale
            debugPrint('Warning: User data found but no auth token');
          }
        } catch (e) {
          debugPrint('Error parsing user JSON from storage: $e');
          // If parsing fails, clear corrupted data
          await prefs.remove(AppConfig.userDataKey);
          _user = null;
        }
      }
    } catch (e) {
      debugPrint('Error loading user from storage: $e');
      // Ignore storage errors, user will be null
    }
  }

  Future<void> _clearUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConfig.userDataKey);
      debugPrint('User data cleared from storage');
    } catch (e) {
      debugPrint('Error clearing user from storage: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
