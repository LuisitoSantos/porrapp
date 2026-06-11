import 'package:flutter/material.dart';
import '../../tournament/models/team.dart';
import '../../tournament/models/knockout_match.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../tournament/models/team.dart';
import '../../../core/utils/flag_utils.dart';
import '../../../core/services/local_storage_service.dart';

class KnockoutScreen extends StatefulWidget {
  final String roomId;

  

  const KnockoutScreen({
    super.key,
    required this.roomId,
  });

  @override
  State<KnockoutScreen> createState() => _KnockoutScreenState();
}

class _KnockoutScreenState extends State<KnockoutScreen> {

        List<KnockoutMatch>
          firstKnockoutRoundMatches  = [];

      List<List<KnockoutMatch>>
          knockoutRounds = [];

      @override
      void initState() {
        super.initState();
        loadKnockoutBracket1();
        loadKnockoutBracket();
      }
          
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Eliminatorias',
        ),
      ),
      body: firstKnockoutRoundMatches.isEmpty
    ? const Center(
        child: CircularProgressIndicator(),
      )
    : ListView(
        padding: const EdgeInsets.all(16),
        children: [

          Text(
            'Dieciseisavos',
            style: Theme.of(context)
                .textTheme
                .headlineSmall,
          ),

          const SizedBox(height: 16),

          ...firstKnockoutRoundMatches.map(
            buildKnockoutMatchCard,
          ),

          ...knockoutRounds.map(
            (round) => Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                const SizedBox(
                  height: 32,
                ),

                Text(
                  getRoundName(
                    round.length,
                  ),
                  style: Theme.of(context)
                  .textTheme
                  .headlineSmall,
                ),
                
                ...round.map(
                  buildKnockoutMatchCard,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          if(!tournamentFinished)
          ElevatedButton(
            onPressed:
                calculateNextRound,
            child: const Text(
              'Siguiente ronda',
            ),
          ),
          if (tournamentFinished) ...[
          const SizedBox(height: 24),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [

                      const Text(
                        '🏆 Campeón',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        champion?.name ?? '-',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        '🥈 Subcampeón',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        runnerUp?.name ?? '-',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ElevatedButton(
              onPressed: submitKnockoutPrediction,
              child: const Text(
                'Enviar porra',
              ),
            ),
        ],
        ]
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
                  '${FlagUtils.flagEmoji(match.homeTeam.code)} ${match.homeTeam.name}',
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
                  '${match.awayTeam.name} ${FlagUtils.flagEmoji(match.awayTeam.code)}',
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
                  '${FlagUtils.flagEmoji(match.homeTeam.code)} ${match.homeTeam.name}',
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
                  '${match.awayTeam.name} ${FlagUtils.flagEmoji(match.awayTeam.code)}',
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

  if (tournamentFinished) {
  return;
}

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

Future<void> loadKnockoutBracket() async {

  final prediction =
      await supabase
          .from('predictions')
          .select()
          .eq(
            'room_id',
            widget.roomId,
          )
          .eq(
            'user_id',
            await CurrentUser.getId(),
          )
          .eq(
            'prediction_type',
            'group_stage',
          )
          .single()
            .catchError((e) {
            debugPrint('ERROR EN ESTA CONSULTA: $e');
            throw e;
          });

  final roomSettings =
      await supabase
          .from('room_settings')
          .select()
          .eq(
            'room_id',
            widget.roomId,
          )
          .single()
            .catchError((e) {
            debugPrint('ERROR EN ESTA CONSULTA: $e');
            throw e;
          });

  final data =
      prediction['data'];

  final groupTables =
      Map<String, dynamic>.from(
        data['group_tables'],
      );

  final bestThirdPlaced =
      List<String>.from(
        data['best_third_placed'],
      );

    final rules =
      roomSettings['knockout_rules'];

      if (rules == null || rules.isEmpty) {

        if (mounted) {
          ScaffoldMessenger.of(context)
            .showSnackBar(
              const SnackBar(
                content: Text(
                  'El administrador aún no ha configurado los cruces',
                ),
              ),
            );
        }

        return;
      }

  final round =
      generateRoundFromAdminRules(
        rules,
        groupTables,
        bestThirdPlaced,
      );

  if (!mounted) return;

  setState(() {
    firstKnockoutRoundMatches =
        round;
  });
}

Team resolveReference(
  String ref,
  Map<String, dynamic> tables,
  List<String> bestThirds,
) {

  if (ref.startsWith('T')) {

    final rank =
        int.parse(
          ref.substring(1),
        );

    return Team(
      code: bestThirds[rank - 1],
      name: bestThirds[rank - 1],
    );
  }

  final group =
      ref.substring(0,1);

  final position =
      int.parse(
        ref.substring(1),
      );

  return Team(
    code: tables[group][position - 1],
    name: tables[group][position - 1],
  );
}

List<KnockoutMatch>
generateRoundFromAdminRules(
  List<dynamic> rules,
  Map<String, dynamic> tables,
  List<String> bestThirds,
) {

  final matches =
      <KnockoutMatch>[];

  for (final rule in rules) {

    final home =
        resolveReference(
          rule['home'],
          tables,
          bestThirds,
        );

    final away =
        resolveReference(
          rule['away'],
          tables,
          bestThirds,
        );

    matches.add(
      KnockoutMatch(
        homeTeam: home,
        awayTeam: away,
      ),
    );
  }

  return matches;
}

Future<void> submitKnockoutPrediction()
async {

  if (!tournamentFinished) {
    return;
  }

  if (champion == null) {

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Debes completar todas las rondas',
        ),
      ),
    );

    return;
  }

  final knockoutData = {

  'round_of_32':
      firstKnockoutRoundMatches
          .map(serializeMatch)
          .toList(),

  'round_of_16':
      knockoutRounds.length > 0
          ? knockoutRounds[0]
              .map(serializeMatch)
              .toList()
          : [],

  'quarter_finals':
      knockoutRounds.length > 1
          ? knockoutRounds[1]
              .map(serializeMatch)
              .toList()
          : [],

  'semi_finals':
      knockoutRounds.length > 2
          ? knockoutRounds[2]
              .map(serializeMatch)
              .toList()
          : [],

  'final':
      knockoutRounds.length > 3
          ? knockoutRounds[3]
              .map(serializeMatch)
              .toList()
          : [],

  'champion':
      champion?.name,

  'runner_up':
      runnerUp?.name,
};

  await supabase
    .from('predictions')
    .upsert(
      {
        'room_id': widget.roomId,
        'user_id':await CurrentUser.getId(),
        'prediction_type': 'knockout_stage',
        'data': knockoutData,
      },
      onConflict:
          'user_id,room_id,prediction_type',
    )
    .select();

  if (!mounted) return;

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(
    const SnackBar(
      content: Text(
        'Porra enviada',
      ),
    ),
  );

  Navigator.pop(context);
}

Map<String, dynamic> serializeMatch(
  KnockoutMatch match,
) {
  return {
    'home_team': match.homeTeam.name,
    'away_team': match.awayTeam.name,
    'home_goals': int.tryParse(
      match.homeController.text,
    ),
    'away_goals': int.tryParse(
      match.awayController.text,
    ),
    'qualified_team':
        match.qualifiedTeam?.name,
  };
}

Future<void> loadKnockoutBracket1() async {
  try {

    print('A');

    final prediction =
        await supabase
            .from('predictions')
            .select()
            .eq('room_id', widget.roomId)
            .eq(
              'user_id',
              await CurrentUser.getId(),
            )
            .eq(
              'prediction_type',
              'group_stage',
            )
            .single()
            .catchError((e) {
            debugPrint('ERROR EN ESTA CONSULTA: $e');
            throw e;
          });

    print('B');

    final roomSettings =
        await supabase
            .from('room_settings')
            .select()
            .eq(
              'room_id',
              widget.roomId,
            )
            .single()
            .catchError((e) {
            debugPrint('ERROR EN ESTA CONSULTA: $e');
            throw e;
          });

    print('C');

  } catch (e) {
    print(e);
  }
}
}
