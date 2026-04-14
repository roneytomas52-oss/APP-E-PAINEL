import 'dart:developer' as developer;

class IncomingOfferRollout {
  IncomingOfferRollout._();

  /// Safe by default: native aggressive takeover stays OFF unless explicitly enabled.
  static const bool _defaultAggressiveTakeover = bool.fromEnvironment(
    'INCOMING_OFFER_AGGRESSIVE_TAKEOVER',
    defaultValue: false,
  );

  static bool? _overrideAggressiveTakeover;

  static bool get aggressiveTakeoverEnabled => _overrideAggressiveTakeover ?? _defaultAggressiveTakeover;

  static bool get hasDebugOverride => _overrideAggressiveTakeover != null;

  static void setAggressiveTakeoverForDebug(bool enabled) {
    _overrideAggressiveTakeover = enabled;
    logIncomingOffer(
      'feature_flag_updated',
      message: 'Aggressive takeover override changed',
      extra: <String, Object?>{'enabled': enabled, 'override_active': true},
    );
  }

  static void clearAggressiveTakeoverDebugOverride() {
    _overrideAggressiveTakeover = null;
    logIncomingOffer(
      'feature_flag_updated',
      message: 'Aggressive takeover override cleared',
      extra: <String, Object?>{'override_active': false, 'enabled': _defaultAggressiveTakeover},
    );
  }
}

void logIncomingOffer(
  String stage, {
  String source = 'flutter',
  String? orderId,
  String? eventId,
  String? eventToken,
  String? moduleType,
  String? type,
  String? message,
  Map<String, Object?> extra = const <String, Object?>{},
}) {
  final Map<String, Object?> payload = <String, Object?>{
    'stage': stage,
    'source': source,
    if (orderId != null && orderId.isNotEmpty) 'order_id': orderId,
    if (eventId != null && eventId.isNotEmpty) 'event_id': eventId,
    if (eventToken != null && eventToken.isNotEmpty) 'event_token': eventToken,
    if (moduleType != null && moduleType.isNotEmpty) 'module_type': moduleType,
    if (type != null && type.isNotEmpty) 'type': type,
    if (message != null && message.isNotEmpty) 'message': message,
    ...extra,
  };
  developer.log(payload.toString(), name: 'IncomingOfferTakeover');
}
