import 'package:flutter/material.dart';
import 'package:labtrack_mobile/screens/home_screen.dart';
import 'package:labtrack_mobile/screens/qr_scan_screen.dart';

class AppRoutes {
  // Nomes das rotas
  static const String home = '/';
  static const String qrScanner = '/qr-scanner';
  static const String equipmentDetails = '/equipment-details';

  // Mapeamento de rotas
  static final Map<String, WidgetBuilder> routes = {
    home: (context) => HomeScreen(),
    qrScanner: (context) => const QrScanScreen(),
    //equipmentDetails: (context) => const EquipmentDetailsScreen(),
  };
}