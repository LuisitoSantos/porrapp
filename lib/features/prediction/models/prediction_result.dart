class PredictionResult {

  final String champion;

  final String runnerUp;

  final String topScorer;

  final String bestPlayer;

  PredictionResult({
    required this.champion,
    required this.runnerUp,
    required this.topScorer,
    required this.bestPlayer,
  });

  Map<String, dynamic> toJson() {
  return {
    'champion': champion,
    'runner_up': runnerUp,
    'top_scorer': topScorer,
    'best_player': bestPlayer,
  };
}
}
