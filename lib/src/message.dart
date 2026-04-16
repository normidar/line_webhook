/// An audio message.
class AudioMessage extends Message {
  const AudioMessage({
    required super.id,
    required super.quoteToken,
    required this.duration,
    required this.contentProvider,
  });

  factory AudioMessage.fromJson(Map<String, dynamic> json) {
    return AudioMessage(
      id: json['id'] as String,
      quoteToken: json['quoteToken'] as String,
      duration: json['duration'] as int,
      contentProvider: ContentProvider.fromJson(
        json['contentProvider'] as Map<String, dynamic>,
      ),
    );
  }

  final int duration;
  final ContentProvider contentProvider;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'audio',
        'id': id,
        'quoteToken': quoteToken,
        'duration': duration,
        'contentProvider': contentProvider.toJson(),
      };
}

// ── Image

class ContentProvider {
  const ContentProvider({
    required this.type,
    this.originalContentUrl,
    this.previewImageUrl,
  });

  factory ContentProvider.fromJson(Map<String, dynamic> json) {
    return ContentProvider(
      type: json['type'] as String,
      originalContentUrl: json['originalContentUrl'] as String?,
      previewImageUrl: json['previewImageUrl'] as String?,
    );
  }

  /// 'line' or 'external'
  final String type;
  final String? originalContentUrl;
  final String? previewImageUrl;

  Map<String, dynamic> toJson() => {
        'type': type,
        if (originalContentUrl != null)
          'originalContentUrl': originalContentUrl,
        if (previewImageUrl != null) 'previewImageUrl': previewImageUrl,
      };
}

/// A file message.
class FileMessage extends Message {
  const FileMessage({
    required super.id,
    required super.quoteToken,
    required this.fileName,
    required this.fileSize,
  });

  factory FileMessage.fromJson(Map<String, dynamic> json) {
    return FileMessage(
      id: json['id'] as String,
      quoteToken: json['quoteToken'] as String,
      fileName: json['fileName'] as String,
      fileSize: json['fileSize'] as int,
    );
  }

  final String fileName;
  final int fileSize;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'file',
        'id': id,
        'quoteToken': quoteToken,
        'fileName': fileName,
        'fileSize': fileSize,
      };
}

/// An image message.
class ImageMessage extends Message {
  const ImageMessage({
    required super.id,
    required super.quoteToken,
    required this.contentProvider,
    this.imageSet,
  });

  factory ImageMessage.fromJson(Map<String, dynamic> json) {
    return ImageMessage(
      id: json['id'] as String,
      quoteToken: json['quoteToken'] as String,
      contentProvider: ContentProvider.fromJson(
        json['contentProvider'] as Map<String, dynamic>,
      ),
      imageSet: json['imageSet'] != null
          ? ImageSet.fromJson(json['imageSet'] as Map<String, dynamic>)
          : null,
    );
  }

  final ContentProvider contentProvider;
  final ImageSet? imageSet;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'image',
        'id': id,
        'quoteToken': quoteToken,
        'contentProvider': contentProvider.toJson(),
        if (imageSet != null) 'imageSet': imageSet!.toJson(),
      };
}

class ImageSet {
  const ImageSet({required this.id, required this.index, required this.total});

  factory ImageSet.fromJson(Map<String, dynamic> json) {
    return ImageSet(
      id: json['id'] as String,
      index: json['index'] as int,
      total: json['total'] as int,
    );
  }

  final String id;
  final int index;
  final int total;

  Map<String, dynamic> toJson() => {'id': id, 'index': index, 'total': total};
}

/// A location message.
class LocationMessage extends Message {
  const LocationMessage({
    required super.id,
    required super.quoteToken,
    required this.latitude,
    required this.longitude,
    this.title,
    this.address,
  });

  factory LocationMessage.fromJson(Map<String, dynamic> json) {
    return LocationMessage(
      id: json['id'] as String,
      quoteToken: json['quoteToken'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      title: json['title'] as String?,
      address: json['address'] as String?,
    );
  }

  final double latitude;
  final double longitude;
  final String? title;
  final String? address;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'location',
        'id': id,
        'quoteToken': quoteToken,
        'latitude': latitude,
        'longitude': longitude,
        if (title != null) 'title': title,
        if (address != null) 'address': address,
      };
}

class Mention {
  const Mention({required this.mentionees});

  factory Mention.fromJson(Map<String, dynamic> json) {
    final list = json['mentionees'] as List<dynamic>;
    return Mention(
      mentionees: list
          .map((e) => Mentionee.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final List<Mentionee> mentionees;

  Map<String, dynamic> toJson() => {
        'mentionees': mentionees.map((m) => m.toJson()).toList(),
      };
}

class Mentionee {
  const Mentionee({
    required this.index,
    required this.length,
    required this.type,
    this.userId,
    this.isSelf,
  });

  factory Mentionee.fromJson(Map<String, dynamic> json) {
    return Mentionee(
      index: json['index'] as int,
      length: json['length'] as int,
      type: json['type'] as String,
      userId: json['userId'] as String?,
      isSelf: json['isSelf'] as bool?,
    );
  }

  final int index;
  final int length;
  final String type;
  final String? userId;
  final bool? isSelf;

  Map<String, dynamic> toJson() => {
        'index': index,
        'length': length,
        'type': type,
        if (userId != null) 'userId': userId,
        if (isSelf != null) 'isSelf': isSelf,
      };
}

// ── Video

/// Base class for all message objects in a webhook event.
sealed class Message {
  const Message({required this.id, required this.quoteToken});

  factory Message.fromJson(Map<String, dynamic> json) {
    return switch (json['type'] as String) {
      'text' => TextMessage.fromJson(json),
      'image' => ImageMessage.fromJson(json),
      'video' => VideoMessage.fromJson(json),
      'audio' => AudioMessage.fromJson(json),
      'file' => FileMessage.fromJson(json),
      'location' => LocationMessage.fromJson(json),
      'sticker' => StickerMessage.fromJson(json),
      _ => throw ArgumentError('Unknown message type: ${json['type']}'),
    };
  }

  final String id;
  final String quoteToken;

  Map<String, dynamic> toJson();
}

// ── Audio

/// A sticker message.
class StickerMessage extends Message {
  const StickerMessage({
    required super.id,
    required super.quoteToken,
    required this.packageId,
    required this.stickerId,
    required this.stickerResourceType,
    this.keywords,
    this.text,
    this.quotedMessageId,
  });

  factory StickerMessage.fromJson(Map<String, dynamic> json) {
    final keywords = json['keywords'] as List<dynamic>?;
    return StickerMessage(
      id: json['id'] as String,
      quoteToken: json['quoteToken'] as String,
      packageId: json['packageId'] as String,
      stickerId: json['stickerId'] as String,
      stickerResourceType: json['stickerResourceType'] as String,
      keywords: keywords?.map((e) => e as String).toList(),
      text: json['text'] as String?,
      quotedMessageId: json['quotedMessageId'] as String?,
    );
  }

  final String packageId;
  final String stickerId;

  /// 'STATIC', 'ANIMATION', 'SOUND', 'ANIMATION_SOUND', 'POPUP', 'POPUP_SOUND',
  /// 'NAME_TEXT', or 'PER_STICKER_TEXT'
  final String stickerResourceType;
  final List<String>? keywords;
  final String? text;
  final String? quotedMessageId;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'sticker',
        'id': id,
        'quoteToken': quoteToken,
        'packageId': packageId,
        'stickerId': stickerId,
        'stickerResourceType': stickerResourceType,
        if (keywords != null) 'keywords': keywords,
        if (text != null) 'text': text,
        if (quotedMessageId != null) 'quotedMessageId': quotedMessageId,
      };
}

// ── File

// ── Text

class TextEmoji {
  const TextEmoji({
    required this.index,
    required this.length,
    required this.productId,
    required this.emojiId,
  });

  factory TextEmoji.fromJson(Map<String, dynamic> json) {
    return TextEmoji(
      index: json['index'] as int,
      length: json['length'] as int,
      productId: json['productId'] as String,
      emojiId: json['emojiId'] as String,
    );
  }

  final int index;
  final int length;
  final String productId;
  final String emojiId;

  Map<String, dynamic> toJson() => {
        'index': index,
        'length': length,
        'productId': productId,
        'emojiId': emojiId,
      };
}

// ── Location

/// A text message.
class TextMessage extends Message {
  const TextMessage({
    required super.id,
    required super.quoteToken,
    required this.text,
    this.emojis,
    this.mention,
    this.quotedMessageId,
  });

  factory TextMessage.fromJson(Map<String, dynamic> json) {
    final emojiList = json['emojis'] as List<dynamic>?;
    return TextMessage(
      id: json['id'] as String,
      quoteToken: json['quoteToken'] as String,
      text: json['text'] as String,
      emojis: emojiList
          ?.map((e) => TextEmoji.fromJson(e as Map<String, dynamic>))
          .toList(),
      mention: json['mention'] != null
          ? Mention.fromJson(json['mention'] as Map<String, dynamic>)
          : null,
      quotedMessageId: json['quotedMessageId'] as String?,
    );
  }

  final String text;
  final List<TextEmoji>? emojis;
  final Mention? mention;
  final String? quotedMessageId;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'text',
        'id': id,
        'quoteToken': quoteToken,
        'text': text,
        if (emojis != null) 'emojis': emojis!.map((e) => e.toJson()).toList(),
        if (mention != null) 'mention': mention!.toJson(),
        if (quotedMessageId != null) 'quotedMessageId': quotedMessageId,
      };
}

// ── Sticker

/// A video message.
class VideoMessage extends Message {
  const VideoMessage({
    required super.id,
    required super.quoteToken,
    required this.duration,
    required this.contentProvider,
  });

  factory VideoMessage.fromJson(Map<String, dynamic> json) {
    return VideoMessage(
      id: json['id'] as String,
      quoteToken: json['quoteToken'] as String,
      duration: json['duration'] as int,
      contentProvider: ContentProvider.fromJson(
        json['contentProvider'] as Map<String, dynamic>,
      ),
    );
  }

  final int duration;
  final ContentProvider contentProvider;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'video',
        'id': id,
        'quoteToken': quoteToken,
        'duration': duration,
        'contentProvider': contentProvider.toJson(),
      };
}
