import 'package:flutter/material.dart';
import 'package:porrapp/core/services/local_storage_service.dart';
import 'home_screen.dart';
import '../../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {

    await Future.delayed(
      const Duration(seconds: 1),
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const StartupScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/porrapp_logo.png',
          width: 280,
        ),
      ),
    );
  }
}