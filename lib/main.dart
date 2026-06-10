import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'core/services/local_storage_service.dart';
import 'features/home/screens/home_screen.dart';
import 'features/onboarding/screens/username_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/supabase/supabase_client.dart';

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
      home: StartupScreen(),
    );
  }
}

class StartupScreen
    extends StatefulWidget {
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
  String? userId;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final savedUsername =
        await storage.getUsername();

    final savedUserId =
        await storage.getUserId();

    setState(() {
      username = savedUsername;
      userId = savedUserId;
    });
  }

  Future<void> login() async {
  if (
    supabase.auth.currentUser ==
        null
  ) {
    await supabase.auth
        .signInAnonymously();
  }
}

  @override
  Widget build(BuildContext context) {
    if (username == null) {
      return UsernameScreen(
        onContinue: (name) async {
          await login();
          await supabase
            .from('profiles')
            .insert({
              'user_id':
                  supabase.auth.currentUser!.id,
              'username': name,
            });

          const uuid = Uuid();

        final generatedUserId = uuid.v4();

        await storage.saveUser(
          id: generatedUserId,
          username: name,
        );

        setState(() {
          username = name;
          userId = generatedUserId;
        });
        },
      );
    }

    return HomeScreen(
      username: username!,
      userId: userId!,
    );
  }
}