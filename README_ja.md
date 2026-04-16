# line_webhook

[![GitHub](https://img.shields.io/github/license/normidar/line_webhook.svg)](https://github.com/normidar/line_webhook/blob/main/LICENSE)
[![pub package](https://img.shields.io/pub/v/line_webhook.svg)](https://pub.dartlang.org/packages/line_webhook)
[![GitHub Stars](https://img.shields.io/github/stars/normidar/line_webhook.svg)](https://github.com/normidar/line_webhook/stargazers)

LINE Messaging API の Webhook を Dart で処理するためのパッケージです。

[English](README.md)

## 機能

- Webhook リクエストボディの JSON パース
- `X-Line-Signature` ヘッダーによる署名検証 (HMAC-SHA256)
- 全 Webhook イベント型に対応 (sealed class によるパターンマッチ)

## インストール

`pubspec.yaml` に追加してください：

```yaml
dependencies:
  line_webhook: ^0.1.0
```

## 使い方

### 署名の検証

LINE プラットフォーム以外からの不正なリクエストを弾くため、**必ず署名を検証してください**。

```dart
import 'package:line_webhook/line_webhook.dart';

bool handleRequest(String body, String signatureHeader) {
  final isValid = verifyWebhookSignature(
    channelSecret: 'YOUR_CHANNEL_SECRET',
    body: body,               // リクエストボディの生文字列
    signature: signatureHeader, // X-Line-Signature ヘッダーの値
  );

  if (!isValid) {
    // 403 を返すなど不正リクエストとして処理する
    return false;
  }

  // ...
  return true;
}
```

### リクエストボディのパース

```dart
import 'dart:convert';
import 'package:line_webhook/line_webhook.dart';

void handleWebhook(String rawBody) {
  final json = jsonDecode(rawBody) as Map<String, dynamic>;
  final body = WebhookRequestBody.fromJson(json);

  print('destination: ${body.destination}');

  for (final event in body.events) {
    handleEvent(event);
  }
}
```

### イベントの処理

`WebhookEvent` は sealed class なので、`switch` 式でコンパイル時に網羅性が保証されます。

```dart
void handleEvent(WebhookEvent event) {
  switch (event) {
    case MessageEvent():
      handleMessage(event);
    case FollowEvent():
      print('フォローされました: ${(event.source as UserSource).userId}');
    case UnfollowEvent():
      print('ブロックされました');
    case JoinEvent():
      print('グループに追加されました');
    case LeaveEvent():
      print('グループから削除されました');
    case PostbackEvent():
      print('ポストバック: ${event.postback.data}');
    case MemberJoinedEvent():
      print('メンバーが参加しました');
    case MemberLeftEvent():
      print('メンバーが退出しました');
    case UnsendEvent():
      print('メッセージが取り消されました: ${event.unsend.messageId}');
    case VideoPlayCompleteEvent():
      print('動画視聴完了: ${event.videoPlayComplete.trackingId}');
    case BeaconEvent():
      print('ビーコン: ${event.beacon.hwid}');
  }
}
```

### メッセージの処理

`Message` も sealed class です。

```dart
void handleMessage(MessageEvent event) {
  switch (event.message) {
    case TextMessage(:final text):
      print('テキスト: $text');
    case ImageMessage():
      print('画像 (ID: ${event.message.id})');
    case VideoMessage(:final duration):
      print('動画 (${duration}ms)');
    case AudioMessage(:final duration):
      print('音声 (${duration}ms)');
    case FileMessage(:final fileName, :final fileSize):
      print('ファイル: $fileName ($fileSize bytes)');
    case LocationMessage(:final latitude, :final longitude):
      print('位置情報: $latitude, $longitude');
    case StickerMessage(:final packageId, :final stickerId):
      print('スタンプ: $packageId / $stickerId');
  }
}
```

### 送信元の判定

```dart
void checkSource(WebhookEvent event) {
  switch (event.source) {
    case UserSource(:final userId):
      print('1対1トーク: $userId');
    case GroupSource(:final groupId, :final userId):
      print('グループ: $groupId (user: $userId)');
    case RoomSource(:final roomId, :final userId):
      print('複数人トーク: $roomId (user: $userId)');
  }
}
```

### 再送 Webhook の検出

```dart
if (event.deliveryContext.isRedelivery) {
  // 重複処理を避けるため webhookEventId で冪等性チェックを行う
  print('再送イベント: ${event.webhookEventId}');
}
```

### shelf を使った完全な例

```dart
import 'dart:convert';
import 'package:line_webhook/line_webhook.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

const channelSecret = 'YOUR_CHANNEL_SECRET';

Handler get app => const Pipeline().addHandler(_handler);

Future<Response> _handler(Request request) async {
  if (request.method != 'POST') {
    return Response(405);
  }

  final body = await request.readAsString();
  final signature = request.headers['x-line-signature'] ?? '';

  if (!verifyWebhookSignature(
    channelSecret: channelSecret,
    body: body,
    signature: signature,
  )) {
    return Response.forbidden('Invalid signature');
  }

  final webhookBody = WebhookRequestBody.fromJson(
    jsonDecode(body) as Map<String, dynamic>,
  );

  for (final event in webhookBody.events) {
    // イベントを処理する
    handleEvent(event);
  }

  return Response.ok('OK');
}

void main() async {
  await io.serve(app, 'localhost', 8080);
  print('サーバー起動: http://localhost:8080');
}
```

## 対応イベント

| イベント | クラス |
|---|---|
| メッセージ | `MessageEvent` |
| 送信取消 | `UnsendEvent` |
| フォロー | `FollowEvent` |
| フォロー解除 (ブロック) | `UnfollowEvent` |
| 参加 | `JoinEvent` |
| 退出 | `LeaveEvent` |
| メンバー参加 | `MemberJoinedEvent` |
| メンバー退出 | `MemberLeftEvent` |
| ポストバック | `PostbackEvent` |
| 動画視聴完了 | `VideoPlayCompleteEvent` |
| ビーコン | `BeaconEvent` |

## 対応メッセージ型

`TextMessage` / `ImageMessage` / `VideoMessage` / `AudioMessage` / `FileMessage` / `LocationMessage` / `StickerMessage`
