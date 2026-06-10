import '../models/team.dart';
import '../models/knockout_match.dart';
import '../models/bracket_match_rule.dart';
import '../models/group_standing.dart';
import '../models/bracket_slot.dart';

class KnockoutService {

  List<KnockoutMatch>
firstKnockoutRound (
  List<Team> teams,
) {
  final matches =
      <KnockoutMatch>[];

  for (
      int i = 0;
      i + 1 < teams.length;
      i += 2
    ) {
    matches.add(
      KnockoutMatch(
        homeTeam: teams[i],
        awayTeam: teams[i + 1],
      ),
    );
  }

  return matches;
}

Team getTeamFromSlot(
  BracketSlot slot,
  Map<String, List<GroupStanding>> tables,
  List<GroupStanding> bestThirds,
) {

  if (slot.bestThirdIndex != null) {
    return bestThirds[
      slot.bestThirdIndex!
    ].team;
  }

  return tables[
      slot.group]![slot.position! - 1]
      .team;
}

List<KnockoutMatch>
generateRoundFromRules(
  List<BracketMatchRule> rules,
  Map<String, List<GroupStanding>> tables,
  List<GroupStanding> bestThirds,
) {
  final matches =
      <KnockoutMatch>[];

  for (final rule in rules) {

    final homeTeam =
    getTeamFromSlot(
  rule.home,
  tables,
  bestThirds,
);

final awayTeam =
    getTeamFromSlot(
  rule.away,
  tables,
  bestThirds,
);

    matches.add(
      KnockoutMatch(
        homeTeam: homeTeam,
        awayTeam: awayTeam,
      ),
    );
  }

  return matches;
}
}