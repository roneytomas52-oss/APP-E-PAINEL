class VehicleBody {
  String? brandId;
  String? modelId;
  String? categoryId;
  String? licencePlateNumber;
  String? licenceExpireDate;
  String? vehicleName;
  String? vinNumber;
  String? transmission;
  String? fuelType;
  String? riderId;
  String? ownership;
  String? token;
  String? translation;

  VehicleBody({
    this.brandId,
    this.modelId,
    this.categoryId,
    this.licencePlateNumber,
    this.licenceExpireDate,
    this.vehicleName,
    this.vinNumber,
    this.transmission,
    this.fuelType,
    this.riderId,
    this.ownership,
    this.token,
    this.translation,
  });

  VehicleBody.fromJson(Map<String, dynamic> json) {
    brandId = json['brand_id'];
    modelId = json['model_id'];
    categoryId = json['category_id'];
    licencePlateNumber = json['licence_plate_number'];
    licenceExpireDate = json['licence_expire_date'];
    vehicleName = json['name'];
    vinNumber = json['vin_number'];
    transmission = json['transmission'];
    fuelType = json['fuel_type'];
    riderId = json['rider_id'];
    ownership = json['ownership'];
    translation = json['translation'];
  }

  Map<String, String> toJson() {
    final Map<String, String> data = <String, String>{};
    data['brand_id'] = brandId!;
    data['model_id'] = modelId!;
    data['category_id'] = categoryId!;
    data['licence_plate_number'] = licencePlateNumber!;
    data['licence_expire_date'] = licenceExpireDate!;
    data['name'] = vehicleName!;
    data['vin_number'] = vinNumber!;
    data['transmission'] = transmission!;
    data['fuel_type'] = fuelType!;
    data['rider_id'] = riderId!;
    data['ownership'] = ownership!;
    data['token'] = token!;
    data['translations'] = translation!;
    return data;
  }
}
