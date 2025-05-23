import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:labtrack_mobile/models/reagent_model.dart';
import 'package:labtrack_mobile/services/auth_service.dart';
import 'package:labtrack_mobile/utils/api_config.dart';

class ReagentScannedScreen extends StatefulWidget {
  final String itemId;

  const ReagentScannedScreen({super.key, required this.itemId});

  @override
  State<ReagentScannedScreen> createState() => _ReagentScannedScreenState();
}

class _ReagentScannedScreenState extends State<ReagentScannedScreen> {
  late Future<Reagent> _reagentFuture;
  final AuthService _authService = AuthService();
  final TextEditingController _quantityController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _reagentFuture = _fetchReagentDetails();
  }

  Future<Reagent> _fetchReagentDetails() async {
    final accessToken = await _authService.getAccessToken();
    if (accessToken == null) throw Exception('Não autenticado');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/inventario/${widget.itemId}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);
      return Reagent.fromJson(data);
    } else if (response.statusCode == 401) {
      final newToken = await _authService.refreshToken();
      if (newToken != null) {
        return _fetchReagentDetails(); // Tentar novamente
      }
      throw Exception('Sessão expirada');
    } else {
      throw Exception('Falha ao carregar detalhes do reagente');
    }
  }

  Future<void> _updateQuantity() async {
    if (_quantityController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) throw Exception('Não autenticado');

      final newQuantity = int.parse(_quantityController.text);
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/inventario/${widget.itemId}/quantidade/$newQuantity'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quantidade atualizada com sucesso!')),
        );
        setState(() {
          _reagentFuture = _fetchReagentDetails();
        });
      } else if (response.statusCode == 401) {
        final newToken = await _authService.refreshToken();
        if (newToken != null) {
          await _updateQuantity(); // Tentar novamente
          return;
        }
        throw Exception('Sessão expirada');
      } else {
        throw Exception('Falha ao atualizar quantidade');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Reagente'),
      ),
      body: FutureBuilder<Reagent>(
        future: _reagentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final reagent = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem('Código do Item', reagent.codigoItem),
                _buildDetailItem('Descrição', reagent.descricao ?? 'Não informado'),
                _buildDetailItem('Fornecedor', reagent.fornecedor ?? 'Não informado'),
                _buildDetailItem('Quantidade Atual', reagent.quantidade.toString()),
                _buildDetailItem('Unidade de Medida', reagent.unidade.toString()),
                _buildDetailItem('Condições de Armazenamento', reagent.condicoesArmazenamento),
                _buildDetailItem('Localidade', reagent.locLaboratorio),
                _buildDetailItem('Classificaçao de Risco', reagent.classificacaoRisco.toString()),
                _buildDetailItem('Data Vencimento', reagent.dataVencimento.toString()),
                
                const SizedBox(height: 20),
                const Text(
                  'Alterar Quantidade:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Nova quantidade',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _updateQuantity,
                            child: const Text('Atualizar'),
                          ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18),
          ),
          const Divider(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }
}