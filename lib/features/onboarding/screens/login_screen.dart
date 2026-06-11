import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {

  final Future<void> Function(
    String email,
  ) onLogin;

  final Future<void> Function(
    String email,
    String username,
  ) onRegister;

  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PorrApp',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [

            ElevatedButton(
              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        RegisterView(
                      onRegister:
                          onRegister,
                    ),
                  ),
                );
              },
              child: const Text(
                'Nuevo usuario',
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            ElevatedButton(
              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        LoginView(
                      onLogin:
                          onLogin,
                    ),
                  ),
                );
              },
              child: const Text(
                'Iniciar sesión',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class RegisterView
    extends StatefulWidget {

  final Future<void> Function(
    String email,
    String username,
  ) onRegister;

  const RegisterView({
    super.key,
    required this.onRegister,
  });

  @override
  State<RegisterView>
      createState() =>
          _RegisterViewState();
}

class _RegisterViewState
    extends State<RegisterView> {

  final emailController =
      TextEditingController();

  final usernameController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          children: [

            TextField(
              controller:
                  emailController,
              decoration:
                  const InputDecoration(
                labelText:
                    'Email',
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
                  usernameController,
              decoration:
                  const InputDecoration(
                labelText:
                    'Nombre usuario',
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            ElevatedButton(
              onPressed: () async {

                await widget.onRegister(
                  emailController.text,
                  usernameController.text,
                );

                if (
                    context.mounted) {
                  Navigator.pop(
                    context,
                  );
                }
              },
              child: const Text(
                'Crear usuario',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class LoginView
    extends StatefulWidget {

  final Future<void> Function(
    String email,
  ) onLogin;

  const LoginView({
    super.key,
    required this.onLogin,
  });

  @override
  State<LoginView>
      createState() =>
          _LoginViewState();
}

class _LoginViewState
    extends State<LoginView> {

  final emailController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          children: [

            TextField(
              controller:
                  emailController,
              decoration:
                  const InputDecoration(
                labelText:
                    'Email',
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            ElevatedButton(
              onPressed: () async {

                await widget.onLogin(
                  emailController.text,
                );

                if (
                    context.mounted) {
                  Navigator.pop(
                    context,
                  );
                }
              },
              child: const Text(
                'Entrar',
              ),
            ),
          ],
        ),
      ),
    );
  }
}