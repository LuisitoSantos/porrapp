import 'package:flutter/material.dart';
import 'package:porrapp/features/lobby/screens/create_lobby_screen.dart';
import 'package:porrapp/features/lobby/screens/join_lobby_screen.dart';
import '../../rooms/models/room.dart';
import '../../rooms/services/room_service.dart';
import 'package:porrapp/features/lobby/screens/lobby_screen.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../main.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  final String user_id;

  const HomeScreen({
    super.key,
    required this.username,
    required this.user_id,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final roomService =
    RoomService();

  List<Room> rooms = []; 

  @override
    void initState() {
      super.initState();
      loadRooms();
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PorrApp'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
            ),
            onPressed: logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Hola ${widget.username}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateLobbyScreen(),
                  ),
                );
                loadRooms();
              },
              child: const Text(
                'Crear lobby',
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () async{
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JoinLobbyScreen(),
                  ),
                );
                loadRooms();
              },
              child: const Text(
                'Unirse a lobby',
              ),
            ),
            const SizedBox(height: 40),

            const Text(
              'Mis salas',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            ...rooms.map(
              (room) => Card(
                child: ListTile(
                  title: Text(
                    room.name,
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            LobbyScreen(
                          room: room,
                        ),
                      ),
                    );
                    loadRooms();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> loadRooms() async {

  final result =
      await roomService
          .getMyRooms();

  setState(() {
    rooms = result;
  });
}

Future<void> logout() async {

  final confirmed =
      await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text(
        'Cerrar sesión',
      ),
      content: const Text(
        '¿Seguro que quieres cerrar sesión?',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              false,
            );
          },
          child: const Text(
            'Cancelar',
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              true,
            );
          },
          child: const Text(
            'Salir',
          ),
        ),
      ],
    ),
  );

  if (confirmed != true) {
    return;
  }

  await LocalStorageService()
      .clearUser();

  if (!mounted) return;

  Navigator.of(context)
      .pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) =>
          const StartupScreen(),
    ),
    (route) => false,
  );
}
}