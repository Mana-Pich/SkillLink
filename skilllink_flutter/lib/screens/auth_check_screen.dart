import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';
import 'provider_dashboard.dart';
import 'welcome_screen.dart';

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() =>
      _AuthCheckScreenState();
}

class _AuthCheckScreenState
    extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();

    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final isLoggedIn =
        await AuthService.isLoggedIn();

    if (!mounted) return;

    if (!isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const WelcomeScreen(),
        ),
      );

      return;
    }

    final role =
        await AuthService.getUserRole();

    if (!mounted) return;

    if (role == 'provider') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const ProviderDashboard(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const HomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor:
          Color(0xFF0F172A),

      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF60A5FA),
        ),
      ),
    );
  }
}