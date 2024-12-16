// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Ensure this file is generated via Firebase CLI
import 'screens/home_screen.dart';
import 'screens/galley_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/chat_screen.dart';
import 'services/chat_service.dart';
import 'screens/checkout_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/sign_in_screen.dart';
import 'services/auth.service.dart';
import 'services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<FirestoreService>(
    create: (_) => FirestoreService(),
  ),
  Provider<ChatService>(
    create: (_) => ChatService(),
  ),
        // Add other providers here (e.g., FirestoreService, StorageService)
      ],
      child: MaterialApp(
        title: 'Virtual Marketplace',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => AuthenticationWrapper(),
          '/home': (context) => const HomeScreen(),
          '/gallery': (context) => const GalleryScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/chat': (context) => const ChatScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}

// Wrapper to handle authentication state
class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          return user == null ? const SignInScreen() : const HomeScreen();
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}