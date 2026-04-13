class VehicleModel {
  int? id;
  String? type;
  String? name;

  VehicleModel({this.id, this.type, this.name});

  VehicleModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['name'] = type;
    return data;
  }
}