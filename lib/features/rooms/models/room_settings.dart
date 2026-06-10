class RoomSettings {

  final String roomId;

  final bool knockoutEnabled;

  final String currentPhase;

  RoomSettings({
    required this.roomId,
    required this.knockoutEnabled,
    required this.currentPhase,
  });

  factory RoomSettings.fromJson(
    Map<String, dynamic> json,
  ) {
    return RoomSettings(
      roomId: json['room_id'],
      knockoutEnabled:
          json['knockout_enabled'],
      currentPhase:
          json['current_phase'],
    );
  }
}