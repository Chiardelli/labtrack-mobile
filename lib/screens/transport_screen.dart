import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:labtrack_mobile/models/reagent_model.dart';
import 'package:labtrack_mobile/models/transport_model.dart';
import 'package:labtrack_mobile/repository/transport_repository.dart';
import 'package:labtrack_mobile/screens/select_items_screen.dart';
import 'package:labtrack_mobile/screens/transport_details_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TransportScreen extends StatefulWidget {
  const TransportScreen({Key? key}) : super(key: key);

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  final TransportRepository _repository = TransportRepository();
  late Future<List<TransportModel>> _transportsFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTransports();
  }

  Future<void> _loadTransports() async {
    setState(() => _isLoading = true);
    try {
      final transports = await _repository.getUserTransports();
      setState(() {
        _transportsFuture = Future.value(transports);
      });
    } catch (e) {
      setState(() {
        _transportsFuture = Future.error(e);
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshData() async {
    await _loadTransports();
  }

  void _startNewTransport(BuildContext context) async {
    final selectedItems = await Navigator.push<List<Reagent>>(
      context,
      MaterialPageRoute(builder: (context) => const SelectItemsScreen()),
    );

    if (selectedItems != null && selectedItems.isNotEmpty) {
      _createTransportWithItems(context, selectedItems);
    }
  }

  Future<void> _createTransportWithItems(
      BuildContext context, List<Reagent> reagents) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final transportCode = await _repository.createTransport(reagents);
      final qrData = await _repository.getTransportQRCode(transportCode);
      
      Navigator.pop(context); // Fecha o loading
      _showTransportQRDialog(context, transportCode, qrData);
      await _loadTransports(); // Atualiza a lista de transportes
    } catch (e) {
      Navigator.pop(context); // Fecha o loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar transporte: $e')),
      );
    }
  }

  void _showTransportQRDialog(
    BuildContext context, String transportCode, String qrData) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Transporte #${transportCode.substring(0, 8)}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200,
                errorStateBuilder: (cxt, err) {
                  return Column(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 50),
                      Text('Erro: $err', textAlign: TextAlign.center),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Escaneie este QR Code para confirmar a entrega',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              qrData,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: qrData));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Link copiado!')),
            );
          },
          child: const Text('Copiar Link'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    ),
  );
}

  Future<void> _showTransportDetails(
      BuildContext context, String transportCode) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransportDetailsScreen(
          transportCode: transportCode,
        ),
      ),
    );
    await _loadTransports(); // Atualiza a lista após possíveis alterações
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Transportes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: FutureBuilder<List<TransportModel>>(
                future: _transportsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Erro ao carregar transportes'),
                          ElevatedButton(
                            onPressed: _refreshData,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Nenhum transporte encontrado'));
                  }

                  final transports = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: transports.length,
                    itemBuilder: (context, index) {
                      final transport = transports[index];
                      return _buildTransportCard(transport);
                    },
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startNewTransport(context),
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFF0061A8),
      ),
    );
  }

  Widget _buildTransportCard(TransportModel transport) {
  return Card(
    margin: const EdgeInsets.only(bottom: 16),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: ExpansionTile(
      leading: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: transport.statusColor,
          shape: BoxShape.circle,
        ),
      ),
      title: Text(
        'Transporte #${transport.codigoTransporte.substring(0, 8)}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status: ${_formatStatus(transport.statusTransporte)}'),
          Text('Enviado em: ${transport.dataSaidaFormatada}'),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserInfo('Enviado por:', transport.usuarioEnviado),
              if (transport.usuarioRecebido != null)
                _buildUserInfo('Recebido por:', transport.usuarioRecebido!),
              if (transport.dataRecebimento != null)
                _buildDetailItem(
                  'Recebido em:', 
                  transport.dataRecebimentoFormatada!,
                ),
              const SizedBox(height: 16),
              const Text(
                'Itens Transportados:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ...transport.itens.map((item) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_right, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.descricao,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${item.quantidadeFormatada} • ${_formatStatus(item.classificacaoRisco.toString().split('.').last)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).toList(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _generateTransportQRCode(
                    context, 
                    transport.codigoTransporte,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0061A8),
                  ),
                  child: const Text('Gerar QR Code'),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Future<void> _generateTransportQRCode(
    BuildContext context, String transportCode) async {
  try {
    final qrData = await _repository.getTransportQRCode(transportCode);
    _showTransportQRDialog(context, transportCode, qrData);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao gerar QR Code: $e')),
    );
  }
}

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(String label, UserTransport user) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.nome,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDENTE':
        return 'Pendente';
      case 'ENVIADO':
        return 'Enviado';
      case 'EM_TRANSPORTE':
        return 'Em Transporte';
      case 'ENTREGUE':
        return 'Entregue';
      case 'CANCELADO':
        return 'Cancelado';
      case 'SEGURO':
        return 'Seguro';
      case 'ATENCAO':
        return 'Atenção';
      case 'PERIGO':
        return 'Perigo';
      default:
        return status;
    }
  }
}