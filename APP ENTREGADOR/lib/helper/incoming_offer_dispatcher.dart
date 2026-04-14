import 'dart:convert';

import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';

enum IncomingOfferEventType { newOrder, orderRequest, assign, unknown }

enum IncomingOfferSource {
  fcmForeground,
  fcmOpenedApp,
  androidBridge,
  appResume,
  unknown,
}

class IncomingOfferPresentation {
  final int orderId;
  final bool isRequest;
  final bool hideItemCount;

  const IncomingOfferPresentation({
    required this.orderId,
    required this.isRequest,
    required this.hideItemCount,
  });
}

class IncomingOfferDispatcher {
  IncomingOfferDispatcher._();

  static final IncomingOfferDispatcher instance = IncomingOfferDispatcher._();
  static const Duration _dedupeWindow = Duration(seconds: 12);

  final Map<String, DateTime> _processedEvents = <String, DateTime>{};
  void Function(IncomingOfferPresentation presentation)? _onPresentOffer;

  void registerOfferPresenter(void Function(IncomingOfferPresentation presentation) presenter) {
    _onPresentOffer = presenter;
  }

  void unregisterOfferPresenter() {
    _onPresentOffer = null;
  }

  bool handleRemotePayload(
    Map<String, dynamic> payload, {
    required IncomingOfferSource source,
    bool triggerPresentation = true,
  }) {
    final IncomingOfferSource _source = source;
    _cleanupExpiredEvents();

    final IncomingOfferEventType eventType = _resolveType(payload);
    if (eventType == IncomingOfferEventType.unknown) {
      return false;
    }

    final int? orderId = _resolveOrderId(payload);
    if (orderId == null) {
      return false;
    }

    final String dedupeKey = _buildDeduplicationKey(
      payload: payload,
      eventType: eventType,
      orderId: orderId,
    );
    if (_processedEvents.containsKey(dedupeKey)) {
      return true;
    }
    _processedEvents[dedupeKey] = DateTime.now();

    _refreshOrderState();

    final bool hideItemCount = _shouldHideItemCount(payload);
    final bool isRequest = eventType == IncomingOfferEventType.newOrder || eventType == IncomingOfferEventType.orderRequest;
    if (triggerPresentation) {
      _onPresentOffer?.call(
        IncomingOfferPresentation(orderId: orderId, isRequest: isRequest, hideItemCount: hideItemCount),
      );
    }

    return true;
  }

  IncomingOfferEventType _resolveType(Map<String, dynamic> payload) {
    final String normalizedType = (payload['type'] ?? payload['body_loc_key'] ?? '').toString().trim();
    switch (normalizedType) {
      case 'new_order':
        return IncomingOfferEventType.newOrder;
      case 'order_request':
        return IncomingOfferEventType.orderRequest;
      case 'assign':
        return IncomingOfferEventType.assign;
      default:
        return IncomingOfferEventType.unknown;
    }
  }

  int? _resolveOrderId(Map<String, dynamic> payload) {
    final dynamic orderIdValue = payload['order_id'] ?? payload['title_loc_key'];
    if (orderIdValue == null) {
      return null;
    }
    return int.tryParse(orderIdValue.toString());
  }

  bool _shouldHideItemCount(Map<String, dynamic> payload) {
    final String orderType = (payload['order_type'] ?? '').toString();
    return orderType == 'parcel_order' || orderType == 'prescription';
  }

  String _buildDeduplicationKey({
    required Map<String, dynamic> payload,
    required IncomingOfferEventType eventType,
    required int orderId,
  }) {
    final String eventSignature = (
      payload['event_id'] ??
      payload['message_id'] ??
      payload['google.message_id'] ??
      payload['timestamp'] ??
      payload['time'] ??
      payload['sent_time'] ??
      payload['created_at'] ??
      payload['updated_at'] ??
      payload['action'] ??
      ''
    ).toString();

    if (eventSignature.isNotEmpty) {
      return '${eventType.name}|$orderId|$eventSignature';
    }

    final String payloadHash = base64Url.encode(utf8.encode(jsonEncode(payload)));
    return '${eventType.name}|$orderId|$payloadHash';
  }

  void _cleanupExpiredEvents() {
    if (_processedEvents.isEmpty) {
      return;
    }

    final DateTime now = DateTime.now();
    _processedEvents.removeWhere((_, DateTime timestamp) => now.difference(timestamp) > _dedupeWindow);
  }

  void _refreshOrderState() {
    if (!Get.isRegistered<OrderController>()) {
      return;
    }

    final OrderController orderController = Get.find<OrderController>();
    orderController.getRunningOrders(orderController.offset, status: 'all');
    orderController.getOrderCount(orderController.orderType);
    orderController.getLatestOrders();
  }
}
