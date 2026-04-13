class LoyaltyReportModel {
  List<LoyalityPoints>? loyalityPoints;
  int? total;
  double? totalLoyaltyPointEarning;
  double? totalReferal;
  double? totalDmTips;
  double? totalDeliveryCharge;
  double? totalAdminCommission;
  String? type;
  String? limit;
  String? offset;

  LoyaltyReportModel({
    this.loyalityPoints,
    this.total,
    this.totalLoyaltyPointEarning,
    this.totalReferal,
    this.totalDmTips,
    this.totalDeliveryCharge,
    this.totalAdminCommission,
    this.type,
    this.limit,
    this.offset,
  });

  LoyaltyReportModel.fromJson(Map<String, dynamic> json) {
    if (json['loyalityPoints'] != null) {
      loyalityPoints = <LoyalityPoints>[];
      json['loyalityPoints'].forEach((v) {
        loyalityPoints!.add(LoyalityPoints.fromJson(v));
      });
    }
    total = json['total'];
    totalLoyaltyPointEarning = json['total_loyalty_point_earning']?.toDouble();
    totalReferal = json['total_referal']?.toDouble();
    totalDmTips = json['total_dm_tips']?.toDouble();
    totalDeliveryCharge = json['total_delivery_charge']?.toDouble();
    totalAdminCommission = json['total_admin_commission']?.toDouble();
    type = json['type'];
    limit = json['limit'];
    offset = json['offset'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (loyalityPoints != null) {
      data['loyalityPoints'] = loyalityPoints!.map((v) => v.toJson()).toList();
    }
    data['total'] = total;
    data['total_loyalty_point_earning'] = totalLoyaltyPointEarning;
    data['total_referal'] = totalReferal;
    data['total_dm_tips'] = totalDmTips;
    data['total_delivery_charge'] = totalDeliveryCharge;
    data['total_admin_commission'] = totalAdminCommission;
    data['type'] = type;
    data['limit'] = limit;
    data['offset'] = offset;
    return data;
  }
}

class LoyalityPoints {
  int? id;
  String? transactionId;
  String? transactionType;
  double? convertedAmount;
  int? point;
  String? createdAt;
  String? reference;
  String? type;

  LoyalityPoints({
    this.id,
    this.transactionId,
    this.transactionType,
    this.convertedAmount,
    this.point,
    this.createdAt,
    this.reference,
    this.type,
  });

  LoyalityPoints.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    transactionId = json['transaction_id'];
    transactionType = json['transaction_type'];
    convertedAmount = json['converted_amount']?.toDouble();
    point = json['point'];
    createdAt = json['created_at'];
    reference = json['reference'];
    type = json['point_conversion_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['transaction_id'] = transactionId;
    data['transaction_type'] = transactionType;
    data['converted_amount'] = convertedAmount;
    data['point'] = point;
    data['created_at'] = createdAt;
    data['reference'] = reference;
    data['point_conversion_type'] = type;
    return data;
  }
}
