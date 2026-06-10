import 'package:flutter/material.dart';
import '../models/match_prediction.dart';
import '../../../data/world_cup_matches.dart';
import '../../tournament/services/group_stage_service.dart';
import '../../tournament/models/group_standing.dart';
import '../../tournament/models/team.dart';
import '../../tournament/models/player.dart';
import '../../tournament/config/world_cup_players.dart';
import 'dart:convert';
import '../../../core/supabase/supabase_client.dart';
import '../../tournament/services/group_stage_calculator.dart';
import '../../../core/utils/flag_utils.dart';

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
          const SizedBox(height: 24),
              const Text(
                'Premios individuales',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
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
          const SizedBox(height: 12),
          if (
                topScorer != null &&
                bestPlayer != null
              )
                ElevatedButton(
                  onPressed: submitPrediction,
                  child: const Text(
                    'Enviar porra',
                  ),
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
              '[${match.group}] ${FlagUtils.flagEmoji(match.homeTeam.code)} ${match.homeTeam.name}',
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
              '${match.awayTeam.name} ${FlagUtils.flagEmoji(match.awayTeam.code)}',
              textAlign:
                  TextAlign.end,
            ),
          ),
        ],
      ),
    ),
  );
}

void calculateGroups() {

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

  final result =
      GroupStageCalculator.calculate(
    matches,
  );

  setState(() {

    groupTables =
        Map<String,
        List<GroupStanding>>.from(
      result['tables'],
    );

    qualifiedTeams =
        Map<String,
        List<Team>>.from(
      result['qualified'],
    );

    bestThirdPlacedTeams =
        List<GroupStanding>.from(
      result['bestThirds'],
    );
  });
}

Future<void> submitPrediction() async {

  final groupMatches = matches
      .map((m) => m.toJson())
      .toList();

  final payload = {
    'group_matches': groupMatches,
    'top_scorer': topScorer!.name,
    'best_player': bestPlayer!.name,
    'best_third_placed': bestThirdPlacedTeams
      .map((t) => t.team.name)
      .toList(),
      'group_tables': {
        for (final entry in groupTables.entries)
          entry.key: entry.value
              .map((team) => team.team.name)
              .toList(),
      },
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
}
}
