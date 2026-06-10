import '../../prediction/models/match_prediction.dart';
import '../models/group_standing.dart';


class GroupStageService {
  List<GroupStanding> calculateGroup(
    List<MatchPrediction> matches,
  ) {
    final standings =
        <String, GroupStanding>{};

    for (final match in matches) {
      // Ignorar partidos sin rellenar
      if (match.homeGoals == null ||
          match.awayGoals == null) {
        continue;
      }

      // Crear equipo local si no existe
      standings.putIfAbsent(
        match.homeTeam.code,
        () => GroupStanding(
          team: match.homeTeam,
        ),
      );

      // Crear equipo visitante si no existe
      standings.putIfAbsent(
        match.awayTeam.code,
        () => GroupStanding(
          team: match.awayTeam,
        ),
      );

      final home =
          standings[match.homeTeam.code]!;

      final away =
          standings[match.awayTeam.code]!;

      // Partidos jugados
      home.played++;
      away.played++;

      // Goles
      home.goalsFor +=
          match.homeGoals!;

      home.goalsAgainst +=
          match.awayGoals!;

      away.goalsFor +=
          match.awayGoals!;

      away.goalsAgainst +=
          match.homeGoals!;

      // Resultado
      if (match.homeGoals! >
          match.awayGoals!) {
        home.wins++;
        away.losses++;

        home.points += 3;
      } else if (match.homeGoals! <
          match.awayGoals!) {
        away.wins++;
        home.losses++;

        away.points += 3;
      } else {
        home.draws++;
        away.draws++;

        home.points++;
        away.points++;
      }
    }

    final table =
        standings.values.toList();

    table.sort(
      (a, b) {
        // 1. Puntos
        if (a.points != b.points) {
          return b.points.compareTo(
            a.points,
          );
        }

        // 2. Diferencia de goles
        if (a.goalDifference !=
            b.goalDifference) {
          return b.goalDifference
              .compareTo(
            a.goalDifference,
          );
        }

        // 3. Goles a favor
        return b.goalsFor.compareTo(
          a.goalsFor,
        );
      },
    );

    return table;
  }
}