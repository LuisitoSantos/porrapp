import 'package:flutter/material.dart';
import 'team.dart';

class KnockoutMatch {
  final Team homeTeam;
  final Team awayTeam;

  int? homeGoals;
  int? awayGoals;

  final homeController =
      TextEditingController();

  final awayController =
      TextEditingController();

  Team? qualifiedTeam;

  KnockoutMatch({
    required this.homeTeam,
    required this.awayTeam,
  });

  Map<String, dynamic> toJson() {
  return {
    'home_team': homeTeam.name,
    'away_team': awayTeam.name,
    'home_goals':
        int.tryParse(
          homeController.text,
        ),
    'away_goals':
        int.tryParse(
          awayController.text,
        ),
    'qualified_team':
        qualifiedTeam?.name,
  };
}
}