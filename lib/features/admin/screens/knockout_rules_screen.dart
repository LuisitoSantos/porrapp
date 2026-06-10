import 'package:flutter/material.dart';
import '../../tournament/config/world_cup_2026_bracket.dart';
import '../../tournament/models/bracket_match_rule.dart';
import '../../../core/supabase/supabase_client.dart';

class KnockoutRulesScreen extends StatefulWidget {
  final String roomId;

  const KnockoutRulesScreen({
    super.key,
    required this.roomId,
  });

  @override
  State<KnockoutRulesScreen> createState() =>
      _KnockoutRulesScreenState();
}

class _KnockoutRulesScreenState
    extends State<KnockoutRulesScreen> {

  final Map<int, int> selectedThirds = {};

  @override
void initState() {
  super.initState();
  loadSavedRules();
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cruces eliminatorias',
        ),
      ),

      body: Column(
        children: [

          Expanded(
            child: ListView.builder(
              itemCount:
                  worldCup2026RoundOf32.length,
              itemBuilder:
                  (context, index) {

                final rule =
                    worldCup2026RoundOf32[index];

                return buildRuleCard(
                  rule,
                  index,
                );
              },
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: saveRules,
              child: const Text(
                'Guardar cruces',
              ),
            ),
          ),
        ],
      ),
    );
  }
Widget buildRuleCard(
  BracketMatchRule rule,
  int index,
) {
  return Card(
    margin:
        const EdgeInsets.all(8),
    child: Padding(
      padding:
          const EdgeInsets.all(12),
      child: Row(
        children: [

          Expanded(
            child: Text(
              '${rule.home.group}${rule.home.position}',
            ),
          ),

          const Text('vs'),

          Expanded(
            child:
                buildAwaySlot(
              rule,
              index,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildAwaySlot(
  BracketMatchRule rule,
  int index,
) {

  final slot =
      rule.away;

  final isThirdPlace =
      slot.position == 3 &&
      slot.group?.contains(',') == true;

  if (!isThirdPlace) {

    return Text(
      '${slot.group}${slot.position}',
      textAlign: TextAlign.end,
    );
  }
  return DropdownButton<int>(
  value: selectedThirds[index],
  isExpanded: true,
  items: List.generate(
    8,
    (i) => DropdownMenuItem(
      value: i + 1,
      child: Text(
        '${i + 1}º mejor tercero',
      ),
    ),
  ),
  onChanged: (value) {
    if (value == null) return;

    setState(() {
      selectedThirds[index] = value;
    });
  },
);
}

Future<void> saveRules() async {
  final values =
    selectedThirds.values.toList();

    if (
  values.toSet().length !=
  values.length
) {
  ScaffoldMessenger.of(context)
      .showSnackBar(
    const SnackBar(
      content: Text(
        'No puede haber terceros repetidos',
      ),
    ),
  );
  return;
}

  final rules = <Map<String, dynamic>>[];

  for (
    int i = 0;
    i < worldCup2026RoundOf32.length;
    i++
  ) {

    final rule =
        worldCup2026RoundOf32[i];

    String awayRef;

    final isThirdPlace =
        rule.away.position == 3 &&
        rule.away.group?.contains(',') == true;

    if (isThirdPlace) {

      awayRef =
          'T${selectedThirds[i]}';

    } else {

      awayRef =
          '${rule.away.group}${rule.away.position}';
    }

    rules.add({
      'home':
          '${rule.home.group}${rule.home.position}',
      'away': awayRef,
    });
  }

  await supabase
      .from('room_settings')
      .update({
        'knockout_rules': rules,
      })
      .eq(
        'room_id',
        widget.roomId,
      );

  if (!mounted) return;

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(
    const SnackBar(
      content: Text(
        'Cruces guardados',
      ),
    ),
  );
}
Future<void> loadSavedRules() async {

  final settings =
      await supabase
          .from('room_settings')
          .select('knockout_rules')
          .eq(
            'room_id',
            widget.roomId,
          )
          .maybeSingle();

  final savedRules =
      settings?['knockout_rules'];

  if (
    savedRules != null &&
    savedRules is List &&
    savedRules.isNotEmpty
  ) {

    for (
      int i = 0;
      i < savedRules.length;
      i++
    ) {

      final away =
          savedRules[i]['away'];

      if (
        away is String &&
        away.startsWith('T')
      ) {

        selectedThirds[i] =
            int.parse(
              away.substring(1),
            );
      }
    }

  } else {

    int nextRank = 1;

    for (
      int i = 0;
      i < worldCup2026RoundOf32.length;
      i++
    ) {

      final rule =
          worldCup2026RoundOf32[i];

      if (
        rule.away.position == 3 &&
        rule.away.group?.contains(',') == true
      ) {

        selectedThirds[i] =
            nextRank;

        nextRank++;
      }
    }
  }

  if (mounted) {
    setState(() {});
  }
}
}