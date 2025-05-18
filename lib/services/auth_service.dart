// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:labtrack_mobile/utils/api_config.dart';

class AuthService {
  static const String _baseUrl = '${ApiConfig.baseUrl}/auth'; // Substitua pela sua URL
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/autenticar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'senha': password,
        }),
      );

      if (response.statusCode == 200) {
        final tokenData = jsonDecode(response.body);
        await _saveTokens(tokenData);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/registrar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': name,
          'email': email,
          'senha': password,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        final tokenData = jsonDecode(response.body);
        await _saveTokens(tokenData);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getAccessToken() async {
    final accessToken = await _storage.read(key: 'accessToken');
    if (accessToken != null) {
      return accessToken;
    }
    return null;
  }

    Future<String?> refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refreshToken');
      if (refreshToken == null) return null;

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final tokenData = jsonDecode(response.body);
        await _saveTokens(tokenData);
        return tokenData['accessToken'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
  }

  Future<void> _saveTokens(Map<String, dynamic> tokenData) async {
    await _storage.write(key: 'accessToken', value: tokenData['accessToken']);
    await _storage.write(key: 'refreshToken', value: tokenData['refreshToken']);
  }
}