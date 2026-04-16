import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Verifies the X-Line-Signature header to ensure the request is from LINE.
///
/// [channelSecret] is your LINE channel secret.
/// [body] is the raw request body string.
/// [signature] is the value of the X-Line-Signature header.
bool verifyWebhookSignature({
  required String channelSecret,
  required String body,
  required String signature,
}) {
  final key = utf8.encode(channelSecret);
  final bytes = utf8.encode(body);
  final hmac = Hmac(sha256, key);
  final digest = hmac.convert(bytes);
  final expected = base64Encode(digest.bytes);
  return expected == signature;
}
