import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/ride_module/ride_order/controllers/ride_controller.dart';
import 'package:sixam_mart_delivery/features/ride_module/ride_order/domain/models/trip_details_model.dart';

  
class RideDetailsScreen extends StatefulWidget {
  final String rideId;
  final RideDetails? rideDetails;
  final bool fromListScreen;
  const RideDetailsScreen({super.key, required this.rideId, this.rideDetails, this.fromListScreen = false});

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }

}

  