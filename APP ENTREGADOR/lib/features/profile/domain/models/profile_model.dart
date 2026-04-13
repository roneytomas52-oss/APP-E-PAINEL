import 'package:sixam_mart_delivery/features/ride_module/add_vehicle/domain/models/ride_categoty_model.dart';
import 'package:sixam_mart_delivery/features/ride_module/add_vehicle/domain/models/vehicle_brand_model.dart';


class ProfileModel {
  int? id;
  String? fName;
  String? lName;
  String? phone;
  String? email;
  String? identityNumber;
  String? identityType;
  List<String>? identityImageFullUrl;
  String? imageFullUrl;
  String? fcmToken;
  int? zoneId;
  int? active;
  double? avgRating;
  int? ratingCount;
  int? memberSinceDays;
  int? orderCount;
  int? todaysOrderCount;
  int? thisWeekOrderCount;
  double? cashInHands;
  int? earnings;
  String? type;
  double? balance;
  double? todaysEarning;
  double? thisWeekEarning;
  double? thisMonthEarning;
  String? createdAt;
  String? updatedAt;
  double? payableBalance;
  bool? adjustable;
  bool? overFlowWarning;
  bool? overFlowBlockWarning;
  double? withDrawableBalance;
  double? totalWithdrawn;
  bool? showPayNowButton;
  double? dmMaxMyAccount;
  bool? showWithdrawButton;
  double? pendingWithdraw;
  String? refCode;
  double? referalEarning;
  int? loyaltyPoint;

  Vehicle? vehicle;
  Wallet? wallet;
  String? dynamicBalanceType;
  double? dynamicBalance;
  double? totalEarning;
  double? totalIncome;
  double? tripIncome;
  double? deliveryIncome;
  double? totalTips;
  bool? isDeliveryOn;
  bool? isRideOn;
  int? totalRides;
  int? todayRideCount;
  int? thisWeekRideCount;
  double? totalReferralEarn;
  TimeTrack? timeTrack;
  Userinfo? userinfo;
  RiderVehicle? riderVehicle;

  ProfileModel({
    this.id,
    this.fName,
    this.lName,
    this.phone,
    this.email,
    this.identityNumber,
    this.identityType,
    this.identityImageFullUrl,
    this.imageFullUrl,
    this.fcmToken,
    this.zoneId,
    this.active,
    this.avgRating,
    this.memberSinceDays,
    this.orderCount,
    this.todaysOrderCount,
    this.thisWeekOrderCount,
    this.cashInHands,
    this.ratingCount,
    this.createdAt,
    this.updatedAt,
    this.earnings,
    this.type,
    this.balance,
    this.todaysEarning,
    this.thisWeekEarning,
    this.thisMonthEarning,
    this.payableBalance,
    this.adjustable,
    this.overFlowWarning,
    this.overFlowBlockWarning,
    this.withDrawableBalance,
    this.totalWithdrawn,
    this.showPayNowButton,
    this.dmMaxMyAccount,
    this.showWithdrawButton,
    this.pendingWithdraw,
    this.refCode,
    this.referalEarning,
    this.loyaltyPoint,
    this.wallet,
    this.vehicle,
    this.dynamicBalanceType,
    this.dynamicBalance,
    this.totalEarning,
    this.totalIncome,
    this.deliveryIncome,
    this.totalTips,
    this.tripIncome,
    this.isDeliveryOn,
    this.isRideOn,
    this.totalRides,
    this.todayRideCount,
    this.thisWeekRideCount,
    this.totalReferralEarn,
    this.timeTrack,
    this.userinfo,
    this.riderVehicle,
  });

  ProfileModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fName = json['f_name'];
    lName = json['l_name'];
    phone = json['phone'];
    email = json['email'];
    identityNumber = json['identity_number'];
    identityType = json['identity_type'];
    identityImageFullUrl = json['identity_image_full_url'].cast<String>();
    imageFullUrl = json['image_full_url'];
    fcmToken = json['fcm_token'];
    zoneId = json['zone_id'];
    active = json['active'];
    avgRating = json['avg_rating']?.toDouble();
    ratingCount = json['rating_count'];
    memberSinceDays = json['member_since_days'];
    orderCount = json['order_count'];
    todaysOrderCount = json['todays_order_count'];
    thisWeekOrderCount = json['this_week_order_count'];
    cashInHands = json['cash_in_hands']?.toDouble();
    earnings = int.tryParse(json['earning'].toString());
    type = json['type'];
    balance = json['balance']?.toDouble();
    todaysEarning = json['todays_earning']?.toDouble();
    thisWeekEarning = json['this_week_earning']?.toDouble();
    thisMonthEarning = json['this_month_earning']?.toDouble();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    payableBalance = json['Payable_Balance']?.toDouble();
    adjustable = json['adjust_able'];
    overFlowWarning = json['over_flow_warning'];
    overFlowBlockWarning = json['over_flow_block_warning'];
    withDrawableBalance = json['withdraw_able_balance']?.toDouble();
    totalWithdrawn = json['total_withdrawn']?.toDouble();
    showPayNowButton = json['show_pay_now_button'];
    dmMaxMyAccount = json['dm_max_cash_in_hand']?.toDouble();
    showWithdrawButton = json['show_withdraw_button'];
    pendingWithdraw = json['pending_withdraw']?.toDouble();
    refCode = json['ref_code'];
    referalEarning = json['referal_earning']?.toDouble();
    loyaltyPoint = json['loyalty_point'];
    vehicle = json['rider_vehicle'] != null ? Vehicle.fromJson(json['rider_vehicle']) : null;
    wallet = json['wallet'] != null ? Wallet.fromJson(json['wallet']) : null;
    dynamicBalanceType = json['dynamic_balance_type'];
    dynamicBalance = json['dynamic_balance']?.toDouble();
    totalEarning = json['total_earning']?.toDouble();
    totalIncome = json['total_income']?.toDouble();
    tripIncome = json['trip_income']?.toDouble();
    deliveryIncome = json['total_delivery_income']?.toDouble();
    totalTips = json['total_tips']?.toDouble();
    isDeliveryOn = json['is_delivery'].toString() == '1';
    isRideOn = json['is_ride'].toString() == '1';
    totalRides = json['ride_count'];
    todayRideCount = json['todays_ride_count'];
    thisWeekRideCount = json['this_week_ride_count'];
    totalReferralEarn = json['total_referral_earning']?.toDouble();
    timeTrack = json['time_track'] != null
        ? TimeTrack.fromJson(json['time_track'])
        : null;
    userinfo = json['userinfo'] != null ? Userinfo.fromJson(json['userinfo']) : null;
    riderVehicle = json['rider_vehicle'] != null
        ? RiderVehicle.fromJson(json['rider_vehicle'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['phone'] = phone;
    data['email'] = email;
    data['identity_number'] = identityNumber;
    data['identity_type'] = identityType;
    data['identity_image_full_url'] = identityImageFullUrl;
    data['image_full_url'] = imageFullUrl;
    data['fcm_token'] = fcmToken;
    data['zone_id'] = zoneId;
    data['active'] = active;
    data['avg_rating'] = avgRating;
    data['rating_count'] = ratingCount;
    data['member_since_days'] = memberSinceDays;
    data['order_count'] = orderCount;
    data['todays_order_count'] = todaysOrderCount;
    data['this_week_order_count'] = thisWeekOrderCount;
    data['cash_in_hands'] = cashInHands;
    data['earning'] = earnings;
    data['balance'] = balance;
    data['type'] = type;
    data['todays_earning'] = todaysEarning;
    data['this_week_earning'] = thisWeekEarning;
    data['this_month_earning'] = thisMonthEarning;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['Payable_Balance'] = payableBalance;
    data['adjust_able'] = adjustable;
    data['over_flow_warning'] = overFlowWarning;
    data['over_flow_block_warning'] = overFlowBlockWarning;
    data['withdraw_able_balance'] = withDrawableBalance;
    data['total_withdrawn'] = totalWithdrawn;
    data['show_pay_now_button'] = showPayNowButton;
    data['dm_max_cash_in_hand'] = dmMaxMyAccount;
    data['show_withdraw_button'] = showWithdrawButton;
    data['pending_withdraw'] = pendingWithdraw;
    data['ref_code'] = refCode;
    data['referal_earning'] = referalEarning;
    data['loyalty_point'] = loyaltyPoint;
    return data;
  }
}


class RiderVehicle {
  int? id;
  String? name;
  Brand? brand;
  Category? category;

  RiderVehicle(
      {this.id,
        this.name,
        this.brand,
        this.category,
      });

  RiderVehicle.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    brand = json['brand'] != null ? Brand.fromJson(json['brand']) : null;
    category = json['category'] != null
        ? Category.fromJson(json['category'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    if (brand != null) {
      data['brand'] = brand!.toJson();
    }
    if (category != null) {
      data['category'] = category!.toJson();
    }
    return data;
  }
}

class Userinfo {
  int? id;
  String? fName;
  String? lName;
  String? phone;
  String? email;
  String? image;

  Userinfo({this.id, this.fName, this.lName, this.phone, this.email, this.image,});

  Userinfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fName = json['f_name'];
    lName = json['l_name'];
    phone = json['phone'];
    email = json['email'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['phone'] = phone;
    data['email'] = email;
    data['image'] = image;
    return data;
  }
}

class Vehicle {
  String? id;
  String? name;
  Brand? brand;
  VehicleModels? model;
  Category? category;
  String? licencePlateNumber;
  String? licenceExpireDate;
  String? vinNumber;
  String? transmission;
  String? fuelType;
  String? ownership;
  List<String>? documentsFullUrl;
  int? isActive;
  String? createdAt;
  String? vehicleRequestStatus;
  String? denyNote;
  double? parcelWeightCapacity;
  List<VehicleTranslation>? translationList;


  Vehicle(
      {
        this.id,
        this.name,
        this.brand,
        this.model,
        this.category,
        this.licencePlateNumber,
        this.licenceExpireDate,
        this.vinNumber,
        this.transmission,
        this.fuelType,
        this.ownership,
        this.documentsFullUrl,
        this.isActive,
        this.createdAt,
        this.parcelWeightCapacity,
        this.denyNote,
        this.vehicleRequestStatus,
        this.translationList
      });

  Vehicle.fromJson(Map<String, dynamic> json) {
    brand = json['brand'] != null ? Brand.fromJson(json['brand']) : null;
    model = json['model'] != null ? VehicleModels.fromJson(json['model']) : null;
    category = json['category'] != null
        ? Category.fromJson(json['category'])
        : null;
    licencePlateNumber = json['licence_plate_number'];
    licenceExpireDate = json['licence_expire_date'];
    vinNumber = json['vin_number'];
    id = json['id'].toString();
    name = json['name'].toString();
    transmission = json['transmission'];
    fuelType = json['fuel_type'];
    ownership = json['ownership'];
    documentsFullUrl =  json['documents_full_url'] != null && json['documents_full_url'] != [] && json['documents_full_url'][0] != null ? json['documents_full_url'].cast<String>() : null;
    isActive = json['is_active'] ? 1: 0;
    createdAt = json['created_at'];
    vehicleRequestStatus = json['vehicle_request_status'];
    denyNote = json['deny_note'];
    parcelWeightCapacity = json['parcel_weight_capacity'] == null ? null :
    double.tryParse('${json['parcel_weight_capacity']}');
    if (json['translations'] != null) {
      translationList = <VehicleTranslation>[];
      json['translations'].forEach((v) {
        translationList!.add(VehicleTranslation.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (brand != null) {
      data['brand'] = brand!.toJson();
    }
    if (model != null) {
      data['model'] = model!.toJson();
    }
    if (category != null) {
      data['category'] = category!.toJson();
    }
    data['licence_plate_number'] = licencePlateNumber;
    data['id'] = id;
    data['name'] = name;
    data['licence_expire_date'] = licenceExpireDate;
    data['vin_number'] = vinNumber;
    data['transmission'] = transmission;
    data['fuel_type'] = fuelType;
    data['ownership'] = ownership;
    data['documents'] = documentsFullUrl;
    data['is_active'] = isActive;
    data['created_at'] = createdAt;
    if (translationList != null) {
      data['translations'] = translationList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VehicleTranslation {
  int? id;
  String? translationableType;
  String? translationableId;
  String? locale;
  String? key;
  String? value;

  VehicleTranslation(
      {this.id,
        this.translationableType,
        this.translationableId,
        this.locale,
        this.key,
        this.value
      });

  VehicleTranslation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    translationableType = json['translationable_type'].toString();
    translationableId = json['translationable_id'].toString();
    locale = json['locale'];
    key = json['key'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['translationable_type'] = translationableType;
    data['translationable_id'] = translationableId;
    data['locale'] = locale;
    data['key'] = key;
    data['value'] = value;
    return data;
  }
}

class Wallet {
  String? id;
  double? payableBalance;
  double? receivableBalance;
  double? receivedBalance;
  double? pendingBalance;
  double? walletBalance;
  double? totalWithdrawn;
  double? referralEarn;

  Wallet(
      {this.id,
        this.payableBalance,
        this.receivableBalance,
        this.receivedBalance,
        this.pendingBalance,
        this.walletBalance,
        this.totalWithdrawn,
        this.referralEarn
      });

  Wallet.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    payableBalance = json['payable_balance'].toDouble();
    receivableBalance = json['receivable_balance'].toDouble();
    if(json['received_balance'] != null){
      try{
        receivedBalance = json['received_balance'].toDouble();
      }catch(e){
        receivedBalance = double.parse(json['received_balance']);
      }

    }else{
      receivedBalance = 0;
    }
    pendingBalance = json['pending_balance'].toDouble();
    walletBalance = json['wallet_balance'].toDouble();
    totalWithdrawn = json['total_withdrawn'].toDouble();
    referralEarn = json['referral_earn'].toDouble();
  }

}

class TimeTrack {
  int? id;
  String? date;
  int? totalOnline;
  int? totalOffline;
  int? totalIdle;
  int? totalDriving;

  TimeTrack(
      {this.id,
        this.date,
        this.totalOnline,
        this.totalOffline,
        this.totalIdle,
        this.totalDriving});

  TimeTrack.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    totalOnline = json['total_online'];
    totalOffline = json['total_offline'];
    totalIdle = json['total_idle'];
    totalDriving = json['total_driving'];
  }

}
