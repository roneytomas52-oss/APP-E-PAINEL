import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/incoming_offer_bridge_event.dart';

class IncomingOfferBridge {
  IncomingOfferBridge._();
  static final IncomingOfferBridge instance = IncomingOfferBridge._();

  static const MethodChannel _commandChannel = MethodChannel('com.sixamtech/incoming_offer_bridge/commands');
  static const EventChannel _eventChannel = EventChannel('com.sixamtech/incoming_offer_bridge/events');

  final StreamController<IncomingOfferBridgeEvent> _eventsController = StreamController<IncomingOfferBridgeEvent>.broadcast();
  StreamSubscription<dynamic>? _nativeEventSubscription;
  bool _initialized = false;

  Stream<IncomingOfferBridgeEvent> get events => _eventsController.stream;

  Future<void> initialize() async {
    if (!GetPlatform.isAndroid || _initialized) {
      return;
    }

    _nativeEventSubscription = _eventChannel.receiveBroadcastStream().listen(
      _emitDynamicEvent,
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('IncomingOfferBridge event stream error: $error');
      },
    );

    final pendingEvents = await _commandChannel.invokeMethod<List<dynamic>>('getPendingEvents');
    if (pendingEvents != null) {
      for (final dynamic event in pendingEvents) {
        _emitDynamicEvent(event);
      }
    }

    await _commandChannel.invokeMethod('bridgeReady');
    _initialized = true;
  }

  void _emitDynamicEvent(dynamic event) {
    if (event is Map) {
      _eventsController.add(IncomingOfferBridgeEvent.fromMap(event));
    }
  }
}
