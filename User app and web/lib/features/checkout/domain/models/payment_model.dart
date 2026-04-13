class PaymentModel {
  String? orderID;
  String? orderType;
  double? orderAmount;
  double? maxCodOrderAmount;
  bool? isCashOnDeliveryActive;
  bool? isDigitalPaymentActive;
  bool? isOfflinePaymentActive;
  String? guestId;
  String? contactNumber;
  int? zoneId;
  double? partiallyPaidAmount;
  String? paymentStatus;
  String? paymentMethod;
  int? userId;

  PaymentModel({
    this.orderID,
    this.orderType,
    this.orderAmount,
    this.maxCodOrderAmount,
    this.isCashOnDeliveryActive,
    this.isDigitalPaymentActive,
    this.isOfflinePaymentActive,
    this.guestId,
    this.contactNumber,
    this.zoneId,
    this.partiallyPaidAmount,
    this.paymentStatus,
    this.paymentMethod,
    this.userId,
});

  PaymentModel.fromJson(Map<String, dynamic> json)
      : orderID = json['order_id']?.toString(),
        orderType = json['order_type'],
        orderAmount = json['order_amount']?.toDouble()??0,
        maxCodOrderAmount = json['maximum_cod_order_amount']?.toDouble(),
        isCashOnDeliveryActive = json['cash_on_delivery'],
        isDigitalPaymentActive = json['digital_payment'],
        isOfflinePaymentActive = json['offline_payment'],
        guestId = json['guest_id'],
        contactNumber = json['contact_person_number'] ?? '',
        zoneId = json['zone_id'] ?? '',
        partiallyPaidAmount = json['partially_paid_amount']?.toDouble(),
        paymentStatus = json['payment_status'],
        paymentMethod = json['payment_method'],
        userId = int.tryParse(json['user_id'].toString());

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderID,
      'order_type': orderType,
      'order_amount': orderAmount,
      'maximum_cod_order_amount': maxCodOrderAmount,
      'cash_on_delivery': isCashOnDeliveryActive,
      'digital_payment': isDigitalPaymentActive,
      'offline_payment': isOfflinePaymentActive,
      'guest_id': guestId,
      'contact_person_number': contactNumber,
      'zone_id': zoneId,
      'partially_paid_amount': partiallyPaidAmount,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'user_id': userId,
    };
  }
}