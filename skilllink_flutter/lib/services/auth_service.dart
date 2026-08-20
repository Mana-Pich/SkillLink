import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // ============================================================
  // STORAGE KEYS
  // ============================================================

  static const String userIdKey = 'user_id';
  static const String userNameKey = 'user_name';
  static const String userEmailKey = 'user_email';
  static const String userRoleKey = 'user_role';

  // ============================================================
  // REGISTER
  // ============================================================

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'role': role,
      }),
    );

    final body = _decodeResponse(response);

    if (response.statusCode == 201) {
      final user = _extractUser(body);

      // Clear any previous account before saving the new one.
      await clearSavedUser();

      await saveUser(user);

      return user;
    }

    _throwApiError(response, body, 'Registration failed.');
  }

  // ============================================================
  // LOGIN
  // ============================================================

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final body = _decodeResponse(response);

    if (response.statusCode == 200) {
      final user = _extractUser(body);

      // IMPORTANT:
      // Remove the previous account first.
      // This prevents Emma/Sarah/etc. from remaining in storage.
      await clearSavedUser();

      // Save the account that JUST logged in.
      await saveUser(user);

      return user;
    }

    _throwApiError(response, body, 'Login failed.');
  }

  // ============================================================
  // SAVE USER
  // ============================================================

  static Future<void> saveUser(
    Map<String, dynamic> user,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // User ID
    final id = user['id'];

    if (id != null) {
      final parsedId = int.tryParse(id.toString());

      if (parsedId != null) {
        await prefs.setInt(
          userIdKey,
          parsedId,
        );
      }
    }

    // User name
    final name = user['name'];

    if (name != null) {
      await prefs.setString(
        userNameKey,
        name.toString(),
      );
    }

    // User email
    final email = user['email'];

    if (email != null) {
      await prefs.setString(
        userEmailKey,
        email.toString(),
      );
    }

    // User role
    final role = user['role'];

    if (role != null) {
      await prefs.setString(
        userRoleKey,
        role.toString().toLowerCase(),
      );
    }
  }

  // ============================================================
  // CHECK LOGIN
  // ============================================================

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getInt(userIdKey) != null;
  }

  // ============================================================
  // GET USER ID
  // ============================================================

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getInt(userIdKey);
  }

  // ============================================================
  // GET USER NAME
  // ============================================================

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(userNameKey);
  }

  // ============================================================
  // GET USER EMAIL
  // ============================================================

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(userEmailKey);
  }

  // ============================================================
  // GET USER ROLE
  // ============================================================

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(userRoleKey);
  }

  // ============================================================
  // GET SAVED USER
  // ============================================================

  static Future<Map<String, dynamic>?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getInt(userIdKey);

    if (userId == null) {
      return null;
    }

    return {
      'id': userId,
      'name': prefs.getString(userNameKey),
      'email': prefs.getString(userEmailKey),
      'role': prefs.getString(userRoleKey),
    };
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  static Future<void> logout() async {
    await clearSavedUser();
  }

  // ============================================================
  // CLEAR SAVED USER
  // ============================================================

  static Future<void> clearSavedUser() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(userIdKey);
    await prefs.remove(userNameKey);
    await prefs.remove(userEmailKey);
    await prefs.remove(userRoleKey);
  }

  // ============================================================
  // EXTRACT USER FROM API RESPONSE
  // ============================================================

  static Map<String, dynamic> _extractUser(
    Map<String, dynamic> body,
  ) {
    dynamic user;

    // Expected response:
    //
    // {
    //   "success": true,
    //   "data": {
    //      "user": {...}
    //   }
    // }

    if (body['data'] is Map) {
      final data = body['data'];

      if (data['user'] is Map) {
        user = data['user'];
      }
    }

    // Also support:
    //
    // {
    //   "user": {...}
    // }

    if (user == null && body['user'] is Map) {
      user = body['user'];
    }

    if (user is Map) {
      return Map<String, dynamic>.from(user);
    }

    throw Exception(
      'The server did not return valid user information.',
    );
  }

  // ============================================================
  // DECODE RESPONSE
  // ============================================================

  static Map<String, dynamic> _decodeResponse(
    http.Response response,
  ) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {};
    } catch (_) {
      return {};
    }
  }

  // ============================================================
  // API ERROR
  // ============================================================

  static Never _throwApiError(
    http.Response response,
    Map<String, dynamic> body,
    String defaultMessage,
  ) {
    if (response.statusCode == 422) {
      final errors = body['errors'];

      if (errors is Map && errors.isNotEmpty) {
        final firstError = errors.values.first;

        if (firstError is List &&
            firstError.isNotEmpty) {
          throw Exception(
            firstError.first.toString(),
          );
        }
      }
    }

    throw Exception(
      body['message']?.toString() ?? defaultMessage,
    );
  }
}