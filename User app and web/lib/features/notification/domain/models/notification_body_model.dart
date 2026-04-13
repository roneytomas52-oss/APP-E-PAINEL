enum NotificationType{
  message,
  order,
  general,
  // ignore: constant_identifier_names
  referral_code,
  otp,
  // ignore: constant_identifier_names
  add_fund,
  block,
  unblock,
  //ignore: constant_identifier_names
  referral_earn,
  //ignore: constant_identifier_names
  cashback,
  //ignore: constant_identifier_names
  loyalty_point,
  trip,
  //ignore: constant_identifier_names
  ride_request,
}

class NotificationBodyModel {
  NotificationType? notificationType;
  int? orderId;
  int? adminId;
  int? deliverymanId;
  int? restaurantId;
  String? type;
  int? conversationId;
  int? index;
  String? image;
  String? name;
  String? receiverType;
  int? providerId;
  int? servicemanId;
  String? action;
  String? nextLevel;
  String? rewardType;
  String? rewardAmount;
  String? rideRequestId;
  String? bookingId;
  String? repeatBookingType;
  String? bookingType;
  String? postId;


  NotificationBodyModel({
    this.notificationType,
    this.orderId,
    this.adminId,
    this.deliverymanId,
    this.restaurantId,
    this.type,
    this.conversationId,
    this.index,
    this.image,
    this.name,
    this.receiverType,
    this.providerId,
    this.servicemanId,
    this.rideRequestId,
    this.action,
    this.nextLevel,
    this.rewardAmount,
    this.rewardType,
    this.bookingId,
    this.bookingType,
    this.postId,
    this.repeatBookingType
  });

  NotificationBodyModel.fromJson(Map<String, dynamic> json) {
    notificationType = convertToEnum(json['order_notification']);
    orderId = json['order_id'];
    adminId = json['admin_id'];
    deliverymanId = json['deliveryman_id'];
    restaurantId = json['restaurant_id'];
    providerId = int.tryParse(json['provider_id'].toString());
    servicemanId = json['serviceman_id'];
    type = json['type'];
    conversationId = json['conversation_id'];
    index = json['index'];
    image = json['image'];
    name = json['name'];
    receiverType = json['receiver_type'];
    rideRequestId = json['ride_request_id'].toString();
    action = json['action'];
    nextLevel = json['next_level'];
    rewardType = json['reward_type'];
    rewardAmount = json['reward_amount'];
    bookingId = json['booking_id'];
    repeatBookingType = json['repeat_type'];
    bookingType = json['booking_type'];
    postId = json['post_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_notification'] = notificationType.toString();
    data['order_id'] = orderId;
    data['admin_id'] = adminId;
    data['deliveryman_id'] = deliverymanId;
    data['restaurant_id'] = restaurantId;
    data['provider_id'] = providerId;
    data['serviceman_id'] = servicemanId;
    data['type'] = type;
    data['conversation_id'] = conversationId;
    data['index'] = index;
    data['image'] = image;
    data['name'] = name;
    data['receiver_type'] = receiverType;
    data['ride_request_id'] = rideRequestId;
    data['action'] = action;
    data['next_level'] = nextLevel;
    data['reward_type'] = rewardType;
    data['reward_amount'] = rewardAmount;
    data['booking_id'] = bookingId;
    data['repeat_type'] = repeatBookingType;
    data['booking_type'] = bookingType;
    data['post_id'] = postId;
    return data;
  }

  NotificationType convertToEnum(String? enumString) {
    final Map<String, NotificationType> enumMap = {
      NotificationType.general.toString(): NotificationType.general,
      NotificationType.order.toString(): NotificationType.order,
      NotificationType.message.toString(): NotificationType.message,
      NotificationType.referral_code.toString(): NotificationType.referral_code,
      NotificationType.otp.toString(): NotificationType.otp,
      NotificationType.add_fund.toString(): NotificationType.add_fund,
      NotificationType.block.toString(): NotificationType.block,
      NotificationType.unblock.toString(): NotificationType.unblock,
      NotificationType.referral_earn.toString(): NotificationType.referral_earn,
      NotificationType.cashback.toString(): NotificationType.cashback,
      NotificationType.loyalty_point.toString(): NotificationType.loyalty_point,
      NotificationType.trip.toString(): NotificationType.trip,
      NotificationType.ride_request.toString(): NotificationType.ride_request,
    };

    return enumMap[enumString] ?? NotificationType.general;
  }

}
