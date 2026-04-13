import '../repositories/rideHome_repository_interface.dart';
import 'rideHome_service_interface.dart';

class RideHomeService implements RideHomeServiceInterface {
  final RideHomeRepositoryInterface rideHomeRepositoryInterface;
  RideHomeService({required this.rideHomeRepositoryInterface});

}
  