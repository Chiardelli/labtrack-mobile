import 'package:flutter/material.dart';
import 'package:labtrack_mobile/screens/home_screen.dart';
import 'package:labtrack_mobile/screens/qr_scan_screen.dart';
import 'package:labtrack_mobile/screens/transport_details_screen.dart';
import 'package:labtrack_mobile/screens/transport_screen.dart';

class AppRoutes {
  // Nomes das rotas
  static const String home = '/';
  static const String qrScanner = '/qr-scanner';
  static const String transport = '/transport';
  static const String equipmentDetails = '/equipment-details';
  static const String transportDetails = '/transport-details';

  // Mapeamento de rotas
  static final Map<String, WidgetBuilder> routes = {
    home: (context) => HomeScreen(),
    qrScanner: (context) => const QrScanScreen(),
    transport: (context) => const TransportScreen(),
    // equipmentDetails: (context) => const EquipmentDetailsScreen(),
    transportDetails: (context) => TransportDetailsScreen(
      transportCode: ModalRoute.of(context)!.settings.arguments as String,
    ),
  };
}