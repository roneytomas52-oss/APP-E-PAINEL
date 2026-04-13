import 'package:sixam_mart_delivery/features/my_account/domain/models/loyalty_report_model.dart';

class LoyaltyPointModel {
  int? total;
  String? limit;
  String? offset;
  List<LoyalityPoints>? loyalityPoints;

  LoyaltyPointModel({this.total, this.limit, this.offset, this.loyalityPoints});

  LoyaltyPointModel.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['loyalityPoints'] != null) {
      loyalityPoints = <LoyalityPoints>[];
      json['loyalityPoints'].forEach((v) {
        loyalityPoints!.add(LoyalityPoints.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    data['limit'] = limit;
    data['offset'] = offset;
    if (loyalityPoints != null) {
      data['loyalityPoints'] = loyalityPoints!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}