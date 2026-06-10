import 'package:flutter/material.dart';

class UsernameScreen extends StatefulWidget {
  final Function(String) onContinue;

  const UsernameScreen({
    super.key,
    required this.onContinue,
  });

  @override
  State<UsernameScreen> createState() =>
      _UsernameScreenState();
}

class _UsernameScreenState
    extends State<UsernameScreen> {
  final controller =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PorrApp'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration:
                  const InputDecoration(
                labelText:
                    'Nombre de usuario',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final name =
                    controller.text.trim();

                if (name.isEmpty) return;

                widget.onContinue(name);
              },
              child: const Text(
                'Continuar',
              ),
            ),
          ],
        ),
      ),
    );
  }
}