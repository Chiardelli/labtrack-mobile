  import 'package:flutter/material.dart';
  import 'package:mobile_scanner/mobile_scanner.dart';

  MobileScannerController cameraController = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  class QrScanScreen extends StatelessWidget {
    const QrScanScreen({super.key});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Escanear Reagente"),
          centerTitle: true,
        ),
        body: MobileScanner(
          controller: cameraController,
          onDetect: (barcode, args) {
            final String code = barcode.rawValue ?? '---';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Reagente escaneado: $code"),
                backgroundColor: const Color(0xFF0061A8),
              ),
            );
          },
        ),
      );
    }
  }

 