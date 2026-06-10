import '../../prediction/models/match_prediction.dart';
import '../models/group_standing.dart';
import '../models/team.dart';
import 'group_stage_service.dart';

class GroupStageCalculator {

  static Map<String, dynamic> calculate(
    List<MatchPrediction> matches,
  ) {

    final service =
        GroupStageService();

    final groupedMatches =
        <String, List<MatchPrediction>>{};

    for (final match in matches) {

      groupedMatches.putIfAbsent(
        match.group,
        () => [],
      );

      groupedMatches[
          match.group]!
          .add(match);
    }

    final tables =
        <String, List<GroupStanding>>{};

    for (final entry
        in groupedMatches.entries) {

      tables[entry.key] =
          service.calculateGroup(
        entry.value,
      );
    }

    final thirds =
        <GroupStanding>[];

    final qualified =
        <String, List<Team>>{};

    for (final entry in tables.entries) {

      qualified[entry.key] = [
        entry.value[0].team,
        entry.value[1].team,
      ];

      thirds.add(
        entry.value[2],
      );
    }

    thirds.sort(
      (a, b) {

        if (b.points != a.points) {
          return b.points.compareTo(
            a.points,
          );
        }

        return b.goalDifference.compareTo(
          a.goalDifference,
        );
      },
    );

    final bestThirds =
        thirds.take(8).toList();

    return {
      'tables': tables,
      'bestThirds': bestThirds,
      'qualified': qualified,
    };
  }
}