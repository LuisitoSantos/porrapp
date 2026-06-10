import 'package:flutter/material.dart';

import '../models/lobby.dart';
import 'lobby_screen.dart';
import '../../rooms/services/room_service.dart';
import '../../rooms/models/room.dart';

class CreateLobbyScreen extends StatefulWidget {
  const CreateLobbyScreen({super.key});

  @override
  State<CreateLobbyScreen> createState() =>
      _CreateLobbyScreenState();
}

class _CreateLobbyScreenState
    extends State<CreateLobbyScreen> {
  final controller =
      TextEditingController();

      final roomService =
    RoomService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Lobby'),
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
                    'Nombre del lobby',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {

                final room =
                    await roomService.createRoom(
                  roomName: controller.text,
                  ownerId:
                      supabase.auth.currentUser!.id,
                );

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
                'Crear Lobby',
              ),
            ),
          ],
        ),
      ),
    );
  }
}