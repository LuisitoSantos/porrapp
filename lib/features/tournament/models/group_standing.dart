import 'team.dart';

class GroupStanding {
  final Team team;

  int played = 0;

  int wins = 0;
  int draws = 0;
  int losses = 0;

  int goalsFor = 0;
  int goalsAgainst = 0;

  int points = 0;

  GroupStanding({
    required this.team,
  });

  int get goalDifference =>
      goalsFor - goalsAgainst;
}