// lib/services/api_interceptor.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:labtrack_mobile/services/auth_service.dart';

class ApiInterceptor {
  final AuthService _authService = AuthService();

  Future<http.Response> post(String url, {Map<String, dynamic>? body}) async {
    return _requestWithToken((token) => http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  Future<http.Response> _requestWithToken(
      Future<http.Response> Function(String) request) async {
    final accessToken = await _authService.getAccessToken();
    if (accessToken == null) throw Exception('Not authenticated');

    var response = await request(accessToken);

    if (response.statusCode == 401) {
      final newToken = await _authService.refreshToken();
      if (newToken == null) throw Exception('Session expired');
      response = await request(newToken);
    }

    return response;
  }
}