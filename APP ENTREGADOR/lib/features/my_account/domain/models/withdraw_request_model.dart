class WithdrawRequestModel {
  int? id;
  int? vendorId;
  int? adminId;
  String? transactionNote;
  double? amount;
  String? updatedAt;
  int? deliveryManId;
  int? withdrawalMethodId;
  String? withdrawalMethodFields;
  String? type;
  String? status;
  String? requestedAt;
  String? bankName;
  Method? method;

  WithdrawRequestModel({
    this.id,
    this.vendorId,
    this.adminId,
    this.transactionNote,
    this.amount,
    this.updatedAt,
    this.deliveryManId,
    this.withdrawalMethodId,
    this.withdrawalMethodFields,
    this.type,
    this.status,
    this.requestedAt,
    this.bankName,
    this.method,
  });

  WithdrawRequestModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    vendorId = json['vendor_id'];
    adminId = json['admin_id'];
    transactionNote = json['transaction_note'];
    amount = json['amount']?.toDouble();
    updatedAt = json['updated_at'];
    deliveryManId = json['delivery_man_id'];
    withdrawalMethodId = json['withdrawal_method_id'];
    withdrawalMethodFields = json['withdrawal_method_fields'];
    type = json['type'];
    status = json['status'];
    requestedAt = json['requested_at'];
    bankName = json['bank_name'];
    method = json['method'] != null ? Method.fromJson(json['method']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['vendor_id'] = vendorId;
    data['admin_id'] = adminId;
    data['transaction_note'] = transactionNote;
    data['amount'] = amount;
    data['updated_at'] = updatedAt;
    data['delivery_man_id'] = deliveryManId;
    data['withdrawal_method_id'] = withdrawalMethodId;
    data['withdrawal_method_fields'] = withdrawalMethodFields;
    data['type'] = type;
    data['status'] = status;
    data['requested_at'] = requestedAt;
    data['bank_name'] = bankName;
    if (method != null) {
      data['method'] = method!.toJson();
    }
    return data;
  }
}

class Method {
  int? id;
  String? methodName;
  List<MethodFields>? methodFields;
  int? isDefault;
  int? isActive;
  String? createdAt;
  String? updatedAt;

  Method({
    this.id,
    this.methodName,
    this.methodFields,
    this.isDefault,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  Method.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    methodName = json['method_name'];
    if (json['method_fields'] != null) {
      methodFields = <MethodFields>[];
      json['method_fields'].forEach((v) {
        methodFields!.add(MethodFields.fromJson(v));
      });
    }
    isDefault = json['is_default'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['method_name'] = methodName;
    if (methodFields != null) {
      data['method_fields'] = methodFields!.map((v) => v.toJson()).toList();
    }
    data['is_default'] = isDefault;
    data['is_active'] = isActive;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class MethodFields {
  String? inputType;
  String? inputName;
  String? placeholder;
  int? isRequired;

  MethodFields({this.inputType, this.inputName, this.placeholder, this.isRequired});

  MethodFields.fromJson(Map<String, dynamic> json) {
    inputType = json['input_type'];
    inputName = json['input_name'];
    placeholder = json['placeholder'];
    isRequired = json['is_required'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['input_type'] = inputType;
    data['input_name'] = inputName;
    data['placeholder'] = placeholder;
    data['is_required'] = isRequired;
    return data;
  }
}
