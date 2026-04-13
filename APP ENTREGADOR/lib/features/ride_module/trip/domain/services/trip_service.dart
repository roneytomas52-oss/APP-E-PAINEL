import '../repositories/trip_repository_interface.dart';
import 'trip_service_interface.dart';

class TripService implements TripServiceInterface {
  final TripRepositoryInterface tripRepositoryInterface;
  TripService({required this.tripRepositoryInterface});

}
  