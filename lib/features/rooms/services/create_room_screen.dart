import 'package:flutter/material.dart';
import '../services/room_service.dart';
import '../../../core/services/local_storage_service.dart';

class CreateRoomScreen
    extends StatefulWidget {

  const CreateRoomScreen({
    super.key,
  });

  @override
  State<CreateRoomScreen>
      createState() =>
          _CreateRoomScreenState();
}

class _CreateRoomScreenState
    extends State<CreateRoomScreen> {
      final controller =
    TextEditingController();

final roomService =
    RoomService();


  @override
  Widget build(
    BuildContext context,
  ) {
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [

              TextField(
                controller: controller,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Nombre de la sala',
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              ElevatedButton(
                onPressed: () async {

                  final room =
                      await roomService
                          .createRoom(
                    roomName:
                        controller.text,
                    ownerId:
                        await CurrentUser.getId(),
                  );
                },
                child: const Text(
                  'Crear sala',
                ),
              ),
            ],
          ),
        );
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crear sala',
        ),
      ),
    );
    
  }
  
}