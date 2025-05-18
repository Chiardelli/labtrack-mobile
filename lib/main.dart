import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:labtrack_mobile/screens/home_screen.dart';
import 'package:labtrack_mobile/screens/login_screen.dart';
import 'package:labtrack_mobile/screens/transport_details_screen.dart';
import 'package:labtrack_mobile/services/auth_service.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:io' show Platform;

// Chave global para navegação
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configuração de orientação portrait apenas
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inicializa o tratamento de deep links
  initUniLinks();
  
  runApp(const MyApp());
}

Future<void> initUniLinks() async {
  if (!Platform.isAndroid && !Platform.isIOS) {
    debugPrint('uni_links não é suportado nesta plataforma');
    return;
  }

  try {
    final initialUri = await getInitialUri();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }

    uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });
  } catch (e) {
    debugPrint('Erro ao inicializar uni_links: $e');
  }
}


void _handleDeepLink(Uri uri) {
  if (uri.scheme == 'labtrack' && uri.host == 'transport') {
    final transportCode = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
    
    if (transportCode.isNotEmpty) {
      // Navega para a tela de detalhes do transporte
      navigatorKey.currentState?.pushNamed(
        '/transport-details',
        arguments: transportCode,
      );
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LabTrack',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF0061A8),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      navigatorKey: navigatorKey,
      initialRoute: '/',
      routes: {
        '/': (context) => FutureBuilder<bool>(
              future: AuthService().isLoggedIn(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return snapshot.data == true 
                    ? const HomeScreen() 
                    : const LoginScreen();
              },
            ),
        '/transport-details': (context) => TransportDetailsScreen(
              transportCode: ModalRoute.of(context)!.settings.arguments as String,
            ),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }
}