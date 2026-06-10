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

  final rows =
      scores.map((score) {
    return {
      'room_id': roomId,
      'user_id': score.userId,
      'group_stage_points':
          score.breakdown.groupMatches +
          score.breakdown.groupTables +
          score.breakdown.qualifiedTeams,
      'knockout_points':
          score.breakdown.knockoutMatches +
          score.breakdown.semifinals +
          score.breakdown.finals +
          score.breakdown.champion +
          score.breakdown.runnerUp,
      'total_points':
          score.total,
    };
  }).toList();

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