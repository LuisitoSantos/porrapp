import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'core/services/local_storage_service.dart';
import 'features/home/screens/home_screen.dart';
import 'features/onboarding/screens/username_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/supabase/supabase_client.dart';
import 'features/onboarding/screens/login_screen.dart';

void main()async  {
   WidgetsFlutterBinding.ensureInitialized();

   await Supabase.initialize(
    url: 'https://uvedlhugldwucnqrnbaf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV2ZWRsaHVnbGR3dWNucXJuYmFmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA5MzQ0NDEsImV4cCI6MjA5NjUxMDQ0MX0.m5_x2OE2tw0SnIqVbqHqsoU2Jx3NOoYW065-f2kkbbM',
  );

  runApp(const PorrApp());
}

class PorrApp extends StatelessWidget {
  const PorrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StartupScreen(),
    );
  }
}

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() =>
      _StartupScreenState();
}

class _StartupScreenState
    extends State<StartupScreen> {

  final storage =
      LocalStorageService();

  String? username;
  String? email;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {

    final savedUsername =
        await storage.getUsername();

    final savedEmail =
        await storage.getUserId();

    if (!mounted) return;

    setState(() {
      username = savedUsername;
      email = savedEmail;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (
      username == null ||
      email == null
    ) {

      return LoginScreen(
        onRegister: registerUser,
        onLogin: loginUser,
      );
    }

    return HomeScreen(
      username: username!,
      user_id: email!,
    );
  }

  Future<void> registerUser(
    String email,
    String username,
  ) async {

    if (email.trim().isEmpty) {
      showError(
        'Introduce un email',
      );
      return;
    }

    if (!email.contains('@')) {
      showError(
        'Email no válido',
      );
      return;
    }

    final existing =
        await supabase
            .from('profiles')
            .select()
            .eq(
              'user_id',
              email,
            )
            .maybeSingle();

    if (existing != null) {
      showError(
        'Ese email ya existe',
      );
      return;
    }

    if (username.trim().isEmpty) {
      showError(
        'Introduce un nombre de usuario',
      );
      return;
    }

    await supabase
        .from('profiles')
        .insert({
      'user_id': email,
      'username': username,
    });

    await storage.saveUser(
      id: email,
      username: username,
    );

    if (!mounted) return;

    setState(() {
      this.email = email;
      this.username = username;
    });
  }

  Future<void> loginUser(
    String email,
  ) async {

    final profile =
        await supabase
            .from('profiles')
            .select()
            .eq(
              'user_id',
              email,
            )
            .maybeSingle();

    if (profile == null) {
      showError(
        'Usuario no encontrado',
      );
      return;
    }

    await storage.saveUser(
      id: email,
      username:
          profile['username'],
    );

    if (!mounted) return;

    setState(() {
      this.email = email;
      username =
          profile['username'];
    });
  }

  void showError(
  String message,
) {
  ScaffoldMessenger.of(context)
      .showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}
}