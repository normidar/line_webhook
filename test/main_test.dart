import 'dart:convert';

import 'package:line_webhook/line_webhook.dart';
import 'package:test/test.dart';

void main() {
  group('WebhookRequestBody', () {
    test('parses a text message event', () {
      final json = jsonDecode('''
{
  "destination": "U1234567890",
  "events": [
    {
      "type": "message",
      "mode": "active",
      "timestamp": 1462629479859,
      "webhookEventId": "01FZ74A0TDDPYRVKNK77XKC3ZR",
      "deliveryContext": { "isRedelivery": false },
      "source": {
        "type": "user",
        "userId": "U4af4980629..."
      },
      "replyToken": "nHuyWiB7yP5Zw52FIkcQobQuGDXCTA",
      "message": {
        "type": "text",
        "id": "14353798921116",
        "quoteToken": "q3Plxr4AgKd...",
        "text": "Hello, world"
      }
    }
  ]
}
''') as Map<String, dynamic>;

      final body = WebhookRequestBody.fromJson(json);
      expect(body.destination, 'U1234567890');
      expect(body.events.length, 1);

      final event = body.events.first as MessageEvent;
      expect(event.replyToken, 'nHuyWiB7yP5Zw52FIkcQobQuGDXCTA');
      expect(event.deliveryContext.isRedelivery, isFalse);

      final message = event.message as TextMessage;
      expect(message.text, 'Hello, world');
      expect(message.id, '14353798921116');
    });

    test('parses a follow event', () {
      final json = jsonDecode('''
{
  "destination": "Uxxxxx",
  "events": [
    {
      "type": "follow",
      "mode": "active",
      "timestamp": 1462629479859,
      "webhookEventId": "abc123",
      "deliveryContext": { "isRedelivery": false },
      "source": { "type": "user", "userId": "Uyyy" },
      "replyToken": "token123"
    }
  ]
}
''') as Map<String, dynamic>;

      final body = WebhookRequestBody.fromJson(json);
      expect(body.events.first, isA<FollowEvent>());
    });

    test('parses an unfollow event', () {
      final json = jsonDecode('''
{
  "destination": "Uxxxxx",
  "events": [
    {
      "type": "unfollow",
      "mode": "active",
      "timestamp": 1462629479859,
      "webhookEventId": "abc123",
      "deliveryContext": { "isRedelivery": false },
      "source": { "type": "user", "userId": "Uyyy" }
    }
  ]
}
''') as Map<String, dynamic>;

      final body = WebhookRequestBody.fromJson(json);
      expect(body.events.first, isA<UnfollowEvent>());
    });

    test('parses a postback event', () {
      final json = jsonDecode('''
{
  "destination": "Uxxxxx",
  "events": [
    {
      "type": "postback",
      "mode": "active",
      "timestamp": 1462629479859,
      "webhookEventId": "abc123",
      "deliveryContext": { "isRedelivery": false },
      "source": { "type": "user", "userId": "Uyyy" },
      "replyToken": "token123",
      "postback": {
        "data": "action=buy&itemid=123"
      }
    }
  ]
}
''') as Map<String, dynamic>;

      final body = WebhookRequestBody.fromJson(json);
      final event = body.events.first as PostbackEvent;
      expect(event.postback.data, 'action=buy&itemid=123');
    });

    test('parses a group source', () {
      final json = jsonDecode('''
{
  "destination": "Uxxxxx",
  "events": [
    {
      "type": "join",
      "mode": "active",
      "timestamp": 1462629479859,
      "webhookEventId": "abc123",
      "deliveryContext": { "isRedelivery": false },
      "source": { "type": "group", "groupId": "Cxxxx" },
      "replyToken": "token123"
    }
  ]
}
''') as Map<String, dynamic>;

      final body = WebhookRequestBody.fromJson(json);
      final event = body.events.first as JoinEvent;
      expect(event.source, isA<GroupSource>());
      expect((event.source as GroupSource).groupId, 'Cxxxx');
    });
  });

  group('verifyWebhookSignature', () {
    test('returns true for a valid signature', () {
      const channelSecret = 'test_secret';
      const body = '{"destination":"U123","events":[]}';
      // Pre-computed HMAC-SHA256 of body with channelSecret, base64-encoded
      final valid = verifyWebhookSignature(
        channelSecret: channelSecret,
        body: body,
        signature: 'QwNod+IA5jCf9bAMk3oyKep/zm5QP3SEBJPHkZvZf0U=',
      );
      expect(valid, isTrue);
    });

    test('returns false for an invalid signature', () {
      final invalid = verifyWebhookSignature(
        channelSecret: 'test_secret',
        body: '{"destination":"U123","events":[]}',
        signature: 'invalidsignature==',
      );
      expect(invalid, isFalse);
    });
  });
}
