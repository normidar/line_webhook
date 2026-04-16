import 'package:line_webhook/src/webhook_event.dart';

/// The request body of a LINE webhook HTTP POST request.
class WebhookRequestBody {
  const WebhookRequestBody({
    required this.destination,
    required this.events,
  });

  factory WebhookRequestBody.fromJson(Map<String, dynamic> json) {
    final eventList = json['events'] as List<dynamic>;
    return WebhookRequestBody(
      destination: json['destination'] as String,
      events: eventList
          .map((e) => WebhookEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// The channel ID of the destination bot.
  final String destination;
  final List<WebhookEvent> events;

  Map<String, dynamic> toJson() => {
        'destination': destination,
        'events': events.map((e) => e.toJson()).toList(),
      };
}
