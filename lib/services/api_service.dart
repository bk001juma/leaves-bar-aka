import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Change this to your machine's IP when running on a physical device
  // e.g. http://192.168.x.x:8000/api
  static const String baseUrl = 'http://10.17.177.209:8000/api';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Auth ──────────────────────────────────────────────

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ── Leaves ────────────────────────────────────────────

  static Future<Map<String, dynamic>> getLeaves() async {
    final response = await http.get(
      Uri.parse('$baseUrl/leaves'),
      headers: await _authHeaders(),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> createLeave({
    required String reason,
    required String startDate,
    required String endDate,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/leaves'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'reason': reason,
        'start_date': startDate,
        'end_date': endDate,
      }),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateLeave(
    int id, {
    String? reason,
    String? startDate,
    String? endDate,
    String? status,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/leaves/$id'),
      headers: await _authHeaders(),
      body: jsonEncode({
        if (reason != null) 'reason': reason,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        if (status != null) 'status': status,
      }),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> deleteLeave(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/leaves/$id'),
      headers: await _authHeaders(),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
