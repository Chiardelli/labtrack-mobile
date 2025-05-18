import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:labtrack_mobile/models/reagent_model.dart';
import 'package:labtrack_mobile/models/transport_model.dart';
import 'package:labtrack_mobile/services/auth_service.dart';
import 'package:labtrack_mobile/utils/api_config.dart';

class TransportRepository {
  final AuthService _authService = AuthService();

  Future<List<TransportModel>> getUserTransports() async {
    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) throw Exception('Usuário não autenticado');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/transporte'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TransportModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return getUserTransports(); // Tentar novamente com novo token
      } else {
        throw Exception('Falha ao carregar transportes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar transportes: $e');
    }
  }

  Future<String> createTransport(List<Reagent> reagents) async {
    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) throw Exception('Usuário não autenticado');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/transporte'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'itens': reagents.map((r) => {'codigoItem': r.codigoItem}).toList(),
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body)['codigoTransporte'] as String;
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return createTransport(reagents); // Tentar novamente com novo token
      } else {
        throw Exception('Falha ao criar transporte: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao criar transporte: $e');
    }
  }

  String getTransportDeepLink(String transportCode) {
  return 'labtrack://transport/$transportCode';
}

Future<String> getTransportQRCode(String transportCode) async {
  return getTransportDeepLink(transportCode);
}

  Future<TransportModel> getTransport(String transportCode) async {
    final accessToken = await AuthService().getAccessToken();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/transporte/$transportCode'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return TransportModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao carregar transporte');
    }
  }

  Future<void> confirmTransportDelivery(String transportCode) async {
    final accessToken = await AuthService().getAccessToken();
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/transporte/$transportCode'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'statusTransporte': 'ENTREGUE',
        'dataRecebimento': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao confirmar entrega');
    }
  }
}