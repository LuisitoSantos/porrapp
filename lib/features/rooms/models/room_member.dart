class RoomMember {
final String userId;
  final String username;


  final bool isOwner;

  final bool groupStageSubmitted;
  final bool knockoutSubmitted;

  const RoomMember({
    required this.userId,
    required this.username,
    required this.isOwner,
    required this.groupStageSubmitted,
    required this.knockoutSubmitted,
  });
}