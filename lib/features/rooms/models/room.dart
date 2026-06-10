class Room {

  final String id;
  final String name;
  final String code;
  final String ownerId;

  final bool knockoutEnabled;

final dynamic knockoutBracket;

final bool groupStageOpen;
  final bool knockoutOpen;

  Room({
  required this.id,
  required this.name,
  required this.code,
  required this.ownerId,
  required this.knockoutEnabled,
  this.knockoutBracket,
  required this.groupStageOpen,
  required this.knockoutOpen,
});

  factory Room.fromJson(
  Map<String, dynamic> json,
) {
  return Room(
    id: json['id'],
    name: json['name'],
    code: json['code'],
    ownerId: json['owner_id'],
    knockoutEnabled:
        json['knockout_enabled'] ?? false,
    knockoutBracket:
        json['knockout_bracket'],
    groupStageOpen:
        json['group_stage_open'] ?? false,
    knockoutOpen:
        json['knockout_open'] ?? false,
  );
}
}