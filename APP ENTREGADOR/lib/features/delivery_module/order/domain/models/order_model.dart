class PaginatedOrderModel {
  int? totalSize;
  String? limit;
  String? offset;
  List<OrderModel>? orders;

  PaginatedOrderModel({this.totalSize, this.limit, this.offset, this.orders});

  PaginatedOrderModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'].toString();
    offset = json['offset'].toString();
    if (json['orders'] != null) {
      orders = [];
      json['orders'].forEach((v) {
        orders!.add(OrderModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (orders != null) {
      data['orders'] = orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }

}

class OrderModel {
  int? id;
  int? itemCampaignId;
  int? userId;
  double? orderAmount;
  double? couponDiscountAmount;
  String? paymentStatus;
  String? orderStatus;
  double? totalTaxAmount;
  String? paymentMethod;
  String? transactionReference;
  int? deliveryAddressId;
  int? deliveryManId;
  String? orderType;
  int? storeId;
  String? createdAt;
  String? updatedAt;
  double? deliveryCharge;
  double? originalDeliveryCharge;
  String? scheduleAt;
  bool? scheduled;
  String? storeName;
  String? storeAddress;
  String? storeLat;
  String? storeLng;
  String? storeLogoFullUrl;
  String? storePhone;
  int? detailsCount;
  String? orderNote;
  bool? prescriptionOrder;
  List<String>? orderAttachmentFullUrl;
  String? chargePayer;
  String? moduleType;
  DeliveryAddress? deliveryAddress;
  DeliveryAddress? receiverDetails;
  ParcelCategory? parcelCategory;
  Customer? customer;
  double? dmTips;
  bool? cutlery;
  String? unavailableItemNote;
  String? deliveryInstruction;
  List<String>? orderProofFullUrl;
  List<Payments>? payments;
  double? storeDiscountAmount;
  bool? taxStatus;
  double? additionalCharge;
  bool? isGuest;
  double? flashAdminDiscountAmount;
  double? flashStoreDiscountAmount;
  double? extraPackagingAmount;
  double? referrerBonusAmount;
  String? storeBusinessModel;
  int? storeChatPermission;
  String? canceled;
  ParcelCancellation? parcelCancellation;
  double? bringChangeAmount;

  OrderModel({
    this.id,
    this.itemCampaignId,
    this.userId,
    this.orderAmount,
    this.couponDiscountAmount,
    this.paymentStatus,
    this.orderStatus,
    this.totalTaxAmount,
    this.paymentMethod,
    this.transactionReference,
    this.deliveryAddressId,
    this.deliveryManId,
    this.orderType,
    this.storeId,
    this.createdAt,
    this.updatedAt,
    this.deliveryCharge,
    this.originalDeliveryCharge,
    this.scheduleAt,
    this.scheduled,
    this.storeName,
    this.storeAddress,
    this.storeLat,
    this.storeLng,
    this.storeLogoFullUrl,
    this.storePhone,
    this.detailsCount,
    this.chargePayer,
    this.prescriptionOrder,
    this.orderAttachmentFullUrl,
    this.orderNote,
    this.moduleType,
    this.deliveryAddress,
    this.receiverDetails,
    this.parcelCategory,
    this.customer,
    this.dmTips,
    this.cutlery,
    this.unavailableItemNote,
    this.deliveryInstruction,
    this.orderProofFullUrl,
    this.payments,
    this.storeDiscountAmount,
    this.taxStatus,
    this.additionalCharge,
    this.isGuest,
    this.flashAdminDiscountAmount,
    this.flashStoreDiscountAmount,
    this.extraPackagingAmount,
    this.referrerBonusAmount,
    this.storeBusinessModel,
    this.storeChatPermission,
    this.canceled,
    this.parcelCancellation,
    this.bringChangeAmount,
  });

  OrderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    itemCampaignId = json['item_campaign_id'];
    userId = json['user_id'];
    orderAmount = json['order_amount']?.toDouble();
    couponDiscountAmount = json['coupon_discount_amount']?.toDouble();
    paymentStatus = json['payment_status'];
    orderStatus = json['order_status'];
    totalTaxAmount = json['total_tax_amount']?.toDouble();
    paymentMethod = json['payment_method'];
    transactionReference = json['transaction_reference'];
    deliveryAddressId = json['delivery_address_id'];
    deliveryManId = json['delivery_man_id'];
    orderType = json['order_type'];
    storeId = json['store_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deliveryCharge = json['delivery_charge']?.toDouble();
    originalDeliveryCharge = json['original_delivery_charge']?.toDouble();
    scheduleAt = json['schedule_at'];
    scheduled = json['scheduled'] == 1 ? true : false;
    storeName = json['store_name'];
    storeAddress = json['store_address'];
    storeLat = json['store_lat'];
    storeLng = json['store_lng'];
    storeLogoFullUrl = json['store_logo_full_url'];
    storePhone = json['store_phone'];
    detailsCount = json['details_count'];
    orderNote = json['order_note'];
    chargePayer = json['charge_payer'];
    moduleType = json['module_type'];
    prescriptionOrder = json['prescription_order'];
    if (json['order_attachment_full_url'] != null) {
      orderAttachmentFullUrl = <String>[];
      json['order_attachment_full_url'].forEach((v) {
        if(v != null){
          orderAttachmentFullUrl!.add(v.toString());
        }
      });
    }
    deliveryAddress = json['delivery_address'] != null ? DeliveryAddress.fromJson(json['delivery_address']) : null;
    receiverDetails = json['receiver_details'] != null ? DeliveryAddress.fromJson(json['receiver_details']) : null;
    parcelCategory = json['parcel_category'] != null ? ParcelCategory.fromJson(json['parcel_category']) : null;
    customer = json['customer'] != null ? Customer.fromJson(json['customer']) : null;
    dmTips = json['dm_tips']?.toDouble();
    cutlery = json['cutlery'];
    unavailableItemNote = json['unavailable_item_note'];
    deliveryInstruction = json['delivery_instruction'];
    if (json['order_proof_full_url'] != null) {
      orderProofFullUrl = <String>[];
      json['order_proof_full_url'].forEach((v) {
        if(v != null){
          orderProofFullUrl!.add(v.toString());
        }
      });
    }
    if (json['payments'] != null) {
      payments = <Payments>[];
      json['payments'].forEach((v) {
        payments!.add(Payments.fromJson(v));
      });
    }
    storeDiscountAmount = json['store_discount_amount']?.toDouble();
    taxStatus = json['tax_status'] == 'included' ? true : false;
    additionalCharge = json['additional_charge']?.toDouble() ?? 0;
    isGuest = json['is_guest'];
    flashAdminDiscountAmount = json['flash_admin_discount_amount']?.toDouble() ?? 0;
    flashStoreDiscountAmount = json['flash_store_discount_amount']?.toDouble() ?? 0;
    extraPackagingAmount = json['extra_packaging_amount']?.toDouble();
    referrerBonusAmount = json['ref_bonus_amount']?.toDouble();
    storeBusinessModel = json['store_business_model'];
    storeChatPermission = json['chat_permission'];
    canceled = json['canceled'];
    parcelCancellation = json['parcel_cancellation'] != null ? ParcelCancellation.fromJson(json['parcel_cancellation']) : null;
    bringChangeAmount = json['bring_change_amount']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['item_campaign_id'] = itemCampaignId;
    data['user_id'] = userId;
    data['order_amount'] = orderAmount;
    data['coupon_discount_amount'] = couponDiscountAmount;
    data['payment_status'] = paymentStatus;
    data['order_status'] = orderStatus;
    data['total_tax_amount'] = totalTaxAmount;
    data['payment_method'] = paymentMethod;
    data['transaction_reference'] = transactionReference;
    data['delivery_address_id'] = deliveryAddressId;
    data['delivery_man_id'] = deliveryManId;
    data['order_type'] = orderType;
    data['store_id'] = storeId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['delivery_charge'] = deliveryCharge;
    data['original_delivery_charge'] = originalDeliveryCharge;
    data['schedule_at'] = scheduleAt;
    data['scheduled'] = scheduled;
    data['store_name'] = storeName;
    data['store_address'] = storeAddress;
    data['store_lat'] = storeLat;
    data['store_lng'] = storeLng;
    data['store_logo_full_url'] = storeLogoFullUrl;
    data['store_phone'] = storePhone;
    data['details_count'] = detailsCount;
    data['prescription_order'] = prescriptionOrder;
    data['order_attachment_full_url'] = orderAttachmentFullUrl;
    data['order_attachment'] = chargePayer;
    data['order_note'] = orderNote;
    data['module_type'] = moduleType;
    if (deliveryAddress != null) {
      data['delivery_address'] = deliveryAddress!.toJson();
    }
    if (receiverDetails != null) {
      data['receiver_details'] = receiverDetails!.toJson();
    }
    if (parcelCategory != null) {
      data['parcel_category'] = parcelCategory!.toJson();
    }
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    data['dm_tips'] = dmTips;
    data['cutlery'] = cutlery;
    data['unavailable_item_note'] = unavailableItemNote;
    data['delivery_instruction'] = deliveryInstruction;
    data['order_proof_full_url'] = orderProofFullUrl;
    if (payments != null) {
      data['payments'] = payments!.map((v) => v.toJson()).toList();
    }
    data['store_discount_amount'] = storeDiscountAmount;
    data['additional_charge'] = additionalCharge;
    data['is_guest'] = isGuest;
    data['flash_admin_discount_amount'] = flashAdminDiscountAmount;
    data['flash_store_discount_amount'] = flashStoreDiscountAmount;
    data['extra_packaging_amount'] = extraPackagingAmount;
    data['ref_bonus_amount'] = referrerBonusAmount;
    data['store_business_model'] = storeBusinessModel;
    data['chat_permission'] = storeChatPermission;
    data['canceled'] = canceled;
    if (parcelCancellation != null) {
      data['parcel_cancellation'] = parcelCancellation!.toJson();
    }
    data['bring_change_amount'] = bringChangeAmount;
    return data;
  }
}

class DeliveryAddress {
  int? id;
  String? addressType;
  String? contactPersonNumber;
  String? address;
  String? latitude;
  String? longitude;
  int? userId;
  String? contactPersonName;
  String? createdAt;
  String? updatedAt;
  int? zoneId;
  String? streetNumber;
  String? house;
  String? floor;

  DeliveryAddress({
    this.id,
    this.addressType,
    this.contactPersonNumber,
    this.address,
    this.latitude,
    this.longitude,
    this.userId,
    this.contactPersonName,
    this.createdAt,
    this.updatedAt,
    this.zoneId,
    this.streetNumber,
    this.house,
    this.floor,
  });

  DeliveryAddress.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    addressType = json['address_type'];
    contactPersonNumber = json['contact_person_number'].toString();
    address = json['address'];
    latitude = json['latitude'].toString();
    longitude = json['longitude'].toString();
    userId = json['user_id'];
    contactPersonName = json['contact_person_name'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    zoneId = json['zone_id'] != null && json['zone_id'] != 'null' ? int.parse(json['zone_id'].toString()) : null;
    streetNumber = json['road'];
    house = json['house'];
    floor = json['floor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['address_type'] = addressType;
    data['contact_person_number'] = contactPersonNumber;
    data['address'] = address;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['user_id'] = userId;
    data['contact_person_name'] = contactPersonName;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['zone_id'] = zoneId;
    data['road'] = streetNumber;
    data['house'] = house;
    data['floor'] = floor;
    return data;
  }
}

class Customer {
  int? id;
  String? fName;
  String? lName;
  String? phone;
  String? email;
  String? imageFullUrl;
  String? createdAt;
  String? updatedAt;
  String? cmFirebaseToken;
  Customer({
    this.id,
    this.fName,
    this.lName,
    this.phone,
    this.email,
    this.imageFullUrl,
    this.createdAt,
    this.updatedAt,
    this.cmFirebaseToken,
  });

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fName = json['f_name'];
    lName = json['l_name'];
    phone = json['phone'];
    email = json['email'];
    imageFullUrl = json['image_full_url'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    cmFirebaseToken = json['cm_firebase_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['phone'] = phone;
    data['email'] = email;
    data['image_full_url'] = imageFullUrl;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['cm_firebase_token'] = cmFirebaseToken;
    return data;
  }
}

class ParcelCategory {
  int? id;
  String? imageFullUrl;
  String? name;
  String? description;
  String? createdAt;
  String? updatedAt;

  ParcelCategory({
    this.id,
    this.imageFullUrl,
    this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  ParcelCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    imageFullUrl = json['image_full_url'];
    name = json['name'];
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image_full_url'] = imageFullUrl;
    data['name'] = name;
    data['description'] = description;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Payments {
  int? id;
  int? orderId;
  double? amount;
  String? paymentStatus;
  String? paymentMethod;
  String? createdAt;
  String? updatedAt;

  Payments({
    this.id,
    this.orderId,
    this.amount,
    this.paymentStatus,
    this.paymentMethod,
    this.createdAt,
    this.updatedAt,
  });

  Payments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    amount = json['amount']?.toDouble();
    paymentStatus = json['payment_status'];
    paymentMethod = json['payment_method'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['amount'] = amount;
    data['payment_status'] = paymentStatus;
    data['payment_method'] = paymentMethod;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class ParcelCancellation {
  int? id;
  int? orderId;
  List<String>? reason;
  String? cancelBy;
  String? note;
  int? returnOtp;
  double? returnFee;
  String? returnFeePaymentStatus;
  String? returnDate;
  double? dmPenaltyFee;
  String? createdAt;
  String? updatedAt;
  int? beforePickup;
  int? setReturnDate;

  ParcelCancellation({
    this.id,
    this.orderId,
    this.reason,
    this.cancelBy,
    this.note,
    this.returnOtp,
    this.returnFee,
    this.returnFeePaymentStatus,
    this.returnDate,
    this.dmPenaltyFee,
    this.createdAt,
    this.updatedAt,
    this.beforePickup,
    this.setReturnDate,
  });

  ParcelCancellation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    reason = json['reason'] != null ? (json['reason'] is List
    ? List<String>.from(json['reason'])
    : json['reason'].toString().replaceAll('[', '').replaceAll(']', '').split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList())
    : null;
    cancelBy = json['cancel_by'];
    note = json['note'];
    returnOtp = json['return_otp'];
    returnFee = json['return_fee'] != null ? double.tryParse(json['return_fee'].toString()) : null;
    returnFeePaymentStatus = json['return_fee_payment_status'];
    returnDate = json['return_date'];
    dmPenaltyFee = json['dm_penalty_fee'] != null ? double.tryParse(json['dm_penalty_fee'].toString()) : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    beforePickup = json['before_pickup'];
    setReturnDate = json['set_return_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['reason'] = reason;
    data['cancel_by'] = cancelBy;
    data['note'] = note;
    data['return_otp'] = returnOtp;
    data['return_fee'] = returnFee;
    data['return_fee_payment_status'] = returnFeePaymentStatus;
    data['return_date'] = returnDate;
    data['dm_penalty_fee'] = dmPenaltyFee;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['before_pickup'] = beforePickup;
    data['set_return_date'] = setReturnDate;
    return data;
  }
}