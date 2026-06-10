import 'package:flutter/material.dart';
import '../../tournament/models/team.dart';
class MatchPrediction {
  final int matchNumber;

  final String stage;

  final String group;

  final String date;

  final Team homeTeam;
  final Team awayTeam;

  final homeController =
      TextEditingController();

  final awayController =
      TextEditingController();

  int? homeGoals;
  int? awayGoals;

  MatchPrediction({
    required this.matchNumber,
    required this.stage,
    required this.group,
    required this.date,
    required this.homeTeam,
    required this.awayTeam,
    this.homeGoals,
    this.awayGoals,
  });

  Map<String, dynamic> toJson() {
  return {
    'match_number': matchNumber,
    'group': group,
    'home_team': homeTeam.name,
    'away_team': awayTeam.name,
    'home_goals': homeGoals,
    'away_goals': awayGoals,
  };
}
}