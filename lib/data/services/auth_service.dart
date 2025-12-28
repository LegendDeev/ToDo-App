import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';

  static User? _currentUser;

  // Get current user
  static User? get currentUser => _currentUser;

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey);
    final userEmail = prefs.getString(_userEmailKey);

    if (userId != null && userEmail != null) {
      // Verify user still exists in database
      final user = await DatabaseService.getUserById(userId);
      if (user != null) {
        _currentUser = user;
        return true;
      } else {
        // User not found in database, clear local storage
        await logout();
      }
    }
    return false;
  }

  // Login user
  static Future<AuthResult> login(String email, String password) async {
    try {
      final user = await DatabaseService.loginUser(email, password);
      if (user != null) {
        _currentUser = user;
        await _saveUserLocally(user);
        return AuthResult(success: true, user: user);
      } else {
        return AuthResult(success: false, error: 'Invalid email or password');
      }
    } catch (e) {
      return AuthResult(success: false, error: 'Login failed: ${e.toString()}');
    }
  }

  // Register new user
  static Future<AuthResult> register(String email, String password) async {
    try {
      // Check if user already exists
      final existingUser = await DatabaseService.getUserByEmail(email);
      if (existingUser != null) {
        return AuthResult(
            success: false, error: 'User with this email already exists');
      }

      final user = await DatabaseService.createUser(email, password);
      if (user != null) {
        _currentUser = user;
        await _saveUserLocally(user);
        return AuthResult(success: true, user: user);
      } else {
        return AuthResult(
            success: false, error: 'Failed to create user account');
      }
    } catch (e) {
      return AuthResult(
          success: false, error: 'Registration failed: ${e.toString()}');
    }
  }

  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    _currentUser = null;
  }

  // Save user data locally
  static Future<void> _saveUserLocally(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, user.id!.toHexString());
    await prefs.setString(_userEmailKey, user.email);
  }
}

class AuthResult {
  final bool success;
  final User? user;
  final String? error;

  AuthResult({
    required this.success,
    this.user,
    this.error,
  });
}
