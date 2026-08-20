import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/booking_history_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/provider_dashboard.dart';
import 'screens/provider_bookings_screen.dart';
import 'screens/provider_services_screen.dart';

import 'services/auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const SkillLinkApp(),
  );
}

class SkillLinkApp extends StatelessWidget {
  const SkillLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'SkillLink',

      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B4FE9),
        ),

        scaffoldBackgroundColor:
            const Color(0xFFF3F5F9),
      ),

      home: const AuthGate(),

      routes: {
        '/login': (context) =>
            const LoginScreen(),

        '/register': (context) =>
            const RegisterScreen(),

        '/home': (context) =>
            const HomeScreen(),

        '/bookings': (context) =>
            const BookingHistoryScreen(),

        '/provider': (context) =>
            const ProviderDashboard(),

        '/provider-bookings': (context) =>
            const ProviderBookingsScreen(),

        '/provider-services': (context) =>
            const ProviderServicesScreen(),
      },
    );
  }
}


// ============================================================
// AUTH GATE
// ============================================================

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() =>
      _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool isLoading = true;
  Widget? nextScreen;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    try {
      final loggedIn =
          await AuthService.isLoggedIn();

      if (!loggedIn) {
        nextScreen =
            const LoginScreen();
      } else {
        final role =
            await AuthService.getUserRole();

        if (role == 'provider') {
          nextScreen =
              const ProviderDashboard();
        } else {
          nextScreen =
              const HomeScreen();
        }
      }
    } catch (e) {
      nextScreen =
          const LoginScreen();
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor:
            Color(0xFF171A35),

        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF8F86FF),
          ),
        ),
      );
    }

    return nextScreen ??
        const LoginScreen();
  }
}