import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/room.dart';
import '../models/room_member.dart';

final supabase =
    Supabase.instance.client;

class RoomService {
Future<Room> createRoom({
  required String roomName,
  required String ownerId,
}) async {

  final roomCode =
      DateTime.now()
          .millisecondsSinceEpoch
          .toString()
          .substring(7);

  final room =
      await supabase
          .from('rooms')
          .insert({
            'name': roomName,
            'code': roomCode,
            'owner_id': ownerId,
          })
          .select()
          .single()
            .catchError((e) {
            debugPrint('ERROR EN ESTA CONSULTA: $e');
            throw e;
          });

          await supabase
    .from('room_settings')
    .insert({
      'room_id': room['id'],
    });

  await supabase
      .from('room_members')
      .insert({
        'room_id': room['id'],
        'user_id': ownerId,
      });

  return Room.fromJson(room);
}

Future<Room?> joinRoom(
  String code,
) async {

  final response =
      await supabase
          .from('rooms')
          .select()
          .eq(
            'code',
            code,
          )
          .maybeSingle();

  if (response == null) {
    return null;
  }

  await supabase
      .from('room_members')
      .insert({
        'room_id':
            response['id'],
        'user_id':
            supabase.auth.currentUser!.id,
      });

  return Room.fromJson(
    response,
  );
}

Future<List<String>>
getRoomMemberUsernames(
  String roomId,
) async {

  final members =
      await supabase
          .from('room_members')
          .select(
            'user_id',
          )
          .eq(
            'room_id',
            roomId,
          );

  final userIds =
      members
          .map(
            (m) => m['user_id']
                as String,
          )
          .toList();

  final profiles =
      await supabase
          .from('profiles')
          .select()
          .inFilter(
            'user_id',
            userIds,
          );

  return profiles
      .map<String>(
        (p) => p['username'],
      )
      .toList();
}

Future<List<Room>> getMyRooms() async {

  final userId =
      supabase.auth.currentUser!.id;

  final memberships =
      await supabase
          .from('room_members')
          .select('room_id')
          .eq('user_id', userId);

  final roomIds =
      memberships
          .map(
            (m) => m['room_id'],
          )
          .toList();

  if (roomIds.isEmpty) {
    return [];
  }

  final rooms =
      await supabase
          .from('rooms')
          .select()
          .inFilter(
            'id',
            roomIds,
          );

  return rooms
      .map<Room>(
        (room) =>
            Room.fromJson(room),
      )
      .toList();
}

Future<void> enableKnockout(
  String roomId,
) async {

  final result =
      await supabase
          .from('room_settings')
          .update({
            'knockout_open': true,
            'group_stage_open': false,
            'current_phase': 'knockout',
          })
          .eq('room_id', roomId)
          .select();

  debugPrint(result.toString());
}

Future<Map<String, dynamic>?>
getRoomSettings(
  String roomId,
) async {
  return await supabase
      .from('room_settings')
      .select()
      .eq(
        'room_id',
        roomId,
      )
      .maybeSingle();
}
Future<bool> hasSubmittedPrediction({
  required String roomId,
}) async {

  final result =
      await supabase
          .from('predictions')
          .select('id')
          .eq('room_id', roomId)
          .eq(
            'user_id',
            supabase.auth.currentUser!.id,
          )
          .maybeSingle();

  return result != null;
}

Future<List<RoomMember>>
getRoomMembers(
  String roomId,
) async {

  final members =
      await supabase
          .from('room_members')
          .select('user_id')
          .eq(
            'room_id',
            roomId,
          );

  final room =
      await supabase
          .from('rooms')
          .select()
          .eq(
            'id',
            roomId,
          )
          .single()
            .catchError((e) {
            debugPrint('ERROR EN ESTA CONSULTA: $e');
            throw e;
          });

  final ownerId =
      room['owner_id'];

  final result =
      <RoomMember>[];

  for (final member in members) {

    final userId =
        member['user_id'];

    final profile =
        await supabase
            .from('profiles')
            .select()
            .eq(
              'user_id',
              userId,
            )
            .single()
            .catchError((e) {
            debugPrint('ERROR EN ESTA CONSULTA: $e');
            throw e;
          });

    // Determine specific submission types
    final groupPrediction =
        await supabase
            .from('predictions')
            .select('id')
            .eq('room_id', roomId)
            .eq('user_id', userId)
            .eq('prediction_type', 'group_stage')
            .maybeSingle();

    final knockoutPrediction =
        await supabase
            .from('predictions')
            .select('id')
            .eq('room_id', roomId)
            .eq('user_id', userId)
            .eq('prediction_type', 'knockout_stage')
            .maybeSingle();

    result.add(
      RoomMember(
        userId: userId,
        username: profile['username'],
        isOwner: userId == ownerId,
        groupStageSubmitted: groupPrediction != null,
        knockoutSubmitted: knockoutPrediction != null,
      ),
    );
  }

  return result;
}

Future<bool> hasSubmittedGroupStage({
  required String roomId,
}) async {

  final result =
      await supabase
          .from('predictions')
          .select('id')
          .eq('room_id', roomId)
          .eq(
            'user_id',
            supabase.auth.currentUser!.id,
          )
          .eq(
            'prediction_type',
            'group_stage',
          )
          .maybeSingle();

  return result != null;
}

Future<bool> hasSubmittedKnockout({
  required String roomId,
}) async {

  final result =
      await supabase
          .from('predictions')
          .select('id')
          .eq('room_id', roomId)
          .eq(
            'user_id',
            supabase.auth.currentUser!.id,
          )
          .eq(
            'prediction_type',
            'knockout_stage', // <- aquí
          )
          .maybeSingle();

  return result != null;
}


}