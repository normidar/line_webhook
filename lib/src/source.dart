/// Source for a group chat.
class GroupSource extends Source {
  const GroupSource({required this.groupId, this.userId});

  factory GroupSource.fromJson(Map<String, dynamic> json) {
    return GroupSource(
      groupId: json['groupId'] as String,
      userId: json['userId'] as String?,
    );
  }

  final String groupId;

  /// Null when the event is not associated with a specific user (e.g., join/leave).
  final String? userId;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'group',
        'groupId': groupId,
        if (userId != null) 'userId': userId,
      };
}

/// Source for a multi-person chat (room).
class RoomSource extends Source {
  const RoomSource({required this.roomId, this.userId});

  factory RoomSource.fromJson(Map<String, dynamic> json) {
    return RoomSource(
      roomId: json['roomId'] as String,
      userId: json['userId'] as String?,
    );
  }

  final String roomId;

  /// Null when the event is not associated with a specific user (e.g., join/leave).
  final String? userId;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'room',
        'roomId': roomId,
        if (userId != null) 'userId': userId,
      };
}

/// The source of a webhook event.
sealed class Source {
  const Source();

  factory Source.fromJson(Map<String, dynamic> json) {
    return switch (json['type'] as String) {
      'user' => UserSource.fromJson(json),
      'group' => GroupSource.fromJson(json),
      'room' => RoomSource.fromJson(json),
      _ => throw ArgumentError('Unknown source type: ${json['type']}'),
    };
  }

  Map<String, dynamic> toJson();
}

/// Source for a 1-on-1 chat.
class UserSource extends Source {
  const UserSource({required this.userId});

  factory UserSource.fromJson(Map<String, dynamic> json) {
    return UserSource(userId: json['userId'] as String);
  }

  final String userId;

  @override
  Map<String, dynamic> toJson() => {'type': 'user', 'userId': userId};
}
