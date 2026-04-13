class UpdateStatusBodyModel {
  String? token;
  int? orderId;
  String? status;
  String? otp;
  String method = 'put';
  String? reason;
  List<String>? reasons;
  String? comment;
  bool? isParcel;
  UpdateStatusBodyModel({this.token, this.orderId, this.status, this.otp, this.reason, this.reasons, this.comment, this.isParcel});

  UpdateStatusBodyModel.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    orderId = json['order_id'];
    status = json['status'];
    otp = json['otp'];
    status = json['_method'];
    reason = json['reason'];
    reasons = json['reasons'].toString().split(',');
    comment = json['note'];
    isParcel = json['is_parcel'];
  }

  Map<String, String> toJson() {
    final Map<String, String> data = <String, String>{};
    data['token'] = token!;
    data['order_id'] = orderId.toString();
    data['status'] = status!;
    data['otp'] = otp??'';
    data['_method'] = method;
    if(reason != '' && reason != null) {
      data['reason'] = reason!;
    }
    if(reasons != null) {
      data['reasons'] = reasons!.join(',');
    }
    data['note'] = comment ?? '';
    data['is_parcel'] = isParcel.toString();
    return data;
  }
}