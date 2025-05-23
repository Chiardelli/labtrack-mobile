import 'package:flutter/material.dart';
import 'package:labtrack_mobile/screens/home_screen.dart';
import 'package:labtrack_mobile/screens/qr_scan_screen.dart';
import 'package:labtrack_mobile/screens/transport_screen.dart';
import 'package:labtrack_mobile/screens/reagent_scanned_screen.dart';

class AppRoutes {
  // Nomes das rotas
  static const String home = '/';
  static const String qrScanner = '/qr-scanner';
  static const String transport = '/transport';
  static const String reagentScanned = '/reagent-scanned';

  // Mapeamento de rotas
  static Map<String, WidgetBuilder> get routes => {
    home: (context) => HomeScreen(),
    qrScanner: (context) => const QrScanScreen(),
    transport: (context) => const TransportScreen(),
    reagentScanned: (context) {
      final itemId = ModalRoute.of(context)!.settings.arguments as String;
      return ReagentScannedScreen(itemId: itemId);
    },
  };

  // Função para lidar com deep links
  static void handleDeepLink(Uri uri, GlobalKey<NavigatorState> navigatorKey) {
    if (uri.pathSegments.contains('reagent')) {
      final itemId = uri.pathSegments.last;
      if (itemId.isNotEmpty) {
        navigatorKey.currentState?.pushNamed(
          reagentScanned,
          arguments: itemId,
        );
      }
    }
  }
}