// lib/models/reagent_model.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum ClassificacaoRisco { SEGURO, ATENCAO, PERIGO }
enum TipoItem { ACIDO, BASE, SOLVENTE, INDICADOR, SAL_INORGANICO, OUTRO }
enum Unidade { mL, L, g, kg, mg }

class Reagent {
  final String id;
  final String descricao;
  final String fornecedor;
  final TipoItem tipoItem;
  final double quantidade;
  final Unidade unidade;
  final String locLaboratorio;
  final String condicoesArmazenamento;
  final ClassificacaoRisco classificacaoRisco;
  final DateTime dataFabricacao;
  final DateTime? dataVencimento;
  final DateTime dataRegistro;

  Reagent({
    required this.id,
    required this.descricao,
    required this.fornecedor,
    required this.tipoItem,
    required this.quantidade,
    required this.unidade,
    required this.locLaboratorio,
    required this.condicoesArmazenamento,
    required this.classificacaoRisco,
    required this.dataFabricacao,
    this.dataVencimento,
    required this.dataRegistro,
  });

  factory Reagent.fromJson(Map<String, dynamic> json) {
    return Reagent(
      id: json['id']?.toString() ?? '',
      descricao: json['descricao']?.toString() ?? 'Sem descrição',
      fornecedor: json['fornecedor']?.toString() ?? 'Fornecedor não informado',
      tipoItem: TipoItem.values.firstWhere(
        (e) => e.toString().split('.').last == json['tipoItem']?.toString(),
        orElse: () => TipoItem.OUTRO,
      ),
      quantidade: (json['quantidade'] as num?)?.toDouble() ?? 0.0,
      unidade: Unidade.values.firstWhere(
        (e) => e.toString().split('.').last == json['unidade']?.toString(),
        orElse: () => Unidade.mL,
      ),
      locLaboratorio: json['locLaboratorio']?.toString() ?? 'Local não informado',
      condicoesArmazenamento: json['condicoesArmazenamento']?.toString() ?? 'Condições não informadas',
      classificacaoRisco: ClassificacaoRisco.values.firstWhere(
        (e) => e.toString().split('.').last == json['classificacaoRisco']?.toString(),
        orElse: () => ClassificacaoRisco.SEGURO,
      ),
      dataFabricacao: json['dataFabricacao'] != null
          ? DateTime.parse(json['dataFabricacao'])
          : DateTime.now(),
      dataVencimento: json['dataVencimento'] != null
          ? DateTime.parse(json['dataVencimento'])
          : null,
      dataRegistro: json['dataRegistro'] != null
          ? DateTime.parse(json['dataRegistro'])
          : DateTime.now(),
    );
  }

  String get quantidadeFormatada {
    return '${quantidade.toStringAsFixed(2)} ${unidade.name}';
  }

  String get dataFabricacaoFormatada {
    return DateFormat('dd/MM/yyyy').format(dataFabricacao);
  }

  String? get dataVencimentoFormatada {
    return dataVencimento != null
        ? DateFormat('dd/MM/yyyy').format(dataVencimento!)
        : null;
  }

  Color get riscoColor {
    switch (classificacaoRisco) {
      case ClassificacaoRisco.SEGURO:
        return Colors.green;
      case ClassificacaoRisco.ATENCAO:
        return Colors.orange;
      case ClassificacaoRisco.PERIGO:
        return Colors.red;
    }
  }
}