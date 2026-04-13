enum NotificationType{
  message,
  order,
  general,
  // ignore: constant_identifier_names
  order_request,
  block,
  unblock,
  otp,
  // ignore: constant_identifier_names
  cash_collect,
  unassign,
  withdraw,
  // ignore: constant_identifier_names
  deliveryman_referral,

  /// ride_module
  // ignore: constant_identifier_names
  ride_request,
  admin,
}

class NotificationBodyModel {
  NotificationType? notificationType;
  int? orderId;
  int? customerId;
  int? vendorId;
  String? type;
  int? conversationId;
  /// Ride Module
  String? rideRequestId;
  int? adminId;
  String? action;
  String? nextLevel;
  String? rewardType;
  String? rewardAmount;

  NotificationBodyModel({
    this.notificationType,
    this.orderId,
    this.customerId,
    this.vendorId,
    this.type,
    this.conversationId,

    /// Ride Module
    this.rideRequestId,
    this.adminId,
    this.action,
    this.nextLevel,
    this.rewardAmount,
    this.rewardType
  });

  NotificationBodyModel.fromJson(Map<String, dynamic> json) {
    notificationType = convertToEnum(json['order_notification']);
    orderId = json['order_id'];
    customerId = json['customer_id'];
    vendorId = json['vendor_id'];
    type = json['type'];
    conversationId = json['conversation_id'];

    /// Ride Module
    rideRequestId = json['ride_request_id'].toString();
    adminId = json['admin_id'];
    action = json['action'];
    nextLevel = json['next_level'];
    rewardType = json['reward_type'];
    rewardAmount = json['reward_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_notification'] = notificationType.toString();
    data['order_id'] = orderId;
    data['customer_id'] = customerId;
    data['vendor_id'] = vendorId;
    data['type'] = type;
    data['conversation_id'] = conversationId;

    /// Ride Module
    data['action'] = action;
    data['ride_request_id'] = rideRequestId;
    data['admin_id'] = adminId;

    return data;
  }

  NotificationType convertToEnum(String? enumString) {
    final Map<String, NotificationType> enumMap = {
      NotificationType.general.toString(): NotificationType.general,
      NotificationType.order.toString(): NotificationType.order,
      NotificationType.order_request.toString(): NotificationType.order_request,
      NotificationType.message.toString(): NotificationType.message,
      NotificationType.block.toString(): NotificationType.block,
      NotificationType.unblock.toString(): NotificationType.unblock,
      NotificationType.otp.toString(): NotificationType.otp,
      NotificationType.cash_collect.toString(): NotificationType.cash_collect,
      NotificationType.unassign.toString(): NotificationType.unassign,
      NotificationType.withdraw.toString(): NotificationType.withdraw,
      NotificationType.deliveryman_referral.toString(): NotificationType.deliveryman_referral,

      /// Ride Module
      NotificationType.ride_request.toString(): NotificationType.ride_request,
    };

    return enumMap[enumString] ?? NotificationType.general;
  }

}