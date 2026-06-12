import 'package:flutter/material.dart';

import '../models/lobby.dart';
import '../../prediction/screens/group_stage_screen.dart';
import '../../rooms/models/room.dart';
import '../../rooms/services/room_service.dart';
import '../../admin/screens/admin_config_screen.dart';
import '../../rooms/models/room_member.dart';
import '../../../core/services/local_storage_service.dart';
import '../../prediction/screens/knockout_stage_screen.dart';

class LobbyScreen extends StatefulWidget {
  final Room room;
  
  

  const LobbyScreen({
    super.key,
    required this.room,
  });

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  String? currentUserId;

  bool knockoutEnabled = false;

final roomService =
    RoomService();
    
    bool loadingLobby = true;
    

List<RoomMember> members = [];

Map<String, int> userPoints = {};
Map<String, int> userPositions = {};

bool groupStageSubmitted = false;
bool knockoutSubmitted = false;



  @override
  Widget build(BuildContext context) {

    final isAdmin =
    widget.room.ownerId ==
    currentUserId;
    
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.table_chart),
            onPressed: showMyPredictions,
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: showScoringRules,
          ),
        ],
      ),
      body: loadingLobby
    ? const Center(
        child: CircularProgressIndicator(),
      )
        : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(
              'Código: ${widget.room.code}',
              style: const TextStyle(
                fontSize: 10,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Participantes',
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),
            ...members.map(
              (member) => Card(
                child: ListTile(
                  onTap: () async {
                    showPredictionDialog(member);
                  },

                  leading: buildPosition(
                    userPositions[member.userId] ?? 0,
                  ),

                  title: Row(
                    children: [

                      Expanded(
                        child: Text(
                          member.isOwner
                              ? '${member.username} ⚙️'
                              : member.username,
                        ),
                      ),

                      Text(
                        '${userPoints[member.userId] ?? 0} pts',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        member.groupStageSubmitted
                            ? Icons.check_circle
                            : Icons.schedule,
                        color:
                            member.groupStageSubmitted
                                ? Colors.green
                                : Colors.orange,
                      ),

                      const SizedBox(width: 8),

                      Icon(
                        member.knockoutSubmitted
                            ? Icons.check_circle
                            : Icons.schedule,
                        color:
                            member.knockoutSubmitted
                                ? Colors.green
                                : Colors.orange,
                      ),
                    ],
                  ),
                )
              ),
            ),

            const SizedBox(height: 24),

            if (!knockoutEnabled &&
                 !groupStageSubmitted)
                ElevatedButton(
                  onPressed: () async {

                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            GroupStageScreen(
                          roomId: widget.room.id,
                        ),
                      ),
                    );
                    await refreshLobby();
                  },
                  child: Text(
                    knockoutEnabled
                        ? 'Completar eliminatorias'
                        : 'Completar fase de grupos',
                  ),
                ),
                if (
                  knockoutEnabled &&
                  !knockoutSubmitted
                )
                ElevatedButton(
                  onPressed: () async {

                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            KnockoutScreen(
                          roomId: widget.room.id,
                        ),
                      ),
                    );

                    await refreshLobby();
                  },
                  child: Text(
                    'Completar eliminatorias',
                  ),
                ),
            if (isAdmin)
              ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminConfigScreen(
                        room: widget.room,
                      ),
                    ),
                  );

                  await refreshLobby();
                },
                child: const Text(
                  'Configuración torneo',
                ),
              ),

              const SizedBox(height: 12),
          ],
        ),
      ),
        )
    );
  }

@override
void initState() {
  super.initState();
  initializeLobby();
}

Future<void> initializeLobby() async {

  currentUserId =
    await CurrentUser.getId();

  await loadMembers();
  await loadSettings();
  await loadRanking();

  if (!mounted) return;

  setState(() {
    loadingLobby = false;
  });
}

Future<void> refreshLobby() async {

  await loadMembers();
  await loadSettings();
  await loadRanking();

  if (!mounted) return;

  setState(() {});
}

Future<void> loadMembers() async {

  final groupPrediction =
    await roomService.hasSubmittedGroupStage(
      roomId: widget.room.id,
    );

final knockoutPrediction =
    await roomService.hasSubmittedKnockout(
      roomId: widget.room.id,
    );

  final result =
      await roomService
          .getRoomMembers(
    widget.room.id,
  );

  if (!mounted) return;

  setState(() {
    members = result;
  });
  final myUsername =
    await LocalStorageService()
        .getUsername();

final me =
    result.where(
      (member) =>
          member.username ==
          myUsername,
    );

if (me.isNotEmpty) {

  setState(() {
    groupStageSubmitted = groupPrediction;
    knockoutSubmitted = knockoutPrediction;
  });
}
}

Future<void> loadSettings() async {
  final settings =
      await roomService.getRoomSettings(
    widget.room.id,
  );

  if (!mounted) return;

  setState(() {
    knockoutEnabled =
        settings?['knockout_open'] ?? false;
  });
}
Widget buildPosition(
  int position,
) {

  switch (position) {

    case 1:
      return const Text(
        '🥇',
        style: TextStyle(
          fontSize: 24,
        ),
      );

    case 2:
      return const Text(
        '🥈',
        style: TextStyle(
          fontSize: 24,
        ),
      );

    case 3:
      return const Text(
        '🥉',
        style: TextStyle(
          fontSize: 24,
        ),
      );

    default:

      return CircleAvatar(
        radius: 14,
        child: Text(
          '$position',
        ),
      );
  }
}

Future<void> loadRanking() async {

  final scores =
      await supabase
          .from('room_scores')
          .select()
          .eq(
            'room_id',
            widget.room.id,
          )
          .order(
            'total_points',
            ascending: false,
          );

  final points =
      <String, int>{};

  final positions =
      <String, int>{};

  for (
    int i = 0;
    i < scores.length;
    i++
  ) {

    final score =
        scores[i];

    points[
      score['user_id']
    ] = score['total_points'];

    positions[
      score['user_id']
    ] = i + 1;
  }

  if (!mounted) return;

  setState(() {
    userPoints = points;
    userPositions = positions;
  });
}

Future<void> showPredictionDialog(
  RoomMember member,
) async {

  final predictions =
      await supabase
          .from('predictions')
          .select()
          .eq(
            'room_id',
            widget.room.id,
          )
          .eq(
            'user_id',
            member.userId,
          );

  if (!mounted) return;

  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: Text(
          member.username,
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: buildPredictionContent(
            predictions,
          ),
        ),
      );
    },
  );
}

Widget buildPredictionContent(
  List<dynamic> predictions,
) {

  final groupPrediction =
      predictions.where(
        (p) =>
            p['prediction_type'] ==
            'group_stage',
      );

  final knockoutPrediction =
      predictions.where(
        (p) =>
            p['prediction_type'] ==
            'knockout_stage',
      );

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        if (groupPrediction.isNotEmpty)
          buildGroupSummary(
            groupPrediction.first['data'],
          ),

        const SizedBox(height: 24),

        if (knockoutPrediction.isNotEmpty)
          buildKnockoutSummary(
            knockoutPrediction.first['data'],
          ),
      ],
    ),
  );
}
Widget buildGroupSummary(
  Map data,
) {
  final tables =
      Map<String,dynamic>.from(
    data['group_tables'],
  );

  return Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [

      const Text(
        'Fase de grupos',
        style: TextStyle(
          fontWeight:
              FontWeight.bold,
        ),
      ),

      ...tables.entries.map(
        (entry) {

          final teams =
              List<String>.from(
            entry.value,
          );

          return Padding(
            padding:
                const EdgeInsets.only(
              top: 8,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  'Grupo ${entry.key}',
                ),

                ...teams.asMap().entries.map(
                  (team) =>
                      Text(
                    '${team.key + 1}. ${team.value}',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ],
  );
}
Widget buildKnockoutSummary(
  Map data,
) {

  Widget buildRound(
    String title,
    String key,
  ) {

    final matches =
        data[key] == null
            ? <dynamic>[]
            : List<dynamic>.from(
                data[key],
              );

    if (matches.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding:
          const EdgeInsets.only(
        top: 12,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style: const TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize: 15,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          ...matches.map(
            (match) {

              final home =
                  match['home_team'];

              final away =
                  match['away_team'];

              final homeGoals =
                  match['home_goals'];

              final awayGoals =
                  match['away_goals'];

              final qualified =
                  match['qualified_team'];

              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 4,
                ),
                child: Text(
                  qualified == null
                      ? '$home $homeGoals - $awayGoals $away'
                      : '$home $homeGoals - $awayGoals $away  ⭐ $qualified',
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  return Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [

      const Text(
        'Eliminatorias',
        style: TextStyle(
          fontSize: 16,
          fontWeight:
              FontWeight.bold,
        ),
      ),

      buildRound(
        'Dieciseisavos',
        'round_of_32',
      ),

      buildRound(
        'Octavos',
        'round_of_16',
      ),

      buildRound(
        'Cuartos',
        'quarter_finals',
      ),

      buildRound(
        'Semifinales',
        'semi_finals',
      ),

      buildRound(
        'Final',
        'final',
      ),

      const SizedBox(
        height: 12,
      ),

      if (data['champion'] != null)
        Text(
          '🏆 Campeón: ${data['champion']}',
          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

      if (data['runner_up'] != null)
        Text(
          '🥈 Subcampeón: ${data['runner_up']}',
          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        if (data['top_scorer'] != null)
          Text(
            '⚽ Máximo goleador: ${data['top_scorer']}',
          ),

        if (data['best_player'] != null)
          Text(
            '⭐ Mejor jugador: ${data['best_player']}',
          ),
    ],
  );
}
void showScoringRules() {

  showDialog(
    context: context,
    builder: (_) {

      return AlertDialog(
        title: const Text(
          'Sistema de puntuación',
        ),

        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: const [

                Text(
                  'FASE DE GRUPOS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                SizedBox(height: 12),

                Text(
                  'Cada partido',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8),

                Text('Resultado exacto  +3'),
                Text('Diferencia de goles  +2'),
                Text('Signo (1-X-2)  +1'),

                SizedBox(height: 16),

                Text(
                  'Clasificación final de grupos',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  'Cada posición acertada  +2',
                ),

                SizedBox(height: 16),

                Text(
                  'Equipos clasificados',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  'Cada equipo clasificado  +5',
                ),

                Divider(height: 32),

                Text(
                  'FASE ELIMINATORIA',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                SizedBox(height: 12),

                Text(
                  'Cada partido',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  'Solo si coinciden los equipos',
                ),

                SizedBox(height: 8),

                Text('Resultado exacto  +3'),
                Text('Diferencia de goles  +2'),
                Text('Clasificado  +1'),

                SizedBox(height: 16),

                Text(
                  'Equipos en rondas',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8),

                Text('Semifinalista  +10'),
                Text('Finalista  +15'),
                Text('Campeón  +20'),
                Text('Subcampeón  +15'),
                SizedBox(height: 16),

                Text(
                  'Premios individuales',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8),

                Text('Máximo goleador  +10'),
                Text('Mejor jugador  +10'),
              ],
            ),
          ),
        ),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cerrar'),
          ),
        ],
      );
    },
  );
}
Future<void> showMyPredictions() async {

  final predictions =
      await supabase
          .from('predictions')
          .select()
          .eq(
            'room_id',
            widget.room.id,
          )
          .eq(
            'user_id',
            currentUserId!,
          )
          .eq(
            'prediction_type',
            'group_stage',
          )
          .maybeSingle();

  if (predictions == null) {
    return;
  }

  final data =
      Map<String, dynamic>.from(
    predictions['data'],
  );

  if (!mounted) return;

  showDialog(
    context: context,
    builder: (_) {

      return AlertDialog(
        title: const Text(
          'Mis pronósticos',
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: buildGroupMatches(
              data,
            ),
          ),
        ),
      );
    },
  );
}
Widget buildGroupMatches(
  Map data,
) {
  final matches =
      List<dynamic>.from(
    data['group_matches'] ?? [],
  );

  final bestThirdPlaced =
      List<String>.from(
    data['best_third_placed'] ?? [],
  );

  return Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [

      const Text(
        'Partidos pronosticados',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),

      const SizedBox(height: 12),

      ...matches.map(
        (match) {

          return Padding(
            padding:
                const EdgeInsets.only(
              bottom: 6,
            ),
            child: Text(
              '[${match['group']}] '
              '${match['home_team']} '
              '${match['home_goals']} - '
              '${match['away_goals']} '
              '${match['away_team']}',
            ),
          );
        },
      ),

      const SizedBox(height: 20),

      const Divider(),

      const SizedBox(height: 12),

      const Text(
        'Mejores terceros',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),

      const SizedBox(height: 8),

      ...bestThirdPlaced.asMap().entries.map(
        (entry) => Padding(
          padding: const EdgeInsets.only(
            bottom: 4,
          ),
          child: Text(
            '${entry.key + 1}. ${entry.value}',
          ),
        ),
      ),
    ],
  );
}
}
