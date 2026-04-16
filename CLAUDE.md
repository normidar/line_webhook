# CLAUDE.md

## Package overview

`line_webhook` is a Dart package for parsing and verifying LINE Messaging API Webhook requests. It has no runtime dependencies beyond `crypto`.

## File structure

```
lib/
  line_webhook.dart          # Public entry point — exports everything below
  src/
    source.dart              # sealed Source + UserSource, GroupSource, RoomSource
    message.dart             # sealed Message + all 7 message subtypes
    webhook_event.dart       # sealed WebhookEvent + all 11 event subtypes, DeliveryContext
    webhook_request_body.dart# WebhookRequestBody (top-level JSON wrapper)
    webhook_signature.dart   # verifyWebhookSignature()
test/
  main_test.dart
```

## Key design decisions

- **Sealed classes in a single file**: Dart's `sealed` keyword restricts subclassing to the same library. All subtypes of `Source`, `Message`, and `WebhookEvent` are defined in the same file as their parent to allow this.
- **No code generation**: All JSON parsing is hand-written `fromJson`/`toJson`. Do not introduce `json_serializable` or similar without discussion.
- **No added dependencies**: Keep the dependency list minimal. Only add a dependency if there is a strong reason.

## Adding a new event type

1. Add a new class in `lib/src/webhook_event.dart` extending `WebhookEvent`.
2. Add the new type string to the `switch` in `WebhookEvent.fromJson()`.
3. Add a test case in `test/main_test.dart`.

## Adding a new message type

1. Add a new class in `lib/src/message.dart` extending `Message`.
2. Add the new type string to the `switch` in `Message.fromJson()`.
3. Add a test case in `test/main_test.dart`.

## Running tests

```sh
fvm dart test
```

## Signature verification

`verifyWebhookSignature()` computes `HMAC-SHA256(channelSecret, rawBody)` and base64-encodes the result, then compares it to the `X-Line-Signature` header. The raw body string (before any JSON decoding) must be passed — decoding and re-encoding JSON will change whitespace and break the comparison.
