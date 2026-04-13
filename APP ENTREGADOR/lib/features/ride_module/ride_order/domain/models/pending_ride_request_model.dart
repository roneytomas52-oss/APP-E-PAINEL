
import 'package:sixam_mart_delivery/features/ride_module/ride_order/domain/models/trip_details_model.dart';

class PendingRideRequestModel {
  String? responseCode;
  String? message;
  int? totalSize;
  String? limit;
  String? offset;
  List<RideDetails>? data;


  PendingRideRequestModel({this.responseCode, this.message, this.totalSize, this.limit, this.offset, this.data});

  PendingRideRequestModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['data'] != null) {
      data = <RideDetails>[];
      json['data'].forEach((v) { data!.add(RideDetails.fromJson(v)); });
    }

  }


}


