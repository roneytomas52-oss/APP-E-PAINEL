import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/incoming_offer_bridge_event.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/services/incoming_offer_bridge.dart';
import 'package:sixam_mart_delivery/helper/incoming_offer_dispatcher.dart' as legacy_dispatcher;

class IncomingOfferDispatcher {
  IncomingOfferDispatcher._();
  static final IncomingOfferDispatcher instance = IncomingOfferDispatcher._();

  static const Set<String> _supportedEvents = {
    IncomingOfferBridgeEvents.offerOpened,
    IncomingOfferBridgeEvents.offerAcceptTapped,
    IncomingOfferBridgeEvents.offerDeclineTapped,
    IncomingOfferBridgeEvents.offerExpired,
    IncomingOfferBridgeEvents.appReopenedWithOffer,
  };

  final Set<String> _processedEventIds = <String>{};
  StreamSubscription<IncomingOfferBridgeEvent>? _bridgeSubscription;

  Future<void> initialize() async {
    if (!GetPlatform.isAndroid) {
      return;
    }

    await IncomingOfferBridge.instance.initialize();
    _bridgeSubscription ??= IncomingOfferBridge.instance.events.listen(dispatchBridgeEvent);
  }

  void registerOfferPresenter(void Function(legacy_dispatcher.IncomingOfferPresentation presentation) presenter) {
    legacy_dispatcher.IncomingOfferDispatcher.instance.registerOfferPresenter(presenter);
  }

  void unregisterOfferPresenter() {
    legacy_dispatcher.IncomingOfferDispatcher.instance.unregisterOfferPresenter();
  }

  bool handleRemotePayload(
    Map<String, dynamic> payload, {
    required legacy_dispatcher.IncomingOfferSource source,
    bool triggerPresentation = true,
  }) {
    return legacy_dispatcher.IncomingOfferDispatcher.instance.handleRemotePayload(
      payload,
      source: source,
      triggerPresentation: triggerPresentation,
    );
  }

  void dispatchBridgeEvent(IncomingOfferBridgeEvent event) {
    if (!_supportedEvents.contains(event.event) || !_markProcessed(event.eventId)) {
      return;
    }

    switch (event.event) {
      case IncomingOfferBridgeEvents.offerOpened:
      case IncomingOfferBridgeEvents.appReopenedWithOffer:
        _dispatchToOfferFlow(event, triggerPresentation: true);
        break;
      case IncomingOfferBridgeEvents.offerAcceptTapped:
      case IncomingOfferBridgeEvents.offerDeclineTapped:
      case IncomingOfferBridgeEvents.offerExpired:
        _dispatchToOfferFlow(event, triggerPresentation: false);
        break;
      default:
        return;
    }
  }

  void dispatchFcmMessage(RemoteMessage message, {required String source}) {
    final data = Map<String, dynamic>.from(message.data);
    final String type = data['type']?.toString() ?? '';
    final bool isOfferSignal = type == 'new_order' || type == 'order_request' || type == 'assign';

    if (!isOfferSignal) {
      return;
    }

    final IncomingOfferBridgeEvent event = IncomingOfferBridgeEvent.fromFcm(
      data,
      event: IncomingOfferBridgeEvents.offerOpened,
      source: source,
    );
    if (!_markProcessed(event.eventId)) {
      return;
    }

    _dispatchToOfferFlow(event, triggerPresentation: false);
  }

  bool _markProcessed(String eventId) {
    if (_processedEventIds.contains(eventId)) {
      return false;
    }
    _processedEventIds.add(eventId);
    return true;
  }

  void _dispatchToOfferFlow(IncomingOfferBridgeEvent event, {required bool triggerPresentation}) {
    final Map<String, dynamic> payload = <String, dynamic>{
      ...event.payload,
      'event_id': event.eventId,
      'order_id': event.orderId,
      'notification_type': event.notificationType,
      'type': _resolveOfferType(event),
      'bridge_event': event.event,
      'bridge_source': event.source,
      'bridge_timestamp': event.timestamp,
    };

    handleRemotePayload(
      payload,
      source: legacy_dispatcher.IncomingOfferSource.androidBridge,
      triggerPresentation: triggerPresentation,
    );
  }

  String _resolveOfferType(IncomingOfferBridgeEvent event) {
    if (event.type == 'new_order' || event.type == 'order_request' || event.type == 'assign') {
      return event.type;
    }

    final String notificationType = event.notificationType ?? '';
    if (notificationType == 'new_order' || notificationType == 'order_request' || notificationType == 'assign') {
      return notificationType;
    }

    return event.payload['type']?.toString() ?? 'unknown';
  }
}
