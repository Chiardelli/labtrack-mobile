import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:labtrack_mobile/models/reagent_model.dart';

class TransportModel {
  final String codigoTransporte;
  final String? qrCodeImageUrl;
  final UserTransport usuarioEnviado;
  final UserTransport? usuarioRecebido;
  final DateTime? dataRecebimento;
  final DateTime dataSaida;
  final String statusTransporte;
  final List<Reagent> itens;

  TransportModel({
    required this.codigoTransporte,
    this.qrCodeImageUrl,
    required this.usuarioEnviado,
    this.usuarioRecebido,
    this.dataRecebimento,
    required this.dataSaida,
    required this.statusTransporte,
    required this.itens,
  });

  factory TransportModel.fromJson(Map<String, dynamic> json) {
    return TransportModel(
      codigoTransporte: json['codigoTransporte'],
      qrCodeImageUrl: json['qrCodeImageUrl'] != null
          ? json['qrCodeImageUrl'].toString()
          : null,
      usuarioEnviado: UserTransport.fromJson(json['usuarioEnviado']),
      usuarioRecebido: json['usuarioRecebido'] != null 
          ? UserTransport.fromJson(json['usuarioRecebido'])
          : null,
      dataRecebimento: json['dataRecebimento'] != null
          ? DateTime.parse(json['dataRecebimento'])
          : null,
      dataSaida: DateTime.parse(json['dataSaida']),
      statusTransporte: json['statusTransporte'],
      itens: List<Reagent>.from(
          json['itens'].map((x) => Reagent.fromJson(x))),
    );
  }

  String get dataSaidaFormatada {
    return DateFormat('dd/MM/yyyy HH:mm').format(dataSaida);
  }

  String? get dataRecebimentoFormatada {
    return dataRecebimento != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(dataRecebimento!)
        : null;
  }

  Color get statusColor {
    switch (statusTransporte.toUpperCase()) {
      case 'PENDENTE':
        return Colors.orange;
      case 'ENVIADO':
      case 'EM_TRANSPORTE':
        return Colors.blue;
      case 'ENTREGUE':
        return Colors.green;
      case 'CANCELADO':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class UserTransport {
  final String id;
  final String nome;
  final String email;
  final DateTime contaCriada;

  UserTransport({
    required this.id,
    required this.nome,
    required this.email,
    required this.contaCriada,
  });

  factory UserTransport.fromJson(Map<String, dynamic> json) {
    return UserTransport(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      contaCriada: DateTime.parse(json['contaCriada']),
    );
  }

  String get contaCriadaFormatada {
    return DateFormat('dd/MM/yyyy').format(contaCriada);
  }
}