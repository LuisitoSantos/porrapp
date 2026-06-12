import 'package:flutter/material.dart';
import '../services/room_result_service.dart';
import '../../../data/world_cup_matches.dart';
import '../../prediction/models/match_prediction.dart';
import '../../tournament/services/group_stage_calculator.dart';
import '../../tournament/models/group_standing.dart';
import '../../tournament/models/score_persistence_service.dart';

class OfficialResultsScreen
    extends StatefulWidget {

  final String roomId;

  const OfficialResultsScreen({
    super.key,
    required this.roomId,
  });

  @override
  State<OfficialResultsScreen>
      createState() =>
          _OfficialResultsScreenState();
}

class _OfficialResultsScreenState
    extends State<OfficialResultsScreen> {

      final roomResultService =
      RoomResultService();

  final matches =
      worldCupMatches;

      @override
      void initState() {
        super.initState();
        loadResults();
      }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Resultados oficiales',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const Text(
            'Resultados oficiales',
            style: TextStyle(
              fontSize: 24,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          ...matches.map(
            buildMatchCard,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: saveResults,
              child: const Text(
                'Guardar resultados',
              ),
            ),
          ),
        ),
      )
    );
  }
  Widget buildMatchCard(
  MatchPrediction match,
) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
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
            ),
          ),

          const SizedBox(
            width: 12,
          ),

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
Future<void> saveResults() async {

  final groupMatches =
      matches.map(
        (match) {

      return {

        'match_number':
            match.matchNumber,

        'home_goals':
            int.tryParse(
          match.homeController.text,
        ),

        'away_goals':
            int.tryParse(
          match.awayController.text,
        ),
      };
    }).toList();

  final allMatchesCompleted =
      matches.every(
    (match) =>
        match.homeController.text.isNotEmpty &&
        match.awayController.text.isNotEmpty,
  );

  final data = <String, dynamic>{
    'group_matches': groupMatches,
  };

  if (allMatchesCompleted) {

    for (final match in matches) {

      match.homeGoals =
          int.parse(
        match.homeController.text,
      );

      match.awayGoals =
          int.parse(
        match.awayController.text,
      );
    }

    final result =
        GroupStageCalculator.calculate(
      matches,
    );

    final officialTables = {

      for (final entry
          in (result['tables']
                  as Map<String,
                      List<GroupStanding>>)
              .entries)

        entry.key:
            entry.value
                .map(
                  (team) =>
                      team.team.name,
                )
                .toList(),
    };

    final officialBestThirds =
        (result['bestThirds']
                as List<GroupStanding>)
            .map(
              (team) =>
                  team.team.name,
            )
            .toList();

    data['group_tables'] =
        officialTables;

    data['best_third_placed'] =
        officialBestThirds;

    data['groups_finished'] =
        true;
  } else {

    data['groups_finished'] =
        false;
  }

  await roomResultService
      .saveResults(
    roomId: widget.roomId,
    data: data,
  );

  await ScorePersistenceService()
    .recalculateRoomScores(
  widget.roomId,
);

  if (!mounted) return;

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(
    SnackBar(
      content: Text(
        allMatchesCompleted
            ? 'Resultados y clasificación guardados'
            : 'Resultados guardados',
      ),
    ),
  );
}


Future<void> loadResults() async {

  final results =
      await roomResultService
          .getResults(
    widget.roomId,
  );


  if (results == null) {
    return;
  }

  final groupMatches =
      results['group_matches'];

  for (final savedMatch in groupMatches) {

    final matchNumber =
        savedMatch['match_number'];

    final match =
        matches.firstWhere(
      (m) =>
          m.matchNumber ==
          matchNumber,
    );

    final homeGoals =
        savedMatch['home_goals'];

    final awayGoals =
        savedMatch['away_goals'];

    match.homeController.text =
        homeGoals?.toString() ?? '';

    match.awayController.text =
        awayGoals?.toString() ?? '';

    match.homeGoals = homeGoals;
    match.awayGoals = awayGoals;
  }

  if (mounted) {
    setState(() {});
  }
}


}