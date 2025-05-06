import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:labtrack_mobile/models/reagent_model.dart';

class ReagentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream que emite lista atualizada de reagentes
  Stream<List<Reagent>> getReagentsStream() {
    return _firestore
        .collection('reagents')
        .orderBy('expiry') // Ordena por validade
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Reagent.fromFirestore(doc))
            .toList());
  }

  // Adiciona novo reagente
  Future<void> addReagent(Reagent reagent) async {
    await _firestore.collection('reagents').add(reagent.toMap());
  }

  // Atualiza reagente existente
  Future<void> updateReagent(Reagent reagent) async {
    await _firestore
        .collection('reagents')
        .doc(reagent.id)
        .update(reagent.toMap());
  }

  // Remove reagente
  Future<void> deleteReagent(String reagentId) async {
    await _firestore.collection('reagents').doc(reagentId).delete();
  }
}