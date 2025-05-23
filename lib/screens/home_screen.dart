import 'package:flutter/material.dart';
import 'package:labtrack_mobile/models/reagent_model.dart';
import 'package:labtrack_mobile/repository/reagent_repository.dart';
import 'package:labtrack_mobile/screens/reagent_details_screen.dart';
import 'package:labtrack_mobile/screens/reagent_form_screen.dart';
import 'package:labtrack_mobile/screens/qr_scan_screen.dart';
import 'package:intl/intl.dart';
import 'package:labtrack_mobile/screens/transport_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ReagentRepository _reagentRepository = ReagentRepository();
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Reagent>> _reagentsFuture;
  bool _isSearching = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReagents();
  }

  Future<void> _loadReagents({String? query}) async {
    setState(() => _isLoading = true);
    try {
      final reagents = await _reagentRepository.getReagents(searchQuery: query);
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

  void _handleSearch(String query) {
    _loadReagents(query: query);
  }

  Future<void> _refreshData() async {
    await _loadReagents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Buscar reagente...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onSubmitted: _handleSearch,
              )
            : const Text('LabTrack'),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QrScanScreen()),
                );
              },
            ),
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.directions_car),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TransportScreen()),
                );
              },
            ),
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _handleSearch('');
                }
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: FutureBuilder<List<Reagent>>(
                future: _reagentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Erro ao carregar reagentes'),
                          ElevatedButton(
                            onPressed: _refreshData,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Nenhum reagente encontrado'));
                  }

                  final reagents = snapshot.data!;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reagentes em Destaque',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._buildFeaturedReagents(reagents.take(2).toList()),
                        const SizedBox(height: 24),
                        const Text(
                          'Estoque Rápido',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildQuickStockGrid(reagents),
                      ],
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReagentFormScreen()),
          ).then((_) => _refreshData());
        },
        backgroundColor: const Color(0xFF0061A8),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Widget> _buildFeaturedReagents(List<Reagent> reagents) {
    return reagents.map((reagent) {
      final progressValue = reagent.quantidade / 1000;
      
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReagentDetailsScreen(reagent: reagent),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B4B3).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.science,
                        color: Color(0xFF00B4B3),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${reagent.tipoItem.toString().split('.').last} • ${reagent.quantidade} ${reagent.unidade.name}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  reagent.descricao,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                if (reagent.dataVencimento != null)
                  Text(
                    'Validade: ${DateFormat('dd/MM/yyyy').format(reagent.dataVencimento!)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: Colors.grey[200],
                  color: const Color(0xFF0061A8),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(progressValue * 100).toInt()}% do estoque',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReagentDetailsScreen(reagent: reagent),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text(
                        'Detalhes',
                        style: TextStyle(
                          color: Color(0xFF0061A8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildQuickStockGrid(List<Reagent> reagents) {
    final quickStockItems = reagents.length > 4 ? reagents.sublist(0, 4) : reagents;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: quickStockItems.length,
      itemBuilder: (context, index) {
        final reagent = quickStockItems[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReagentDetailsScreen(reagent: reagent),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0061A8).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.science,
                      color: Color(0xFF0061A8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    reagent.descricao,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${reagent.quantidade} ${reagent.unidade.name}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}