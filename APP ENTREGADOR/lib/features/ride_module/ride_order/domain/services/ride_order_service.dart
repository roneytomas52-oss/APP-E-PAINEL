import 'package:sixam_mart_delivery/features/ride_module/ride_order/domain/repositories/ride_order_repository_interface.dart';
import 'ride_order_service_interface.dart';

class RideOrderService implements RideOrderServiceInterface {
  final RideOrderRepositoryInterface rideOrderRepositoryInterface;
  RideOrderService({required this.rideOrderRepositoryInterface});
}
  