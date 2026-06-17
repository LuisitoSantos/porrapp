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
Map<String, int> previousPositions = {};

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
                color: member.userId == currentUserId
                ? Colors.blue.shade50
                : null,
                child: ListTile(
                  onTap: () async {
                    showPredictionDialog(member);
                  },

                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      buildPosition(
                        userPositions[member.userId] ?? 0,
                      ),

                      const SizedBox(width: 4),

                      buildPositionMovement(
                        member.userId,
                      ),
                    ],
                  ),

                  title: Row(
                    children: [

                      Expanded(
                        child: Text(
                          member.username,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),

                      if (member.isOwner)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.admin_panel_settings,
                            size: 16,
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
                        color: member.groupStageSubmitted
                            ? Colors.green
                            : Colors.orange,
                        size: 14,
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
                        size: 14,
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
                      builder: (_) => GroupStageScreen(
                        roomId: widget.room.id,
                      ),
                    ),
                  );

                  await refreshLobby();
                },
                child: const Text(
                  'Completar fase de grupos',
                ),
              ),

            if (knockoutEnabled &&
                !knockoutSubmitted) ...[
              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => KnockoutScreen(
                        roomId: widget.room.id,
                      ),
                    ),
                  );

                  await refreshLobby();
                },
                child: const Text(
                  'Completar eliminatorias',
                ),
              ),
            ],
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
            'position',
            ascending: true,
          );

  final points =
      <String, int>{};

  final positions =
      <String, int>{};

  final previous =
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
    ] =
        score['position'] ?? (i + 1);

    previous[
      score['user_id']
    ] =
        score['previous_position'] ?? 0;
  }

  if (!mounted) return;

  setState(() {

    userPoints = points;

    userPositions = positions;

    previousPositions = previous;

    members.sort(
      (a, b) =>
          (userPositions[a.userId] ?? 999)
              .compareTo(
        userPositions[b.userId] ?? 999,
      ),
    );
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

  final officialResults =
    await supabase
        .from('room_results')
        .select()
        .eq(
          'room_id',
          widget.room.id,
        )
        .maybeSingle();

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
            officialResults?['data'],
          )
        ),
      );
    },
  );
}

Widget buildPredictionContent(
  List<dynamic> predictions,
  Map? officialData,
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

  final groupData =
      groupPrediction.isNotEmpty
          ? Map<String, dynamic>.from(
              groupPrediction.first['data'],
            )
          : null;

  final knockoutData =
      knockoutPrediction.isNotEmpty
          ? Map<String, dynamic>.from(
              knockoutPrediction.first['data'],
            )
          : null;

  final widgets = <Widget>[];

  final groupsFinished =
      officialData?['groups_finished'] == true;

  final bestThirdPlaced =
      List<String>.from(
    groupData?['best_third_placed'] ?? [],
  );

  // ==========================
  // YA EXISTE PORRA ELIMINATORIAS
  // ==========================

  if (knockoutData != null) {

    widgets.add(
      buildKnockoutSummary(
        knockoutData,
        officialData,
      ),
    );

    widgets.add(
      const SizedBox(height: 24),
    );

    if (groupData != null) {

      widgets.add(
        buildGroupSummary(
          groupData,
          officialData,
        ),
      );

      widgets.add(
        const SizedBox(height: 16),
      );
/*
      addBestThirdPlaced(
        widgets,
        bestThirdPlaced,
      );*/

      widgets.add(
        buildGroupMatches(
          groupData,
          officialData,
        ),
      );
    }
  }

  // ==========================
  // GRUPOS TERMINADOS
  // ==========================

  else if (groupsFinished) {

    if (groupData != null) {

      widgets.add(
        buildGroupSummary(
          groupData,
          officialData,
        ),
      );

      widgets.add(
        const SizedBox(height: 16),
      );
/*
      addBestThirdPlaced(
        widgets,
        bestThirdPlaced,
      );*/

      widgets.add(
        buildGroupMatches(
          groupData,
          officialData,
        ),
      );
    }
  }

  // ==========================
  // GRUPOS EN JUEGO
  // ==========================

  else {

  if (groupData != null) {

    widgets.add(
      buildGroupMatches(
        groupData,
        officialData,
      ),
    );

    widgets.add(
      const SizedBox(height: 16),
    );

    widgets.add(
      buildGroupSummary(
        groupData,
        officialData,
      ),
    );

    widgets.add(
      const SizedBox(height: 16),
    );

/*
    addBestThirdPlaced(
      widgets,
      bestThirdPlaced,
    );
    */
  }
}

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: widgets,
    ),
  );
}
void addBestThirdPlaced(
  List<Widget> widgets,
  List<String> bestThirdPlaced,
) {

  if (bestThirdPlaced.isEmpty) {
    return;
  }

  widgets.add(
    const Text(
      'Mejores terceros',
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  widgets.add(
    const SizedBox(height: 8),
  );

  widgets.addAll(
    bestThirdPlaced.map(
      (team) => Text(team),
    ),
  );

  widgets.add(
    const SizedBox(height: 16),
  );
}
Widget buildGroupSummary(
  Map data,
  Map? officialData,
) {
  final tables =
      Map<String,dynamic>.from(
    data['group_tables'],
  );

  final officialTables =
    Map<String,dynamic>.from(
  officialData?['group_tables'] ?? {},
);

final bestThirdPlaced =
      List<String>.from(
    data['best_third_placed'] ?? [],
  );

  return Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
      const Divider(),

      const SizedBox(height: 12),

      const Text(
        'Fase de grupos',
        style: TextStyle(
          fontWeight:
              FontWeight.bold,
              fontSize: 18
        ),
      ),

      ...tables.entries.map(
        (entry) {

          final teams =
              List<String>.from(
            entry.value,
          );

          final officialTeams =
              List<String>.from(
            officialTables[entry.key] ?? [],
          );

          final perfectGroup =
              teams.length == officialTeams.length &&
              List.generate(
                teams.length,
                (i) => teams[i] == officialTeams[i],
              ).every((e) => e);

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
                (team) {

                  final officialTeams =
                      List<String>.from(
                    officialTables[entry.key] ?? [],
                  );

                  int points = 0;
                  final predictedPosition = team.key;

                  final officialPosition =
                      officialTeams.indexOf(
                    team.value,
                  );

                  final officialBestThirds =
                      List<String>.from(
                    officialData?['best_third_placed'] ?? [],
                  );

                  final predictedTeam = team.value;

                  final qualifiedOfficially =
                      (officialPosition >= 0 &&
                          officialPosition < 2) ||
                      officialBestThirds.contains(
                        predictedTeam,
                      );

                  final qualifiedPredicted =
                      predictedPosition < 2 ||
                      bestThirdPlaced.contains(
                        predictedTeam,
                      );

                  // Posición exacta
                  if (
                    officialPosition != -1 &&
                    officialPosition == predictedPosition
                  ) {

                    points = 2;

                  }

                  // Clasificado pero en otra posición
                  else if (
                    qualifiedPredicted &&
                    qualifiedOfficially
                  ) {

                    points = 1;
                  }

                  return Row(
                    children: [

                      Expanded(
                        child: Text(
                          '${team.key + 1}. ${team.value}',
                        ),
                      ),

                      if (
                        officialData != null &&
                        officialData['groups_finished'] == true
                      )
                        Text(
                          '+$points',
                          style: TextStyle(
                            color: points > 0
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  );
                },
              ),
              if (
                officialData != null &&
                officialData['groups_finished'] == true &&
                perfectGroup
              )
                Row(
                  children: const [

                    Expanded(
                      child: Text(
                        'Bonus grupo completo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Text(
                      '+2',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      const SizedBox(height: 10),

      const Divider(),

      const SizedBox(height: 10),

      if (data['best_third_placed'] != null) ...[

        const Text(
          'Mejores terceros',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        ...List<String>.from(
          data['best_third_placed'],
        ).asMap().entries.map(
          (entry) {

            bool correct = false;

            if (
              officialData != null &&
              officialData['best_third_placed'] != null
            ) {

              final officialThirds =
                  List<String>.from(
                officialData['best_third_placed'],
              );

              correct =
                  officialThirds.contains(
                entry.value,
              );
            }

            return Row(
              children: [

                Expanded(
                  child: Text(
                    '${entry.key + 1}. ${entry.value}',
                  ),
                ),
              ],
            );
          },
        ),
      ],
      
    ],
  );
}
Widget buildKnockoutSummary(
  Map data,
  Map? officialData,
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

    final officialMatches =
        List<dynamic>.from(
      officialData?[key] ?? [],
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

                  final officialMatch =
                officialMatches.where(
                  (m) =>
                      m['match_number'] ==
                      match['match_number'],
                ).firstOrNull;

                int points = 0;

                  if (officialMatch != null) {
                  points = calculateKnockoutPoints(
                    match,
                    officialMatch,
                  );
                }

              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 4,
                ),
                child: Row(
                  children: [

                    Expanded(
                      child: Text(
                        qualified == null
                            ? '$home $homeGoals - $awayGoals $away'
                            : '$home $homeGoals - $awayGoals $away ⭐ $qualified',
                      ),
                    ),

                    if (
                      officialMatch != null &&
                      officialMatch['home_goals'] != null &&
                      officialMatch['away_goals'] != null
                    )
                      Text(
                        '+$points',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: points == 3
                              ? Colors.green
                              : points == 2
                                  ? Colors.orange
                                  : points == 1
                                      ? Colors.blue
                                      : Colors.red,
                        ),
                      ),
                  ],
                )
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
                    fontSize: 22,
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

                Text('Resultado exacto  +4'),
                Text('Diferencia de goles  +3'),
                Text('Signo (1-X-2)  +2'),

                SizedBox(height: 16),

                Text(
                  'Clasificación final de grupos',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8),

                Text('Posición exacta +2'),
                Text('Clasificado pero posición incorrecta +1'),
                Text('Grupo completo correcto +2'),

                SizedBox(height: 8),

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

                Text('Resultado exacto  +4'),
                Text('Diferencia de goles  +3'),
                Text('Clasificado  +2'),
                Text('En caso de empate, se suma otro +1 si se acierta el equipo que clasifica'),

                SizedBox(height: 16),

                Text(
                  'Equipos en rondas',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8),
                Text('Equipo en octavos +5'),
                Text('Equipo en cuartos +5'),
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

Widget buildGroupMatches(
  Map data,
  Map? officialData,
) {
  final matches =
      List<dynamic>.from(
    data['group_matches'] ?? [],
  );

  final officialMatches =
    List<dynamic>.from(
  officialData?['group_matches'] ?? [],
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

          final officialMatch =
    officialMatches.where(
      (m) =>
          m['match_number'] ==
          match['match_number'],
    ).firstOrNull;

int points = 0;

if (officialMatch != null) {

  points = calculateMatchPoints(
    match['home_goals'],
    match['away_goals'],
    officialMatch['home_goals'],
    officialMatch['away_goals'],
  );
}

Color color;
/*
switch (points) {
  case 4:
    color = Colors.green;
    break;

  case 3:
    color = Colors.green;
    break;

  case 2:
    color = Colors.green;
    break;

  default:
    color = Colors.red;
}*/

switch (points) {
  case 0:
    color = Colors.red;
    break;
  default:
    color = Colors.green;
}

      return Padding(
        padding: const EdgeInsets.only(
          bottom: 6,
        ),
        child: Row(
          children: [

            Expanded(
              child: Text(
                '[${match['group']}] '
                '${match['home_team']} '
                '${match['home_goals']} - '
                '${match['away_goals']} '
                '${match['away_team']}',
              ),
            ),

            if (
              officialMatch != null &&
              officialMatch['home_goals'] != null &&
              officialMatch['away_goals'] != null
            )
              Text(
                '+$points',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              const Icon(
                Icons.schedule,
                size: 16,
                color: Colors.grey,
              ),
          ],
        ),
      );
        },
      ),

      const SizedBox(height: 10),
    ],
  );
}

  int calculateMatchPoints(
  int? predictedHome,
  int? predictedAway,
  int? officialHome,
  int? officialAway,
) {
  if (
    predictedHome == null ||
    predictedAway == null ||
    officialHome == null ||
    officialAway == null
  ) {
    return 0;
  }

  final predictedDiff =
      predictedHome - predictedAway;

  final officialDiff =
      officialHome - officialAway;

  final predictedWinner =
      predictedDiff.sign;

  final officialWinner =
      officialDiff.sign;

  if (
    predictedHome == officialHome &&
    predictedAway == officialAway
  ) {
    //return 3;
    return 4;
  }

  if (
    predictedDiff == officialDiff
  ) {
    //return 2;
    return 3;
  }

  if (
    predictedWinner == officialWinner
  ) {
    //return 1;
    return 2;
  }

  return 0;
}

int calculateKnockoutPoints(
  Map prediction,
  Map official,
) {
  final predictedHome =
      prediction['home_goals'];

  final predictedAway =
      prediction['away_goals'];

  final officialHome =
      official['home_goals'];

  final officialAway =
      official['away_goals'];

  if (
    predictedHome == null ||
    predictedAway == null ||
    officialHome == null ||
    officialAway == null
  ) {
    return 0;
  }

  final predictedQualified =
      prediction['qualified_team'];

  final officialQualified =
      official['qualified_team'];

  // Resultado exacto
  if (
    predictedHome == officialHome &&
    predictedAway == officialAway
  ) {

    int points = 4;

    // Si el resultado exacto es empate,
    // también premiamos acertar quién pasa.
    if (
      officialHome == officialAway &&
      predictedQualified != null &&
      predictedQualified ==
          officialQualified
    ) {
      points += 2;
    }

    return points;
  }

  int points = 0;

  final predictedDiff =
      predictedHome - predictedAway;

  final officialDiff =
      officialHome - officialAway;

  // Diferencia
  if (
    predictedDiff == officialDiff
  ) {
    points += 3;
  }

  // Clasificado
  if (
    predictedQualified != null &&
    predictedQualified ==
        officialQualified
  ) {
    points += 2;
  }

  return points;
}
Widget buildPositionChange(
  String userId,
) {

  final current =
      userPositions[userId];

  final previous =
      previousPositions[userId];

  if (
    current == null ||
    previous == null
  ) {
    return const SizedBox();
  }

  if (current < previous) {
    return const Icon(
      Icons.arrow_upward,
      color: Colors.green,
      size: 18,
    );
  }

  if (current > previous) {
    return const Icon(
      Icons.arrow_downward,
      color: Colors.red,
      size: 18,
    );
  }

  return const Icon(
    Icons.remove,
    color: Colors.grey,
    size: 18,
  );
}
Widget buildPositionMovement(
  String userId,
) {

  final current =
      userPositions[userId] ?? 0;

  final previous =
      previousPositions[userId] ?? current;

  if (previous == 0) {
    return const SizedBox();
  }

  final difference =
      (previous - current).abs();

  if (current < previous) {

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [

        const Icon(
          Icons.arrow_upward,
          color: Colors.green,
          size: 12,
        ),

        Text(
          '$difference',
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  if (current > previous) {

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [

        const Icon(
          Icons.arrow_downward,
          color: Colors.red,
          size: 12,
        ),

        Text(
          '$difference',
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  return const Icon(
    Icons.remove,
    color: Colors.grey,
    size: 18,
  );
}
}
