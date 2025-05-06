import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:labtrack_mobile/repository/reagent_repository.dart';
import 'package:labtrack_mobile/models/reagent_model.dart';

class HomeScreen extends StatelessWidget {
  final ReagentRepository _repository = ReagentRepository();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Reagent>>(
        stream: _repository.getReagentsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reagents = snapshot.data!;

          return ListView.builder(
            itemCount: reagents.length,
            itemBuilder: (context, index) {
              final reagent = reagents[index];
              return ListTile(
                title: Text(reagent.name),
                subtitle: Text('Validade: ${DateFormat('dd/MM/yyyy').format(reagent.expiry)}'),
                trailing: Text(reagent.quantity),
              );
            },
          );
        },
      ),
    );
  }
}