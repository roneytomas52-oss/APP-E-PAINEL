import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../repositories/ride_order_repository_interface.dart';
import 'ride_order_service_interface.dart';

class RideOrderService implements RideOrderServiceInterface {
  final RideOrderRepositoryInterface rideOrderRepositoryInterface;
  RideOrderService({required this.rideOrderRepositoryInterface});

}
  