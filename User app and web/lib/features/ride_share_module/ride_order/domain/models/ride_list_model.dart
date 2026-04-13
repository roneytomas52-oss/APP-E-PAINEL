
import 'package:sixam_mart/features/ride_share_module/ride_location/domain/models/ride_details_model.dart';

class RideListModel {
  String? responseCode;
  String? message;
  int? totalSize;
  String? limit;
  String? offset;
  List<RideDetails>? data;

  RideListModel(
      {this.responseCode,
        this.message,
        this.totalSize,
        this.limit,
        this.offset,
        this.data,});

  RideListModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['data'] != null) {
      data = <RideDetails>[];
      json['data'].forEach((v) {
        data!.add(RideDetails.fromJson(v));
      });
    }
  }


}