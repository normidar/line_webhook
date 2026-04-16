import 'package:line_webhook/src/message.dart';
import 'package:line_webhook/src/source.dart';

// ── Beacon event

class BeaconDetail {
  const BeaconDetail({required this.hwid, required this.type, this.dm});

  factory BeaconDetail.fromJson(Map<String, dynamic> json) {
    return BeaconDetail(
      hwid: json['hwid'] as String,
      type: json['type'] as String,
      dm: json['dm'] as String?,
    );
  }

  final String hwid;

  /// 'enter', 'banner', or 'stay'
  final String type;

  /// Device message
  final String? dm;

  Map<String, dynamic> toJson() => {
        'hwid': hwid,
        'type': type,
        if (dm != null) 'dm': dm,
      };
}

// ── Base

/// Fired when a user enters or stays in the range of a LINE Beacon.
class BeaconEvent extends WebhookEvent {
  const BeaconEvent({
    required super.mode,
    required super.timestamp,
    required super.source,
    required super.webhookEventId,
    required super.deliveryContext,
    required this.replyToken,
    required this.beacon,
  });

  factory BeaconEvent.fromJson(Map<String, dynamic> json) {
    return BeaconEvent(
      mode: json['mode'] as String,
      timestamp: json['timestamp'] as int,
      source: Source.fromJson(json['source'] as Map<String, dynamic>),
      webhookEventId: json['webhookEventId'] as String,
      deliveryContext: DeliveryContext.fromJson(
        json['deliveryContext'] as Map<String, dynamic>,
      ),
      replyToken: json['replyToken'] as String,
      beacon: BeaconDetail.fromJson(json['beacon'] as Map<String, dynamic>),
    );
  }

  final String replyToken;
  final BeaconDetail beacon;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'beacon',
        ..._base(),
        'replyToken': replyToken,
        'beacon': beacon.toJson(),
      };
}

// ── Message event

/// Delivery context for a webhook event.
class DeliveryContext {
  const DeliveryContext({required this.isRedelivery});

  factory DeliveryContext.fromJson(Map<String, dynamic> json) {
    return DeliveryContext(isRedelivery: json['isRedelivery'] as bool);
  }

  final bool isRedelivery;

  Map<String, dynamic> toJson() => {'isRedelivery': isRedelivery};
}

/// Fired when a user adds the LINE official account as a friend or unblocks it.
class FollowEvent extends WebhookEvent {
  const FollowEvent({
    required super.mode,
    required super.timestamp,
    required super.source,
    required super.webhookEventId,
    required super.deliveryContext,
    required this.replyToken,
  });

  factory FollowEvent.fromJson(Map<String, dynamic> json) {
    return FollowEvent(
      mode: json['mode'] as String,
      timestamp: json['timestamp'] as int,
      source: Source.fromJson(json['source'] as Map<String, dynamic>),
      webhookEventId: json['webhookEventId'] as String,
      deliveryContext: DeliveryContext.fromJson(
        json['deliveryContext'] as Map<String, dynamic>,
      ),
      replyToken: json['replyToken'] as String,
    );
  }

  final String replyToken;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'follow',
        ..._base(),
        'replyToken': replyToken,
      };
}

// ── MemberJoined event

class GroupMember {
  const GroupMember({required this.type, required this.userId});

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      type: json['type'] as String,
      userId: json['userId'] as String,
    );
  }

  final String type;
  final String userId;

  Map<String, dynamic> toJson() => {'type': type, 'userId': userId};
}

// ── Follow event

/// Fired when the LINE official account joins a group or room chat.
class JoinEvent extends WebhookEvent {
  const JoinEvent({
    required super.mode,
    required super.timestamp,
    required super.source,
    required super.webhookEventId,
    required super.deliveryContext,
    required this.replyToken,
  });

  factory JoinEvent.fromJson(Map<String, dynamic> json) {
    return JoinEvent(
      mode: json['mode'] as String,
      timestamp: json['timestamp'] as int,
      source: Source.fromJson(json['source'] as Map<String, dynamic>),
      webhookEventId: json['webhookEventId'] as String,
      deliveryContext: DeliveryContext.fromJson(
        json['deliveryContext'] as Map<String, dynamic>,
      ),
      replyToken: json['replyToken'] as String,
    );
  }

  final String replyToken;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'join',
        ..._base(),
        'replyToken': replyToken,
      };
}

// ── Unfollow event

/// Fired when a user removes the LINE official account from a group or room
/// chat.
class LeaveEvent extends WebhookEvent {
  const LeaveEvent({
    required super.mode,
    required super.timestamp,
    required super.source,
    required super.webhookEventId,
    required super.deliveryContext,
  });

  factory LeaveEvent.fromJson(Map<String, dynamic> json) {
    return LeaveEvent(
      mode: json['mode'] as String,
      timestamp: json['timestamp'] as int,
      source: Source.fromJson(json['source'] as Map<String, dynamic>),
      webhookEventId: json['webhookEventId'] as String,
      deliveryContext: DeliveryContext.fromJson(
        json['deliveryContext'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'leave', ..._base()};
}

// ── Join event

/// Fired when a user joins a group or room chat that the LINE official account
/// is in.
class MemberJoinedEvent extends WebhookEvent {
  const MemberJoinedEvent({
    required super.mode,
    required super.timestamp,
    required super.source,
    required super.webhookEventId,
    required super.deliveryContext,
    required this.replyToken,
    required this.joined,
  });

  factory MemberJoinedEvent.fromJson(Map<String, dynamic> json) {
    final joinedMap = json['joined'] as Map<String, dynamic>;
    final memberList = joinedMap['members'] as List<dynamic>;
    return MemberJoinedEvent(
      mode: json['mode'] as String,
      timestamp: json['timestamp'] as int,
      source: Source.fromJson(json['source'] as Map<String, dynamic>),
      webhookEventId: json['webhookEventId'] as String,
      deliveryContext: DeliveryContext.fromJson(
        json['deliveryContext'] as Map<String, dynamic>,
      ),
      replyToken: json['replyToken'] as String,
      joined: memberList
          .map((e) => GroupMember.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final String replyToken;
  final List<GroupMember> joined;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'memberJoined',
        ..._base(),
        'replyToken': replyToken,
        'joined': {'members': joined.map((m) => m.toJson()).toList()},
      };
}

// ── Leave event

/// Fired when a user leaves a group or room chat that the LINE official
/// account is in.
class MemberLeftEvent extends WebhookEvent {
  const MemberLeftEvent({
    required super.mode,
    required super.timestamp,
    required super.source,
    required super.webhookEventId,
    required super.deliveryContext,
    required this.left,
  });

  factory MemberLeftEvent.fromJson(Map<String, dynamic> json) {
    final leftMap = json['left'] as Map<String, dynamic>;
    final memberList = leftMap['members'] as List<dynamic>;
    return MemberLeftEvent(
      mode: json['mode'] as String,
      timestamp: json['timestamp'] as int,
      source: Source.fromJson(json['source'] as Map<String, dynamic>),
      webhookEventId: json['webhookEventId'] as String,
      deliveryContext: DeliveryContext.fromJson(
        json['deliveryContext'] as Map<String, dynamic>,
      ),
      left: memberList
          .map((e) => GroupMember.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final List<GroupMember> left;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'memberLeft',
        ..._base(),
        'left': {'members': left.map((m) => m.toJson()).toList()},
      };
}

/// Fired when a user sends a message.
class MessageEvent extends WebhookEvent {
  const MessageEvent({
    required super.mode,
    required super.timestamp,
    required super.source,
    required super.webhookEventId,
    required super.deliveryContext,
    required this.replyToken,
    required this.message,
  });

  factory MessageEvent.fromJson(Map<String, dynamic> json) {
    return MessageEvent(
      mode: json['mode'] as String,
      timestamp: json['timestamp'] as int,
      source: Source.fromJson(json['source'] as Map<String, dynamic>),
      webhookEventId: json['webhookEventId'] as String,
      deliveryContext: DeliveryContext.fromJson(
        json['deliveryContext'] as Map<String, dynamic>,
      ),
      replyToken: json['replyToken'] as String,
      message: Message.fromJson(json['message'] as Map<String, dynamic>),
    );
  }

  final String replyToken;
  final Message message;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'message',
        ..._base(),
        'replyToken': replyToken,
        'message': message.toJson(),
      };
}

class PostbackDetail {
  const PostbackDetail({required this.data, this.params});

  factory PostbackDetail.fromJson(Map<String, dynamic> json) {
    return PostbackDetail(
      data: json['data'] as String,
      params: json['params'] != null
          ? PostbackParams.fromJson(json['params'] as Map<String, dynamic>)
          : null,
    );
  }

  final String data;
  final PostbackParams? params;

  Map<String, dynamic> toJson() => {
        'data': data,
        if (params != null) 'params': params!.toJson(),
      };
}

// ── MemberLeft event

/// Fired when a user performs a postback action.
class PostbackEvent extends WebhookEvent {
  const PostbackEvent({
    required super.mode,
    required super.timestamp,
    required super.source,
    required super.webhookEventId,
    required super.deliveryContext,
    required this.replyToken,
    required this.postback,
  });

  factory PostbackEvent.fromJson(Map<String, dynamic> json) {
    return PostbackEvent(
      mode: json['mode'] as String,
      timestamp: json['timestamp'] as int,
      source: Source.fromJson(json['source'] as Map<String, dynamic>),
      webhookEventId: json['webhookEventId'] as String,
      deliveryContext: DeliveryContext.fromJson(
        json['deliveryContext'] as Map<String, dynamic>,
      ),
      replyToken: json['replyToken'] as String,
      postback: PostbackDetail.fromJson(
        json['postback'] as Map<String, dynamic>,
      ),
    );
  }

  final String replyToken;
  final PostbackDetail postback;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'postback',
        ..._base(),
        'replyToken': replyToken,
        'postback': postback.toJson(),
      };
}

// ── Postback event

class PostbackParams {
  const PostbackParams({
    this.date,
    this.time,
    this.datetime,
    this.newRichMenuAliasId,
    this.status,
  });

  factory PostbackParams.fromJson(Map<String, dynamic> json) {
    return PostbackParams(
      date: json['date'] as String?,
      time: json['time'] as String?,
      datetime: json['datetime'] as String?,
      newRichMenuAliasId: json['newRichMenuAliasId'] as String?,
      status: json['status'] as String?,
    );
  }

  final String? date;
  final String? time;
  final String? datetime;
  final String? newRichMenuAliasId;
  final String? status;

  Map<String, dynamic> toJson() => {
        if (date != null) 'date': date,
        if (time != null) 'time': time,
        if (datetime != null) 'datetime': datetime,
        if (newRichMenuAliasId != null)
          'newRichMenuAliasId': newRichMenuAliasId,
        if (status != null) 'status': status,
      };
}

/// Fired when a user blocks the LINE official account.
class UnfollowEvent extends WebhookEvent {
  const UnfollowEvent({
    required super.mode,
    required super.timestamp,
    required super.source,
    required super.webhookEventId,
    required super.deliveryContext,
  });

  factory UnfollowEvent.fromJson(Map<String, dynamic> json) {
    return UnfollowEvent(
      mode: json['mode'] as String,
      timestamp: json['timestamp'] as int,
      source: Source.fromJson(json['source'] as Map<String, dynamic>),
      webhookEventId: json['webhookEventId'] as String,
      deliveryContext: DeliveryContext.fromJson(
        json['deliveryContext'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'unfollow', ..._base()};
}

// ── Unsend event

class UnsendDetail {
  const UnsendDetail({required this.messageId});

  factory UnsendDetail.fromJson(Map<String, dynamic> json) {
    return UnsendDetail(messageId: json['messageId'] as String);
  }

  final String messageId;

  Map<String, dynamic> toJson() => {'messageId': messageId};
}

/// Fired when a user unsends a message.
class UnsendEvent extends WebhookEvent {
  const UnsendEvent({
    required super.mode,
    required super.timestamp,
    required super.source,
    required super.webhookEventId,
    required super.deliveryContext,
    required this.unsend,
  });

  factory UnsendEvent.fromJson(Map<String, dynamic> json) {
    return UnsendEvent(
      mode: json['mode'] as String,
      timestamp: json['timestamp'] as int,
      source: Source.fromJson(json['source'] as Map<String, dynamic>),
      webhookEventId: json['webhookEventId'] as String,
      deliveryContext: DeliveryContext.fromJson(
        json['deliveryContext'] as Map<String, dynamic>,
      ),
      unsend: UnsendDetail.fromJson(json['unsend'] as Map<String, dynamic>),
    );
  }

  final UnsendDetail unsend;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'unsend',
        ..._base(),
        'unsend': unsend.toJson(),
      };
}

// ── VideoPlayComplete event

class VideoPlayComplete {
  const VideoPlayComplete({required this.trackingId});

  factory VideoPlayComplete.fromJson(Map<String, dynamic> json) {
    return VideoPlayComplete(trackingId: json['trackingId'] as String);
  }

  final String trackingId;

  Map<String, dynamic> toJson() => {'trackingId': trackingId};
}

/// Fired when a user finishes watching a video message with a trackingId.
class VideoPlayCompleteEvent extends WebhookEvent {
  const VideoPlayCompleteEvent({
    required super.mode,
    required super.timestamp,
    required super.source,
    required super.webhookEventId,
    required super.deliveryContext,
    required this.replyToken,
    required this.videoPlayComplete,
  });

  factory VideoPlayCompleteEvent.fromJson(Map<String, dynamic> json) {
    return VideoPlayCompleteEvent(
      mode: json['mode'] as String,
      timestamp: json['timestamp'] as int,
      source: Source.fromJson(json['source'] as Map<String, dynamic>),
      webhookEventId: json['webhookEventId'] as String,
      deliveryContext: DeliveryContext.fromJson(
        json['deliveryContext'] as Map<String, dynamic>,
      ),
      replyToken: json['replyToken'] as String,
      videoPlayComplete: VideoPlayComplete.fromJson(
        json['videoPlayComplete'] as Map<String, dynamic>,
      ),
    );
  }

  final String replyToken;
  final VideoPlayComplete videoPlayComplete;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'videoPlayComplete',
        ..._base(),
        'replyToken': replyToken,
        'videoPlayComplete': videoPlayComplete.toJson(),
      };
}

/// Base class for all webhook events.
sealed class WebhookEvent {
  const WebhookEvent({
    required this.mode,
    required this.timestamp,
    required this.source,
    required this.webhookEventId,
    required this.deliveryContext,
  });

  factory WebhookEvent.fromJson(Map<String, dynamic> json) {
    return switch (json['type'] as String) {
      'message' => MessageEvent.fromJson(json),
      'unsend' => UnsendEvent.fromJson(json),
      'follow' => FollowEvent.fromJson(json),
      'unfollow' => UnfollowEvent.fromJson(json),
      'join' => JoinEvent.fromJson(json),
      'leave' => LeaveEvent.fromJson(json),
      'memberJoined' => MemberJoinedEvent.fromJson(json),
      'memberLeft' => MemberLeftEvent.fromJson(json),
      'postback' => PostbackEvent.fromJson(json),
      'videoPlayComplete' => VideoPlayCompleteEvent.fromJson(json),
      'beacon' => BeaconEvent.fromJson(json),
      _ => throw ArgumentError('Unknown event type: ${json['type']}'),
    };
  }

  /// 'active' or 'standby'
  final String mode;
  final int timestamp;
  final Source source;
  final String webhookEventId;
  final DeliveryContext deliveryContext;

  Map<String, dynamic> toJson();

  Map<String, dynamic> _base() => {
        'mode': mode,
        'timestamp': timestamp,
        'source': source.toJson(),
        'webhookEventId': webhookEventId,
        'deliveryContext': deliveryContext.toJson(),
      };
}
