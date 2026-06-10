import 'score_breakdown.dart';

class PredictionScore {

  final String userId;

  final ScoreBreakdown breakdown;

  PredictionScore({
    required this.userId,
    required this.breakdown,
  });

  int get total =>
      breakdown.total;
}