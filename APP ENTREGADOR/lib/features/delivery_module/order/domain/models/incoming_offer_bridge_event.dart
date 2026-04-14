class IncomingOfferBridgeEvent {
  final int version;
  final String event;
  final String source;
  final String type;
  final String? orderId;
  final String? notificationType;
  final int timestamp;
  final String eventId;
  final Map<String, dynamic> payload;

  const IncomingOfferBridgeEvent({
    required this.version,
    required this.event,
    required this.source,
    required this.type,
    required this.orderId,
    required this.notificationType,
    required this.timestamp,
    required this.eventId,
    required this.payload,
  });

  int? get parsedOrderId => int.tryParse(orderId ?? '');

  factory IncomingOfferBridgeEvent.fromMap(Map<dynamic, dynamic> map) {
    final payloadMap = map['payload'];
    return IncomingOfferBridgeEvent(
      version: map['version'] is int ? map['version'] as int : 1,
      event: map['event']?.toString() ?? 'offer_opened',
      source: map['source']?.toString() ?? 'android_bridge',
      type: map['type']?.toString() ?? 'unknown',
      orderId: map['order_id']?.toString(),
      notificationType: map['notification_type']?.toString(),
      timestamp: map['timestamp'] is int ? map['timestamp'] as int : DateTime.now().millisecondsSinceEpoch,
      eventId: map['event_id']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
      payload: payloadMap is Map
          ? payloadMap.map((key, value) => MapEntry(key.toString(), value))
          : <String, dynamic>{},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'event': event,
      'source': source,
      'type': type,
      'order_id': orderId,
      'notification_type': notificationType,
      'timestamp': timestamp,
      'event_id': eventId,
      'payload': payload,
    };
  }

  factory IncomingOfferBridgeEvent.fromFcm(
    Map<String, dynamic> data, {
    required String event,
    required String source,
  }) {
    final orderId = data['order_id']?.toString();
    final notificationType = data['notification_type']?.toString() ?? data['type']?.toString();

    return IncomingOfferBridgeEvent(
      version: 1,
      event: event,
      source: source,
      type: data['type']?.toString() ?? 'unknown',
      orderId: orderId,
      notificationType: notificationType,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      eventId: '${source}_${event}_${orderId ?? 'no_order'}_${data['message_id'] ?? DateTime.now().microsecondsSinceEpoch}',
      payload: Map<String, dynamic>.from(data),
    );
  }
}

class IncomingOfferBridgeEvents {
  static const String offerOpened = 'offer_opened';
  static const String offerAcceptTapped = 'offer_accept_tapped';
  static const String offerDeclineTapped = 'offer_decline_tapped';
  static const String offerExpired = 'offer_expired';
  static const String appReopenedWithOffer = 'app_reopened_with_offer';
}
