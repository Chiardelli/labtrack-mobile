// lib/screens/reagent_details_screen.dart
import 'package:flutter/material.dart';
import 'package:labtrack_mobile/models/reagent_model.dart';
import 'package:intl/intl.dart';

class ReagentDetailsScreen extends StatelessWidget {
  final Reagent reagent;

  const ReagentDetailsScreen({super.key, required this.reagent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Reagente'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('Descrição', reagent.descricao),
            _buildDetailItem('Fornecedor', reagent.fornecedor),
            _buildDetailItem('Tipo', reagent.tipoItem.toString().split('.').last),
            _buildDetailItem('Quantidade', reagent.quantidadeFormatada),
            _buildDetailItem('Local no Laboratório', reagent.locLaboratorio),
            _buildDetailItem(
              'Condições de Armazenamento', 
              reagent.condicoesArmazenamento
            ),
            _buildDetailItem(
              'Classificação de Risco', 
              reagent.classificacaoRisco.toString().split('.').last,
              color: reagent.riscoColor,
            ),
            _buildDetailItem(
              'Data de Fabricação', 
              DateFormat('dd/MM/yyyy').format(reagent.dataFabricacao),
            ),
            if (reagent.dataVencimento != null)
              _buildDetailItem(
                'Data de Vencimento', 
                DateFormat('dd/MM/yyyy').format(reagent.dataVencimento!),
                isExpired: reagent.dataVencimento!.isBefore(DateTime.now()),
              ),
            _buildDetailItem(
              'Data de Registro', 
              DateFormat('dd/MM/yyyy').format(reagent.dataRegistro),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, 
      {Color? color, bool isExpired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: isExpired ? Colors.red : color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}