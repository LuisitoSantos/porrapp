class ScoreBreakdown {

  int groupMatches = 0;
  int groupTables = 0;
  //int qualifiedTeams = 0;

  int knockoutMatches = 0;

  int semifinals = 0;
  int finals = 0;

  int champion = 0;
  int runnerUp = 0;

  int topScorer = 0;
  int bestPlayer = 0;

  int get total =>
      groupMatches +
      groupTables +
      //qualifiedTeams +
      knockoutMatches +
      semifinals +
      finals +
      champion +
      runnerUp +
      topScorer +
      bestPlayer;
      Map<String, dynamic> toJson() {
  return {
    'group_matches': groupMatches,
    'group_tables': groupTables,
    //'qualified_teams': qualifiedTeams,
    'knockout_matches': knockoutMatches,
    'semi_finalists': semifinals,
    'finalists': finals,
    'champion': champion,
    'runner_up': runnerUp,
    'top_scorer': topScorer,
    'best_player': bestPlayer,
  };
}
}