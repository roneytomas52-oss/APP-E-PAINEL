import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/incoming_offer_bridge_event.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/services/incoming_offer_bridge.dart';

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

  void dispatchBridgeEvent(IncomingOfferBridgeEvent event) {
    if (!_supportedEvents.contains(event.event)) {
      return;
    }
    _dispatch(event);
  }

  void dispatchFcmMessage(RemoteMessage message, {required String source}) {
    final data = Map<String, dynamic>.from(message.data);
    final String type = data['type']?.toString() ?? '';
    final bool isOfferSignal = type == 'new_order' || type == 'order_request' || type == 'assign';

    if (!isOfferSignal) {
      return;
    }

    final event = IncomingOfferBridgeEvent.fromFcm(
      data,
      event: IncomingOfferBridgeEvents.offerOpened,
      source: source,
    );

    _dispatch(event);
  }

  void _dispatch(IncomingOfferBridgeEvent event) {
    if (_processedEventIds.contains(event.eventId)) {
      return;
    }
    _processedEventIds.add(event.eventId);

    if (!Get.isRegistered<OrderController>()) {
      return;
    }

    final orderController = Get.find<OrderController>();
    orderController.getRunningOrders(orderController.offset, status: 'all');
    orderController.getOrderCount(orderController.orderType);
    orderController.getLatestOrders();
  }
}
