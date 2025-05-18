import 'package:flutter/material.dart';
import 'package:labtrack_mobile/models/transport_model.dart';
import 'package:labtrack_mobile/repository/transport_repository.dart';

class TransportDetailsScreen extends StatefulWidget {
  final String transportCode;

  const TransportDetailsScreen({super.key, required this.transportCode});

  @override
  State<TransportDetailsScreen> createState() => _TransportDetailsScreenState();
}

class _TransportDetailsScreenState extends State<TransportDetailsScreen> {
  final TransportRepository _repository = TransportRepository();
  late Future<TransportModel> _transportFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTransport();
  }

  Future<void> _loadTransport() async {
    setState(() => _isLoading = true);
    try {
      final transport = await _repository.getTransport(widget.transportCode);
      setState(() {
        _transportFuture = Future.value(transport);
      });
    } catch (e) {
      setState(() {
        _transportFuture = Future.error(e);
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDelivery() async {
    setState(() => _isLoading = true);
    try {
      await _repository.confirmTransportDelivery(widget.transportCode);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrega confirmada com sucesso!')),
      );
      await _loadTransport(); // Recarrega os dados
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao confirmar entrega: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
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
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transporte #${widget.transportCode.substring(0, 8)}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<TransportModel>(
              future: _transportFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final transport = snapshot.data!;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: ${_formatStatus(transport.statusTransporte)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
                      ...transport.itens.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_right, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.descricao,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '${item.quantidadeFormatada} • ${item.classificacaoRisco.toString().split('.').last}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 24),
                      if (transport.statusTransporte == 'ENVIADO')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _confirmDelivery,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0061A8),
                            ),
                            child: const Text('Confirmar Entrega'),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
