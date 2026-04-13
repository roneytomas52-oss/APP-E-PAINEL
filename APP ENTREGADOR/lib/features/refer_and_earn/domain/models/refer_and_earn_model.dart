class ReferEarningModel {
  int? total;
  String? limit;
  String? offset;
  List<RefrealEarnings>? refrealEarnings;

  ReferEarningModel({this.total, this.limit, this.offset, this.refrealEarnings});

  ReferEarningModel.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['refrealEarnings'] != null) {
      refrealEarnings = <RefrealEarnings>[];
      json['refrealEarnings'].forEach((v) {
        refrealEarnings!.add(RefrealEarnings.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    data['limit'] = limit;
    data['offset'] = offset;
    if (refrealEarnings != null) {
      data['refrealEarnings'] = refrealEarnings!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RefrealEarnings {
  int? id;
  String? transactionId;
  double? amount;
  String? createdAt;

  RefrealEarnings({this.id, this.transactionId, this.amount, this.createdAt});

  RefrealEarnings.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    transactionId = json['transaction_id'];
    amount = json['amount']?.toDouble();
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['transaction_id'] = transactionId;
    data['amount'] = amount;
    data['created_at'] = createdAt;
    return data;
  }
}