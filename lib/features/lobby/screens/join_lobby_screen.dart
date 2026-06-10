import 'package:flutter/material.dart';

import '../models/lobby.dart';
import 'lobby_screen.dart';
import '../../rooms/services/room_service.dart';
import '../../rooms/models/room.dart';

class JoinLobbyScreen extends StatefulWidget {
  const JoinLobbyScreen({super.key});

  @override
  State<JoinLobbyScreen> createState() =>
      _JoinLobbyScreenState();
}

class _JoinLobbyScreenState
    extends State<JoinLobbyScreen> {
  final controller =
      TextEditingController();

      final roomService =
    RoomService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Unirse a Lobby',
        ),
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
                    'Código del lobby',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final room =
                    await roomService.joinRoom(
                  controller.text,
                );

                if (room == null) {

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Sala no encontrada',
                      ),
                    ),
                  );

                  return;
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        LobbyScreen(
                      room: room,
                    ),
                  ),
                );
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