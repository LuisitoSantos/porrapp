import '../../../core/supabase/supabase_client.dart';

import 'scoring_service.dart';

class ScorePersistenceService {

  final scoringService =
      ScoringService();

  Future<void> recalculateRoomScores(
  String roomId,
) async {

  final scores =
      await scoringService
          .calculateRoomScores(
    roomId,
  );

  final existingScores =
    await supabase
        .from('room_scores')
        .select()
        .eq(
          'room_id',
          roomId,
        );

    final oldPositions =
        <String, int>{};

    for (final row in existingScores) {

      oldPositions[
        row['user_id']
      ] =
          row['position'] ?? 0;
    }

  final rows =
    <Map<String, dynamic>>[];

  int currentPosition = 1;

for (int i = 0; i < scores.length; i++) {

  final score = scores[i];

  if (i > 0) {

    final previousScore = scores[i - 1];

    if (score.total < previousScore.total) {
      currentPosition = i + 1;
    }
  }

  rows.add({
    'room_id': roomId,

    'user_id': score.userId,

    'group_stage_points':
        score.breakdown.groupMatches +
        score.breakdown.groupTables,

        /*
    'group_stage_points':
        score.breakdown.groupMatches +
        score.breakdown.groupTables +
        score.breakdown.qualifiedTeams,
        */

    'knockout_points':
        score.breakdown.knockoutMatches +
        score.breakdown.semifinals +
        score.breakdown.finals +
        score.breakdown.champion +
        score.breakdown.runnerUp,

    'total_points': score.total,

    'previous_position':
        oldPositions[score.userId],

    'position': currentPosition,
  });
}

  if (rows.isEmpty) return;

  print(
  'Scores calculados: ${scores.length}'
);

for (final score in scores) {
  print(score.userId);
}

for (final row in rows) {
  print(
    '${row['room_id']} '
    '${row['user_id']}'
  );
}

  try {

  await supabase
      .from('room_scores')
      .upsert(
        rows,
        onConflict:
            'room_id,user_id',
      );

} catch (e) {
  print(e);
}
}
}