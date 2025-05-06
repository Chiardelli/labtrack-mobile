import 'package:cloud_firestore/cloud_firestore.dart';

class Reagent {
  final String? id; // Nullable para novos registros
  final String name;
  final String batch;
  final String type;
  final String quantity; // Ex: "500 mL"
  final DateTime expiry;
  final String location;
  final String responsible;
  final DateTime createdAt;
  final String status; // "available", "low_stock", "expired"

  Reagent({
    this.id,
    required this.name,
    required this.batch,
    required this.type,
    required this.quantity,
    required this.expiry,
    required this.location,
    required this.responsible,
    required this.createdAt,
    this.status = "available",
  });

  // Converte o modelo para um Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'batch': batch,
      'type': type,
      'quantity': quantity,
      'expiry': expiry,
      'location': location,
      'responsible': responsible,
      'createdAt': createdAt,
      'status': status,
    };
  }

  // Cria um Reagent a partir de um DocumentSnapshot do Firestore
  factory Reagent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Reagent(
      id: doc.id,
      name: data['name'] ?? '',
      batch: data['batch'] ?? '',
      type: data['type'] ?? '',
      quantity: data['quantity'] ?? '',
      expiry: (data['expiry'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      responsible: data['responsible'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'available',
    );
  }

  // Método para atualizar campos específicos
  Reagent copyWith({
    String? name,
    String? batch,
    String? type,
    String? quantity,
    DateTime? expiry,
    String? location,
    String? responsible,
    String? status,
  }) {
    return Reagent(
      id: id,
      name: name ?? this.name,
      batch: batch ?? this.batch,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      expiry: expiry ?? this.expiry,
      location: location ?? this.location,
      responsible: responsible ?? this.responsible,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }

  // Calcula dias até a expiração (para alertas)
  int get daysUntilExpiry {
    return expiry.difference(DateTime.now()).inDays;
  }

  // Extrai o valor numérico da quantidade (ex: "500 mL" → 500)
  double get numericQuantity {
    try {
      return double.parse(quantity.split(' ')[0]);
    } catch (e) {
      return 0.0;
    }
  }

  // Extrai a unidade (ex: "500 mL" → "mL")
  String get quantityUnit {
    try {
      return quantity.split(' ')[1];
    } catch (e) {
      return '';
    }
  }
}