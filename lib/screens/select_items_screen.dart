import 'package:flutter/material.dart';
import 'package:labtrack_mobile/models/reagent_model.dart';
import 'package:labtrack_mobile/repository/reagent_repository.dart';

class SelectItemsScreen extends StatefulWidget {
  const SelectItemsScreen({Key? key}) : super(key: key);

  @override
  State<SelectItemsScreen> createState() => _SelectItemsScreenState();
}

class _SelectItemsScreenState extends State<SelectItemsScreen> {
  final ReagentRepository _repository = ReagentRepository();
  late Future<List<Reagent>> _reagentsFuture;
  final List<Reagent> _selectedItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReagents();
  }

  Future<void> _loadReagents() async {
    setState(() => _isLoading = true);
    try {
      final reagents = await _repository.getReagents();
      setState(() {
        _reagentsFuture = Future.value(reagents);
      });
    } catch (e) {
      setState(() {
        _reagentsFuture = Future.error(e);
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleItemSelection(Reagent reagent) {
    setState(() {
      if (_selectedItems.contains(reagent)) {
        _selectedItems.remove(reagent);
      } else {
        _selectedItems.add(reagent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Itens para Transporte'),
        actions: [
          if (_selectedItems.isNotEmpty)
            TextButton(
              onPressed: () => Navigator.pop(context, _selectedItems),
              child: const Text(
                'Confirmar',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Reagent>>(
              future: _reagentsFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final reagent = snapshot.data![index];
                    return CheckboxListTile(
                      title: Text(reagent.descricao),
                      subtitle: Text('Quantidade: ${reagent.quantidadeFormatada}'),
                      value: _selectedItems.contains(reagent),
                      onChanged: (_) => _toggleItemSelection(reagent),
                      secondary: Icon(
                        Icons.science,
                        color: reagent.riscoColor,
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}