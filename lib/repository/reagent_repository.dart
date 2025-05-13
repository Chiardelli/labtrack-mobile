import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:labtrack_mobile/models/reagent_model.dart';
import 'package:labtrack_mobile/services/auth_service.dart';
import 'package:labtrack_mobile/utils/api_config.dart';

class ReagentRepository {
  final AuthService _authService = AuthService();

  Future<List<Reagent>> getReagents({String? searchQuery}) async {
    final accessToken = await _authService.getAccessToken();
    if (accessToken == null) throw Exception('Não autenticado');

    final url = searchQuery != null
        ? '${ApiConfig.baseUrl}/inventario?search=$searchQuery'
        : '${ApiConfig.baseUrl}/inventario';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Reagent.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      // Token expirado, tentar refresh
      final newToken = await _authService.refreshToken();
      if (newToken != null) {
        return getReagents(searchQuery: searchQuery); // Tentar novamente
      }
      throw Exception('Sessão expirada');
    } else {
      throw Exception('Falha ao carregar reagentes');
    }
  }

  Future<List<Reagent>> searchReagents(String query) async {
    return getReagents(searchQuery: query);
  }
}