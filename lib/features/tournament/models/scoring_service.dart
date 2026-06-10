import '../../../core/supabase/supabase_client.dart';

import 'PredictionScore.dart';
import 'score_breakdown.dart';

class ScoringService {

  Future<List<PredictionScore>>
      calculateRoomScores(
    String roomId,
  ) async {

    final roomResults =
        await supabase
            .from('room_results')
            .select()
            .eq(
              'room_id',
              roomId,
            )
            .single();

    final knockoutResults =
        await supabase
            .from('knockout_results')
            .select()
            .eq(
              'room_id',
              roomId,
            )
            .maybeSingle();

    final predictions =
        await supabase
            .from('predictions')
            .select()
            .eq(
              'room_id',
              roomId,
            );

    final results =
        <PredictionScore>[];

    final users =
        predictions
            .map(
              (e) => e['user_id']
                  as String,
            )
            .toSet();

    for (final userId in users) {

      final groupPrediction =
          predictions.firstWhere(
        (p) =>
            p['user_id'] ==
                userId &&
            p['prediction_type'] ==
                'group_stage',
      );

      final knockoutPrediction =
          predictions.where(
        (p) =>
            p['user_id'] ==
                userId &&
            p['prediction_type'] ==
                'knockout_stage',
      ).isEmpty
              ? null
              : predictions.firstWhere(
                  (p) =>
                      p['user_id'] ==
                          userId &&
                      p['prediction_type'] ==
                          'knockout_stage',
                );

      final breakdown =
          ScoreBreakdown();

      calculateGroupStage(
        breakdown,
        groupPrediction['data'],
        roomResults['data'],
      );

      if (
        knockoutPrediction != null &&
        knockoutResults != null
      ) {

        calculateKnockout(
          breakdown,
          knockoutPrediction['data'],
          knockoutResults['data'],
        );
      }

      results.add(
        PredictionScore(
          userId: userId,
          breakdown: breakdown,
        ),
      );
    }

    results.sort(
      (a, b) =>
          b.total.compareTo(
        a.total,
      ),
    );

    return results;
  }

  void calculateGroupStage(
  ScoreBreakdown score,
  Map prediction,
  Map official,
) {

  final predictedMatches =
      List<Map<String,dynamic>>.from(
    prediction['group_matches'] ?? [],
  );

  final officialMatches =
      List<Map<String,dynamic>>.from(
    official['group_matches'] ?? [],
  );

  for (
    int i = 0;
    i < predictedMatches.length &&
    i < officialMatches.length;
    i++
  ) {

    final p =
        predictedMatches[i];

    final o =
        officialMatches[i];

    score.groupMatches +=
        calculateMatchPoints(
      p['home_goals'],
      p['away_goals'],
      o['home_goals'],
      o['away_goals'],
    );
  }

  if (
    prediction['group_tables'] != null &&
    official['group_tables'] != null
  ) {

    calculateGroupTablesPoints(
      score,
      prediction,
      official,
    );
  }

  if (
    prediction['best_third_placed'] != null &&
    official['best_third_placed'] != null &&
    prediction['group_tables'] != null &&
    official['group_tables'] != null
  ) {

    calculateQualifiedTeamsPoints(
      score,
      prediction,
      official,
    );
  }

  calculateIndividualAwards(
    score,
    prediction,
    official,
  );
}

  int calculateMatchPoints(
    int? predictedHome,
    int? predictedAway,
    int? officialHome,
    int? officialAway,
  ) {

    if (
      predictedHome == null ||
      predictedAway == null ||
      officialHome == null ||
      officialAway == null
    ) {
      return 0;
    }

    int points = 0;

    if (
      predictedHome ==
          officialHome &&
      predictedAway ==
          officialAway
    ) {
      points += 3;
    }

    final predictedDiff =
        predictedHome -
        predictedAway;

    final officialDiff =
        officialHome - officialAway;

    if (
      predictedDiff ==
      officialDiff
    ) {
      points += 2;
    }

    final predictedWinner =
        predictedDiff.sign;

    final officialWinner =
        officialDiff.sign;

    if (
      predictedWinner ==
      officialWinner
    ) {
      points += 1;
    }

    return points;
  }

  void calculateGroupTablesPoints(
    ScoreBreakdown score,
    Map prediction,
    Map official,
  ) {

    final predicted =
        Map<String,dynamic>.from(
      prediction['group_tables'],
    );

    final real =
        Map<String,dynamic>.from(
      official['group_tables'],
    );

    for (final group in real.keys) {

      final predictedGroup =
          List<String>.from(
        predicted[group],
      );

      final officialGroup =
          List<String>.from(
        real[group],
      );

      for (
        int i = 0;
        i < officialGroup.length;
        i++
      ) {

        if (
          predictedGroup[i] ==
          officialGroup[i]
        ) {
          score.groupTables += 2;
        }
      }
    }
  }

  void calculateQualifiedTeamsPoints(
    ScoreBreakdown score,
    Map prediction,
    Map official,
  ) {

    final predicted =
        <String>{};

    final real =
        <String>{};

    final predictedTables =
        Map<String,dynamic>.from(
      prediction['group_tables'],
    );

    final officialTables =
        Map<String,dynamic>.from(
      official['group_tables'],
    );

    for (
      final group
          in predictedTables.values
    ) {

      final teams =
          List<String>.from(
        group,
      );

      predicted.addAll(
        teams.take(2),
      );
    }

    predicted.addAll(
      List<String>.from(
        prediction[
            'best_third_placed'],
      ),
    );

    for (
      final group
          in officialTables.values
    ) {

      final teams =
          List<String>.from(
        group,
      );

      real.addAll(
        teams.take(2),
      );
    }

    real.addAll(
      List<String>.from(
        official[
            'best_third_placed'],
      ),
    );

    for (final team in predicted) {

      if (real.contains(team)) {
        score.qualifiedTeams += 5;
      }
    }
  }

  void calculateIndividualAwards(
  ScoreBreakdown score,
  Map prediction,
  Map official,
) {

  if (
    official['top_scorer'] != null &&
    prediction['top_scorer'] ==
        official['top_scorer']
  ) {
    score.topScorer += 10;
  }

  if (
    official['best_player'] != null &&
    prediction['best_player'] ==
        official['best_player']
  ) {
    score.bestPlayer += 10;
  }
}

  void calculateKnockoutRound(
    ScoreBreakdown score,
    dynamic predictedMatchesRaw,
    dynamic officialMatchesRaw,
  ) {

    final predictedMatches =
        List<Map<String,dynamic>>.from(
      predictedMatchesRaw ?? [],
    );

    final officialMatches =
        List<Map<String,dynamic>>.from(
      officialMatchesRaw ?? [],
    );

    for (
      int i = 0;
      i < predictedMatches.length &&
      i < officialMatches.length;
      i++
    ) {

      final p =
          predictedMatches[i];

      final o =
          officialMatches[i];

      final sameMatch =
          p['home_team'] ==
              o['home_team'] &&
          p['away_team'] ==
              o['away_team'];

      if (!sameMatch) {
        continue;
      }

      score.knockoutMatches +=
          calculateMatchPoints(
        p['home_goals'],
        p['away_goals'],
        o['home_goals'],
        o['away_goals'],
      );
    }
  }

  void calculateSemifinalists(
    ScoreBreakdown score,
    Map prediction,
    Map official,
  ) {

    final predicted =
        extractTeamsFromRound(
      prediction['semi_finals'],
    );

    final real =
        extractTeamsFromRound(
      official['semi_finals'],
    );

    for (final team in predicted) {

      if (real.contains(team)) {
        score.semifinals += 10;
      }
    }
  }

  void calculateFinalists(
    ScoreBreakdown score,
    Map prediction,
    Map official,
  ) {

    final predicted =
        extractTeamsFromRound(
      prediction['final'],
    );

    final real =
        extractTeamsFromRound(
      official['final'],
    );

    for (final team in predicted) {

      if (real.contains(team)) {
        score.finals += 15;
      }
    }
  }

  void calculateChampionRunnerUp(
    ScoreBreakdown score,
    Map prediction,
    Map official,
  ) {

    if (
      prediction['champion'] ==
      official['champion']
    ) {
      score.champion += 20;
    }

    if (
      prediction['runner_up'] ==
      official['runner_up']
    ) {
      score.runnerUp += 15;
    }
  }

  Set<String> extractTeamsFromRound(
    dynamic roundRaw,
  ) {

    final round =
        List<Map<String,dynamic>>.from(
      roundRaw ?? [],
    );

    final teams =
        <String>{};

    for (final match in round) {

      teams.add(
        match['home_team'],
      );

      teams.add(
        match['away_team'],
      );
    }

    return teams;
  }

  void calculateKnockout(
  ScoreBreakdown score,
  Map prediction,
  Map official,
) {

  calculateKnockoutRound(
    score,
    prediction['round_of_32'],
    official['round_of_32'],
  );

  calculateKnockoutRound(
    score,
    prediction['round_of_16'],
    official['round_of_16'],
  );

  calculateKnockoutRound(
    score,
    prediction['quarter_finals'],
    official['quarter_finals'],
  );

  calculateKnockoutRound(
    score,
    prediction['semi_finals'],
    official['semi_finals'],
  );

  calculateKnockoutRound(
    score,
    prediction['final'],
    official['final'],
  );

  if (official['semi_finals'] != null) {

    calculateSemifinalists(
      score,
      prediction,
      official,
    );
  }

  if (official['final'] != null) {

    calculateFinalists(
      score,
      prediction,
      official,
    );
  }

  if (official['champion'] != null) {

    calculateChampionRunnerUp(
      score,
      prediction,
      official,
    );
  }
}
}