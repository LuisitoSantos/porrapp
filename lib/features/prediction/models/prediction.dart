class Prediction {

  final String champion;
  final String runnerUp;
  final String topScorer;
  final String bestPlayer;

  const Prediction({
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

  factory Prediction.fromJson(
    Map<String, dynamic> json,
  ) {
    return Prediction(
      champion: json['champion'],
      runnerUp: json['runner_up'],
      topScorer: json['top_scorer'],
      bestPlayer: json['best_player'],
    );
  }
}