import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Escanear Reagente"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 5,
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: const Color(0xFF0061A8),
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 8,
                    cutOutSize: MediaQuery.of(context).size.width * 0.7,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Posicione o QR code do reagente",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_isLoading)
                        const CircularProgressIndicator(
                          color: Color(0xFF0061A8),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

void _onQRViewCreated(QRViewController controller) {
  this.controller = controller;

  controller.scannedDataStream.listen((scanData) async {
    if (!_isLoading) {
      setState(() => _isLoading = true);

      final String? qrCode = scanData.code;

      if (qrCode != null && qrCode.startsWith("reagent:")) {
        final String reagentId = qrCode.split(":")[1];

        // Para a câmera para evitar múltiplos scans
        await controller.pauseCamera();

        // Navegar para a tela de detalhes
        Navigator.pushNamed(
          context,
          '/reagent-scanned',
          arguments: reagentId,
        ).then((_) {
          // Quando voltar, reativa a câmera
          controller.resumeCamera();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("QR Code inválido!"),
            backgroundColor: Color(0xFF0061A8),
          ),
        );
      }

      setState(() => _isLoading = false);
    }
  });
}

}