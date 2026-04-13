class OngoingOrderModel {
  List<OrderData>? data;

  OngoingOrderModel({this.data});

  OngoingOrderModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <OrderData>[];
      json['data'].forEach((v) {
        data!.add(OrderData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OrderData {
  int? id;
  String? orderType;
  String? status;
  bool? isRepeatBooking;
  String? createdAt;

  OrderData({this.id, this.orderType, this.status, this.isRepeatBooking, this.createdAt});

  OrderData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderType = json['order_type'];
    status = json['status'];
    isRepeatBooking = json['is_repeat'].toString() == '1';
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_type'] = orderType;
    data['status'] = status;
    data['created_at'] = createdAt;
    return data;
  }
}