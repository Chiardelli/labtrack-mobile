import 'package:flutter/material.dart';
import 'package:labtrack_mobile/models/reagent_model.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class ReagentDetailsScreen extends StatelessWidget {
  final Reagent reagent;

  const ReagentDetailsScreen({super.key, required this.reagent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Reagente'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: reagent.riscoColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.science,
                          color: reagent.riscoColor,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reagent.descricao,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            if (reagent.dataVencimento != null && 
                                reagent.dataVencimento!.isBefore(DateTime.now()))
                              Text(
                                'VENCIDO',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildDetailItem('Fornecedor', reagent.fornecedor, icon: Icons.business),
                          _buildDetailItem('Tipo', reagent.tipoItem.toString().split('.').last, icon: Icons.category),
                          _buildDetailItem('Quantidade', reagent.quantidadeFormatada, icon: Icons.scale),
                          _buildDetailItem(
                            'Classificação de Risco', 
                            reagent.classificacaoRisco.toString().split('.').last,
                            icon: Icons.warning,
                            color: reagent.riscoColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildDetailItem('Local no Laboratório', reagent.locLaboratorio, icon: Icons.location_on),
                          _buildDetailItem(
                            'Condições de Armazenamento', 
                            reagent.condicoesArmazenamento,
                            icon: Icons.storage,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildDetailItem(
                            'Data de Fabricação', 
                            DateFormat('dd/MM/yyyy').format(reagent.dataFabricacao),
                            icon: Icons.date_range,
                          ),
                          if (reagent.dataVencimento != null)
                            _buildDetailItem(
                              'Data de Vencimento', 
                              DateFormat('dd/MM/yyyy').format(reagent.dataVencimento!),
                              icon: Icons.event_busy,
                              isExpired: reagent.dataVencimento!.isBefore(DateTime.now()),
                            ),
                          _buildDetailItem(
                            'Data de Registro', 
                            DateFormat('dd/MM/yyyy').format(reagent.dataRegistro),
                            icon: Icons.event_available,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.inventory_2, size: 20),
              label: const Text('Gerar QR Code para Baixa'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _showInventoryQR(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {
    IconData? icon,
    Color? color,
    bool isExpired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: isExpired ? Colors.red : color ?? Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInventoryQR(BuildContext context) {
    final inventoryData = {
      'type': 'inventory',
      'reagentId': reagent.codigoItem,
      'description': reagent.descricao,
      'currentQuantity': reagent.quantidade,
      'unit': reagent.unidade.name,
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code para Baixa no Estoque'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: jsonEncode(inventoryData),
              version: QrVersions.auto,
              size: 200,
            ),
            const SizedBox(height: 16),
            Text(
              reagent.descricao,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${reagent.quantidade} ${reagent.unidade.name}',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonEncode(inventoryData)));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dados copiados para a área de transferência')),
              );
            },
            child: const Text('Copiar Dados'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}