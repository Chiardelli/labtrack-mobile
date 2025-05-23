import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:labtrack_mobile/screens/home_screen.dart';
import 'package:labtrack_mobile/screens/login_screen.dart';
import 'package:labtrack_mobile/screens/reagent_scanned_screen.dart';
import 'package:labtrack_mobile/services/auth_service.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
  
  if (!kIsWeb) {
    _initDeepLinking();
  } else {
    _handleWebInitialUrl();
  }
}

Future<void> _handleWebInitialUrl() async {
  if (!kIsWeb) return;
  
  await Future.delayed(const Duration(seconds: 1)); // Espera o app inicializar
  
  final uri = Uri.base;
  debugPrint("URL inicial na web: ${uri.toString()}");
  
  if (uri.path.endsWith('/reagent-scanned')) {
    final itemId = uri.queryParameters['id'];
    if (itemId != null && itemId.isNotEmpty) {
      navigatorKey.currentState?.pushNamed(
        '/reagent-scanned',
        arguments: itemId,
      );
    }
  }
}

void _initDeepLinking() async {
  try {
    // Para quando o app é aberto por um link
    Uri? initialUri = await getInitialUri();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }

    // Para quando o app já está aberto
    uriLinkStream.listen((Uri? uri) {
      if (uri != null) _handleDeepLink(uri);
    });
  } catch (e) {
    debugPrint("Erro em deep links: $e");
  }
}

void _handleDeepLink(Uri uri) {
  debugPrint("Deep link recebido: ${uri.toString()}");
  
  String? itemId;
  
  // Tenta obter o ID de ambas as formas
  if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'reagent' && uri.pathSegments.length >= 2) {
    itemId = uri.pathSegments[1];
  } else if (uri.queryParameters.containsKey('id')) {
    itemId = uri.queryParameters['id'];
  }

  if (itemId != null && itemId.isNotEmpty) {
    navigatorKey.currentState?.pushNamed(
      '/reagent-scanned',
      arguments: itemId, // Garanta que está passando como String
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LabTrack',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF0061A8),
        ),
      ), // Fechamento CORRETO do theme
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
        '/reagent-scanned': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String;
          return ReagentScannedScreen(itemId: args);
        },
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }
}