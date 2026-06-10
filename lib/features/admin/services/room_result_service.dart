import 'package:supabase_flutter/supabase_flutter.dart';

final supabase =
    Supabase.instance.client;

class RoomResultService {

    Future<void> saveResults({
      required String roomId,
      required Map<String,dynamic> data,
    }) async {

      await supabase
          .from('room_results')
          .upsert({
            'room_id': roomId,
            'data': data,
          });
    }

  Future<Map<String,dynamic>?>
  loadResults(
    String roomId,
  ) async {

    final result =
        await supabase
            .from('room_results')
            .select()
            .eq(
              'room_id',
              roomId,
            )
            .maybeSingle();

    if (result == null) {
      return null;
    }

    return result['data'];
  }

  Future<Map<String, dynamic>?> getResults(
  String roomId,
) async {

  final result =
      await supabase
          .from('room_results')
          .select()
          .eq(
            'room_id',
            roomId,
          )
          .maybeSingle();

  return result?['data'];
}
}