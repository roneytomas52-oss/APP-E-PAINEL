
import 'package:sixam_mart_delivery/features/ride_module/ride_order/domain/models/trip_details_model.dart';

class TripModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<RideDetails>? tripList;

  TripModel({
    this.totalSize,
    this.limit,
    this.offset,
    this.tripList,
  });

  TripModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = int.tryParse(json['limit'].toString());
    offset =int.tryParse( json['offset'].toString());
    if (json['data'] != null) {
      tripList = <RideDetails>[];
      json['data'].forEach((v) {
        tripList!.add(RideDetails.fromJson(v));
      });
    }

  }

}

