class RecordLocationBodyModel {
  String? token;
  double? longitude;
  double? latitude;
  String? location;
  String? zoneId;

  RecordLocationBodyModel({this.token, this.longitude, this.latitude, this.location, this.zoneId});

  RecordLocationBodyModel.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    longitude = json['longitude']?.toDouble();
    latitude = json['latitude']?.toDouble();
    location = json['location'];
    zoneId = json['zone_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    data['longitude'] = longitude;
    data['latitude'] = latitude;
    data['location'] = location;
    data['zone_id'] = zoneId;
    return data;
  }
}