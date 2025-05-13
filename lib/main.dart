// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:labtrack_mobile/screens/home_screen.dart';
import 'package:labtrack_mobile/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LabTrackApp());
}

class LabTrackApp extends StatelessWidget {
  const LabTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LabTrack',
      initialRoute: '/',
      routes: {
        '/': (context) => FutureBuilder(
              future: const FlutterSecureStorage().read(key: 'accessToken'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }
                return snapshot.hasData ? const HomeScreen() : const LoginScreen();
              },
            ),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}