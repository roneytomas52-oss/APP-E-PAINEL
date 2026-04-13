
import 'package:sixam_mart/features/ride_share_module/ride_location/domain/models/ride_details_model.dart';

class RideModel {
  int? totalSize;
  String? limit;
  String? offset;
  List<RideDetails>? data;

  RideModel(
      {
        this.totalSize,
        this.limit,
        this.offset,
        this.data,
        });

  RideModel.fromJson(Map<String, dynamic> json) {
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

