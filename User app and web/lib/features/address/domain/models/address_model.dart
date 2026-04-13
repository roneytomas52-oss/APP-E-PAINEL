import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';

class AddressModel {
  int? id;
  String? addressType;
  String? contactPersonNumber;
  String? address;
  String? additionalAddress;
  String? latitude;
  String? longitude;
  int? zoneId;
  int? serviceZoneId;
  int? rideZoneId;
  List<int>? zoneIds;
  String? method;
  String? contactPersonName;
  String? streetNumber;
  String? house;
  String? floor;
  List<ZoneData>? zoneData;
  List<int>? areaIds;
  String? email;

  AddressModel({
    this.id,
    this.addressType,
    this.contactPersonNumber,
    this.address,
    this.additionalAddress,
    this.latitude,
    this.longitude,
    this.zoneId,
    this.serviceZoneId,
    this.rideZoneId,
    this.zoneIds,
    this.method,
    this.contactPersonName,
    this.streetNumber,
    this.house,
    this.floor,
    this.zoneData,
    this.areaIds,
    this.email,
  });

  AddressModel copyWith({
    String? contactPersonName,
    String? contactPersonNumber,
  }) {
    return AddressModel(
      id: id,
      addressType: addressType,
      contactPersonNumber: contactPersonNumber ?? this.contactPersonNumber,
      address: address,
      additionalAddress: additionalAddress,
      latitude: latitude,
      longitude: longitude,
      zoneId: zoneId,
      serviceZoneId: serviceZoneId,
      rideZoneId: rideZoneId,
      zoneIds: zoneIds,
      method: method,
      contactPersonName: contactPersonName ?? this.contactPersonName,
      streetNumber: streetNumber,
      house: house,
      floor: floor,
      zoneData: zoneData,
      areaIds: areaIds,
      email: email,
    );
  }

  AddressModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    addressType = json['address_type'];
    contactPersonNumber = json['contact_person_number'].toString();
    address = json['address'];
    additionalAddress = json['additional_address'];
    latitude = json['latitude'].toString();
    longitude = json['longitude'].toString();
    zoneId = (json['zone_id'] != null && json['zone_id'] != 'null') ? int.parse(json['zone_id'].toString()) : null;
    serviceZoneId = (json['service_zone_id'] != null && json['service_zone_id'] != 'null') ? int.parse(json['service_zone_id'].toString()) : null;
    rideZoneId = (json['ride_zone_id'] != null && json['ride_zone_id'] != 'null') ? int.parse(json['ride_zone_id'].toString()) : null;
    zoneIds = json['zone_ids']?.cast<int>();
    method = json['_method'];
    contactPersonName = json['contact_person_name'];
    streetNumber = json['road'];
    house = json['house'];
    floor = json['floor'] ;
    if (json['zone_data'] != null) {
      zoneData = [];
      json['zone_data'].forEach((v) {
        zoneData!.add(ZoneData.fromJson(v));
      });
    }
    areaIds = json['area_ids']?.cast<int>();
    if(json['contact_person_email'] != null) {
      email = json['contact_person_email'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['address_type'] = addressType;
    data['contact_person_number'] = contactPersonNumber;
    data['address'] = address;
    data['additional_address'] = additionalAddress;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['zone_id'] = zoneId;
    data['service_zone_id'] = serviceZoneId;
    data['ride_zone_id'] = rideZoneId;
    data['zone_ids'] = zoneIds;
    data['_method'] = method;
    data['contact_person_name'] = contactPersonName;
    data['road'] = streetNumber;
    data['house'] = house;
    data['floor'] = floor;
    if (zoneData != null) {
      data['zone_data'] = zoneData!.map((v) => v.toJson()).toList();
    }
    data['area_ids'] = areaIds;
    if(email != null) {
      data['contact_person_email'] = email;
    }
    return data;
  }
}
