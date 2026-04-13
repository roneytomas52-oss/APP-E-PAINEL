
import 'package:sixam_mart/features/ride_share_module/ride_location/domain/models/ride_details_model.dart';

class BiddingModel {
  int? totalSize;
  String? limit;
  String? offset;
  List<Bidding>? data;


  BiddingModel(
      {
        this.totalSize,
        this.limit,
        this.offset,
        this.data
      });

  BiddingModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['data'] != null) {
      data = <Bidding>[];
      json['data'].forEach((v) {
        data!.add(Bidding.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;


    return data;
  }
}

class Bidding {
  String? id;
  String? tripRequestsId;
  RideRequest? rideRequest;
  Driver? driver;
  DriverLastLocation? driverLastLocation;
  double? bidFare;
  String? driverAvgRating;

  Bidding(
      {this.id,
        this.tripRequestsId,
        this.rideRequest,
        this.driver,
        this.driverLastLocation,
        this.bidFare,
        this.driverAvgRating,
      });

  Bidding.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    tripRequestsId = json['ride_requests_id']?.toString();
    rideRequest = json['ride_request'] != null
        ? new RideRequest.fromJson(json['ride_request'])
        : null;
    driver =
    json['driver'] != null ? Driver.fromJson(json['driver']) : null;

    driverLastLocation = json['driver_last_location'] != null
        ? DriverLastLocation.fromJson(json['driver_last_location'])
        : null;
    bidFare = json['bid_fare'] != null ? double.parse(json['bid_fare'].toString()) : 0;
    driverAvgRating = json['driver_avg_rating'];
  }


}
class DriverLastLocation {
  String? userId;
  String? type;
  String? latitude;
  String? longitude;
  String? zoneId;

  DriverLastLocation(
      {this.userId, this.type, this.latitude, this.longitude, this.zoneId});

  DriverLastLocation.fromJson(Map<String, dynamic> json) {
    userId = json['user_id']?.toString();
    type = json['type'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    zoneId = json['zone_id']?.toString();
  }


}

class RideRequest {
  int? id;
  String? refId;
  double? estimatedFare;
  double? actualFare;
  double? returnFee;
  double? dueAmount;
  double? discountActualFare;
  double? estimatedDistance;
  double? paidFare;
  double? actualDistance;

  RideRequest(
      {this.id,
        this.refId,
        this.estimatedFare,
        this.actualFare,
        this.returnFee,
        this.dueAmount,
        this.discountActualFare,
        this.estimatedDistance,
        this.paidFare,
        this.actualDistance,
      });

  RideRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    refId = json['ref_id'];
    estimatedFare = json['estimated_fare']?.toDouble();
    actualFare = json['actual_fare']?.toDouble();
    returnFee = json['return_fee']?.toDouble();
    dueAmount = json['due_amount']?.toDouble();
    discountActualFare = json['discount_actual_fare']?.toDouble();
    estimatedDistance = json['estimated_distance']?.toDouble();
    paidFare = json['paid_fare']?.toDouble();
    actualDistance = json['actual_distance']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['ref_id'] = this.refId;
    data['estimated_fare'] = this.estimatedFare;
    data['actual_fare'] = this.actualFare;
    data['return_fee'] = this.returnFee;
    data['due_amount'] = this.dueAmount;
    data['discount_actual_fare'] = this.discountActualFare;
    data['estimated_distance'] = this.estimatedDistance;
    data['paid_fare'] = this.paidFare;
    data['actual_distance'] = this.actualDistance;
    return data;
  }
}