import 'package:flutter/material.dart';

import '../../rooms/models/room.dart';
import '../../rooms/services/room_service.dart';
import 'official_results_screen.dart';
import '../screens/knockout_rules_screen.dart';
import 'official_knockout_results_screen.dart';

class AdminConfigScreen
    extends StatefulWidget {

  final Room room;

  const AdminConfigScreen({
    super.key,
    required this.room,
  });

  @override
  State<AdminConfigScreen>
      createState() =>
          _AdminConfigScreenState();
}
class _AdminConfigScreenState
    extends State<AdminConfigScreen> {

  final roomService =
      RoomService();

  bool knockoutEnabled =
      false;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings()
  async {

    final settings =
        await roomService
            .getRoomSettings(
      widget.room.id,
    );

    if (settings == null) {
      return;
    }

    setState(() {
      knockoutEnabled =
          settings[
              'knockout_enabled'];
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Configuración torneo',
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            const Text(
              'Panel administrador',
              style: TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            ListTile(
              leading:
                  const Icon(Icons.flag),
              title: const Text(
                'Resultados grupos',
              ),
              onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OfficialResultsScreen(
                        roomId: widget.room.id,
                      ),
                    ),
                  );

                  await loadSettings();

              },
              subtitle: const Text(
                'Gestionar fase de grupos',
              ),
            ),

            ListTile(
              leading:
                  const Icon(Icons.route),
              title: const Text(
                'Cruces eliminatorias',
              ),
              subtitle: const Text(
                'Configurar dieciseisavos',
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        KnockoutRulesScreen(
                      roomId: widget.room.id,
                    ),
                  ),
                );
              },
            ),

            ListTile(
              leading:
                  const Icon(Icons.route),
              title: const Text(
                'Resultados eliminatorias',
              ),
              subtitle: const Text(
                'Gestionar fase eliminatoria',
              ),
              onTap: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        OfficialKnockoutResultsScreen(
                      roomId: widget.room.id,
                    ),
                  ),
                );
              },
            ),


            ListTile(
                leading:
                    const Icon(Icons.lock_open),

                title: Text(
                  knockoutEnabled
                      ? 'Eliminatorias abiertas'
                      : 'Abrir eliminatorias',
                ),

                onTap: () async {

                  await roomService
                      .enableKnockout(
                    widget.room.id,
                  );

                  setState(() {
                    knockoutEnabled =
                        true;
                  });

                  if (mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Eliminatorias habilitadas',
                        ),
                      ),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
  
}