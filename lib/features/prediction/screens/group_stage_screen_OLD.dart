import 'package:flutter/material.dart';
import '../models/match_prediction.dart';
import '../../../data/world_cup_matches.dart';
import '../../tournament/services/group_stage_service.dart';
import '../../tournament/models/group_standing.dart';
import '../../tournament/models/team.dart';
import '../../tournament/models/knockout_match.dart';
import '../../tournament/services/knockout_service.dart';
import '../../tournament/config/world_cup_2026_bracket.dart';
import '../../tournament/models/player.dart';
import '../../tournament/config/world_cup_players.dart';
import '../models/prediction_result.dart';
import 'dart:convert';
import '../../../core/supabase/supabase_client.dart';

class GroupStageScreen extends StatefulWidget {

  final String roomId;

  const GroupStageScreen({
    super.key,
    required this.roomId,
  });

  @override
  State<GroupStageScreen> createState() =>
      _GroupStageScreenState();
}

  class _GroupStageScreenState
    extends State<GroupStageScreen> {

      Player? topScorer;
      Player? bestPlayer;
      final matches = worldCupMatches;
      final service =
      GroupStageService();
      final knockoutService =
      KnockoutService();

      final topScorerController =
      TextEditingController();

      final bestPlayerController =
      TextEditingController();


      Map<String, List<GroupStanding>>
          groupTables = {};
      Map<String, List<Team>>
          qualifiedTeams = {};

      List<GroupStanding>
          thirdPlacedTeams = [];

      List<GroupStanding>
          bestThirdPlacedTeams = [];



      List<KnockoutMatch>
          firstKnockoutRoundMatches  = [];

      List<List<KnockoutMatch>>
          knockoutRounds = [];


      List<Widget> buildMatchList() {
      List<Widget> widgets = [];

      String? currentDate;

      for (final match in matches) {

        if (match.date != currentDate) {

          currentDate = match.date;

          widgets.add(
            Padding(
              padding: const EdgeInsets.only(
                top: 24,
                bottom: 12,
              ),
              child: Text(
                currentDate,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }

        widgets.add(
          buildMatchCard(match),
        );
      }
      return widgets;
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Predicción Mundial'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Fase de grupos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          ...buildMatchList(),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: calculateGroups,
            child: const Text(
              'Calcular clasificación',
            ),
          ),

          const SizedBox(height: 32),

          ...groupTables.entries.expand(
            (entry) {
              return [
                Text(
                  'Grupo ${entry.key}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Row(
                  children: [

                    Expanded(
                      flex: 4,
                      child: Text(
                        'Equipo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Expanded(
                      child: Text(
                        'PJ',
                        textAlign: TextAlign.center,
                      ),
                    ),

                    Expanded(
                      child: Text(
                        'DG',
                        textAlign: TextAlign.center,
                      ),
                    ),

                    Expanded(
                      child: Text(
                        'PTS',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),

                ...entry.value.map(
                  (team) => Row(
                    children: [

                      Expanded(
                        flex: 4,
                        child: Builder(
                          builder: (_) {

                            final position =
                                entry.value.indexOf(team);

                            Color? textColor;
                            FontWeight fontWeight =
                                FontWeight.normal;

                            if (position < 2) {

                              textColor =
                                  Colors.green;

                              fontWeight =
                                  FontWeight.bold;
                            }
                            else if (
                              bestThirdPlacedTeams.any(
                                (third) =>
                                    third.team.name ==
                                    team.team.name,
                              )
                            ) {

                              textColor =
                                  Colors.orange;

                              fontWeight =
                                  FontWeight.bold;
                            }

                            return Text(
                              team.team.name,
                              style: TextStyle(
                                color: textColor,
                                fontWeight:
                                    fontWeight,
                              ),
                            );
                          },
                        ),
                      ),

                      Expanded(
                        child: Text(
                          '${team.played}',
                          textAlign: TextAlign.center,
                        ),
                      ),

                      Expanded(
                        child: Text(
                          '${team.goalDifference}',
                          textAlign: TextAlign.center,
                        ),
                      ),

                      Expanded(
                        child: Text(
                          '${team.points}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )
                ),

                const SizedBox(height: 24),
              ];
            },
          ),
          const SizedBox(height: 32),
          if (firstKnockoutRoundMatches.isNotEmpty)
            Text(
              getRoundName(
                firstKnockoutRoundMatches.length,
              ),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

          const SizedBox(height: 16),
          ...firstKnockoutRoundMatches.map(
            buildKnockoutMatchCard,
          ),
          const SizedBox(height: 24),

          ...knockoutRounds.asMap().entries.expand(
            (entry) {

              final roundIndex =
                  entry.key;

              final roundMatches =
                  entry.value;

              return [

                    Text(
                      getRoundName(
                        roundMatches.length,
                      ),
                      style:
                          const TextStyle(
                        fontSize: 24,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    ...roundMatches.map(
                      buildKnockoutMatchCard,
                    ),

                    const SizedBox(
                      height: 32,
                    ),
                  ];
                },
              ),
              
             if (firstKnockoutRoundMatches.isNotEmpty &&
                !tournamentFinished)
              ElevatedButton(
                onPressed: calculateNextRound,
                child: const Text(
                  'Calcular siguiente ronda',
                ),
              ),

              if (champion != null) ...[

                const SizedBox(
                  height: 32,
                ),

                const Text(
                  'Resultado final',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                Card(
                  child: ListTile(
                    leading: const Text(
                      '🏆',
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                    title: const Text(
                      'Campeón',
                    ),
                    subtitle: Text(
                      champion!.name,
                    ),
                  ),
                ),

                Card(
                  child: ListTile(
                    leading: const Text(
                      '🥈',
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                    title: const Text(
                      'Subcampeón',
                    ),
                    subtitle: Text(
                      runnerUp!.name,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              const Text(
                'Premios individuales',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (
                champion != null &&
                topScorer != null &&
                bestPlayer != null
              )
                ElevatedButton(
                  onPressed: submitPrediction,
                  child: const Text(
                    'Enviar porra',
                  ),
                ),
              Autocomplete<Player>(
  displayStringForOption:
      (player) => player.name,

  optionsBuilder: (textEditingValue) {

    if (textEditingValue.text.isEmpty) {
      return const Iterable<Player>.empty();
    }

    return worldCupPlayers.where(
      (player) =>
          player.name
              .toLowerCase()
              .contains(
                textEditingValue.text
                    .toLowerCase(),
              ),
    );
  },

  onSelected: (player) {
    setState(() {
      topScorer = player;
    });
  },

  fieldViewBuilder: (
    context,
    controller,
    focusNode,
    onFieldSubmitted,
  ) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration:
          const InputDecoration(
        labelText:
            'Máximo goleador',
      ),
    );
  },
),
Autocomplete<Player>(
  displayStringForOption:
      (player) => player.name,

  optionsBuilder: (textEditingValue) {

    if (textEditingValue.text.isEmpty) {
      return const Iterable<Player>.empty();
    }

    return worldCupPlayers.where(
      (player) =>
          player.name
              .toLowerCase()
              .contains(
                textEditingValue.text
                    .toLowerCase(),
              ),
    );
  },

  onSelected: (player) {
    setState(() {
      bestPlayer = player;
    });
  },

  fieldViewBuilder: (
    context,
    controller,
    focusNode,
    onFieldSubmitted,
  ) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration:
          const InputDecoration(
        labelText:
            'Mejor jugador del torneo',
      ),
    );
  },
),
if (topScorer != null)
  Text(
    '⚽ ${topScorer!.name}',
  ),

if (bestPlayer != null)
  Text(
    '🏅 ${bestPlayer!.name}',
  ),
        ],
      ),
    );
  }
  Widget buildMatchCard(
  MatchPrediction match,
) {
  return Card(
    key: ValueKey(
    match.matchNumber,
  ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '[${match.group}] ${match.homeTeam.name}',
            ),
          ),

          SizedBox(
            width: 50,
            child: TextField(
              controller: match.homeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '',
              ),
              onChanged: (value) {
                match.homeGoals =
                    int.tryParse(value);
              },
            ),
          ),

          const Padding(
            padding:
                EdgeInsets.symmetric(
              horizontal: 8,
            ),
            child: Text('-'),
          ),

          SizedBox(
            width: 50,
            child: TextField(
              controller: match.awayController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '',
              ),
              onChanged: (value) {
                match.awayGoals =
                    int.tryParse(value);
              },
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              match.awayTeam.name,
              textAlign:
                  TextAlign.end,
            ),
          ),
        ],
      ),
    ),
  );
}
Widget buildKnockoutMatchCard(
  KnockoutMatch match,
) {
  final isDraw =
      match.homeController.text ==
          match.awayController.text &&
      match.homeController.text
          .isNotEmpty;

  return Column(
    children: [

      Card(
        child: Padding(
          padding:
              const EdgeInsets.all(12),
          child: Row(
            children: [

              Expanded(
                child: Text(
                  match.homeTeam.name,
                ),
              ),

              SizedBox(
                width: 50,
                child: TextField(
                  controller:
                      match.homeController,
                  keyboardType:
                      TextInputType.number,
                  onChanged: (_) {
                    setState(() {});
                  },
                ),
              ),

              const Padding(
                padding:
                    EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                child: Text('-'),
              ),

              SizedBox(
                width: 50,
                child: TextField(
                  controller:
                      match.awayController,
                  keyboardType:
                      TextInputType.number,
                  onChanged: (_) {
                    setState(() {});
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  match.awayTeam.name,
                  textAlign:
                      TextAlign.end,
                ),
              ),
            ],
          ),
        ),
      ),

      if (isDraw)
        Card(
          child: Column(
            children: [

              const Padding(
                padding:
                    EdgeInsets.only(
                  top: 8,
                ),
                child: Text(
                  'Clasificado',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              RadioListTile<Team>(
                title: Text(
                  match.homeTeam.name,
                ),
                value:
                    match.homeTeam,
                groupValue:
                    match.qualifiedTeam,
                onChanged: (value) {
                  setState(() {
                    match.qualifiedTeam =
                        value;
                  });
                },
              ),

              RadioListTile<Team>(
                title: Text(
                  match.awayTeam.name,
                ),
                value:
                    match.awayTeam,
                groupValue:
                    match.qualifiedTeam,
                onChanged: (value) {
                  setState(() {
                    match.qualifiedTeam =
                        value;
                  });
                },
              ),
            ],
          ),
        ),
    ],
  );
}

void calculateGroups() {
  debugPrint("CALCULANDO GRUPOS");
  debugPrint(
  'Partidos: ${matches.length}',
);
  for (final match in matches) {
    match.homeGoals =
        int.tryParse(
          match.homeController.text,
        );

    match.awayGoals =
        int.tryParse(
          match.awayController.text,
        );
  }

  final groupedMatches =
    <String, List<MatchPrediction>>{};

    debugPrint(
  'Grupos encontrados: ${groupedMatches.length}',
);

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

  if (entry.value.length >= 3) {

    qualified[entry.key] = [
      entry.value[0].team,
      entry.value[1].team,
    ];

    thirds.add(
      entry.value[2],
    );
  }
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

    final qualifiedTeamsForKnockout =
    <Team>[];

    for (final group in qualified.values) {
  qualifiedTeamsForKnockout.addAll(
    group,
  );
}

for (final third in bestThirds) {
  qualifiedTeamsForKnockout.add(
    third.team,
  );
}


final firstKnockoutRound =
   knockoutService
        .generateRoundFromRules(
  worldCup2026RoundOf32,
  tables,
  bestThirds,
);

  setState(() {
    groupTables = tables;
    qualifiedTeams = qualified;
    thirdPlacedTeams = thirds;
    bestThirdPlacedTeams = bestThirds;

    firstKnockoutRoundMatches =
        firstKnockoutRound;

    knockoutRounds = [];
  });
}

Team? getWinner(
        KnockoutMatch match,
      ) {
        final homeGoals =
            int.tryParse(
          match.homeController.text,
        );

        final awayGoals =
            int.tryParse(
          match.awayController.text,
        );

        if (homeGoals == null ||
            awayGoals == null) {
          return null;
        }

        if (homeGoals > awayGoals) {
          return match.homeTeam;
        }

        if (awayGoals > homeGoals) {
          return match.awayTeam;
        }
        if (homeGoals == awayGoals) {
          return match.qualifiedTeam;
        }

        return null;
      }

      KnockoutMatch? get finalMatch {

        if (knockoutRounds.isEmpty) {
          return null;
        }

        final lastRound =
            knockoutRounds.last;

        if (lastRound.length != 1) {
          return null;
        }

        return lastRound.first;
      }

      Team? get champion {

      final match =
          finalMatch;

      if (match == null) {
        return null;
      }

      return getWinner(match);
    }

    Team? get runnerUp {

      final match =
          finalMatch;

      final winner =
          champion;

      if (
        match == null ||
        winner == null
      ) {
        return null;
      }

      if (winner ==
          match.homeTeam) {

        return match.awayTeam;
      }

      return match.homeTeam;
    }

      List<KnockoutMatch>
generateNextRound(
  List<KnockoutMatch> matches,
) {
  final winners = <Team>[];

  for (final match in matches) {

    final winner =
        getWinner(match);

    if (winner == null) {
      return [];
    }

    winners.add(winner);
  }

  final nextRound =
      <KnockoutMatch>[];

  for (
    int i = 0;
    i < winners.length;
    i += 2
  ) {
    if (i + 1 <
        winners.length) {

      nextRound.add(
        KnockoutMatch(
          homeTeam:
              winners[i],
          awayTeam:
              winners[i + 1],
        ),
      );
    }
  }

  return nextRound;
}



void calculateNextRound() {

  List<KnockoutMatch> sourceRound;

  if (knockoutRounds.isEmpty) {

    sourceRound =
        firstKnockoutRoundMatches;

  } else {

    sourceRound =
        knockoutRounds.last;
  }

  final nextRound =
      generateNextRound(
    sourceRound,
  );

  if (nextRound.isEmpty) {

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      const SnackBar(
        content: Text(
          'Revisa los empates sin clasificado',
        ),
      ),
    );

    return;
  }

  setState(() {
    knockoutRounds.add(
      nextRound,
    );
  });
}

Future<void> submitPrediction() async {

  final prediction =
      PredictionResult(
    champion: champion!.name,
    runnerUp: runnerUp!.name,
    topScorer: topScorer!.name,
    bestPlayer: bestPlayer!.name,
  );

  final groupMatches =
    matches.map(
      (m) => m.toJson(),
    ).toList();

  final knockoutMatches =
    [
      ...firstKnockoutRoundMatches,
      ...knockoutRounds.expand(
        (round) => round,
      ),
    ]
        .map(
          (m) => m.toJson(),
        )
        .toList();
        /*
        final payload = {
          'prediction': prediction.toJson(),
          'group_matches': groupMatches,
          'knockout_matches': knockoutMatches,
        };
        */
        final payload = {
          'group_matches': groupMatches,
          'top_scorer': topScorer!.name,
          'best_player': bestPlayer!.name,
        };

       await supabase
        .from('predictions')
        .insert({
          'user_id':
              supabase.auth.currentUser!.id,

          'room_id':
              widget.roomId,

          'prediction_type':
              'group_stage',

          'data': payload,
        });

    if (!mounted) return;

Navigator.pop(context);

  debugPrint(
  const JsonEncoder.withIndent(
    '  ',
  ).convert(payload),
);
}

String getRoundName(
  int matchCount,
) {
  switch (matchCount) {
    case 16:
      return 'Dieciseisavos';

    case 8:
      return 'Octavos';

    case 4:
      return 'Cuartos';

    case 2:
      return 'Semifinales';

    case 1:
      return 'Final';

    default:
      return 'Eliminatoria';
  }
}

bool get tournamentFinished {

  if (knockoutRounds.isEmpty) {
    return false;
  }

  return knockoutRounds.last.length == 1;
}
}
