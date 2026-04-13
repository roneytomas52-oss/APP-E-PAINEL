import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/ride_module/ride_order/domain/models/pending_ride_request_model.dart';
import 'package:sixam_mart_delivery/features/ride_module/ride_order/domain/models/trip_details_model.dart';
import '../domain/services/ride_order_service_interface.dart';

class RideController extends GetxController implements GetxService {
  final RideOrderServiceInterface rideOrderServiceInterface;

  RideController({required this.rideOrderServiceInterface});

  final bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _rideId;
  String? get rideId => _rideId;
  RideDetails? tripDetail;
  List<RideDetails>? _ongoingRide, _lastRideDetails;
  List<RideDetails>? get ongoingRide => _ongoingRide;
  List<RideDetails>? get lastRideDetails => _lastRideDetails;
  PendingRideRequestModel? _pendingRideRequestModel;
  PendingRideRequestModel? get pendingRideRequestModel => _pendingRideRequestModel;

  void setRideId(String id){}

  void setRideGetMessage(bool value){}

  Future<void> getLastRideDetail() async {}


  Future<Response> ongoingTripList() async {
   return Response();
  }

  Future<Response> remainingDistance(String tripId,{bool mapBound = false}) async {
    return Response();
  }

  Future<RideDetails?> getRideDetails(String rideId, {bool reload = false}) async {
    return null;
  }

  Future<Response> getRideDetailsFromMapIcon(String rideId) async {
    return Response();
  }

  Future<Response> getRideDetailBeforeAccept(String tripId) async {
   return Response();
  }

  void updateRoute(bool showHideIcon, {bool notify = false}){}

  Future<Response?> getPendingRideRequestList(int offset, {int limit = 10, bool isUpdate = false}) async {
    return null;
  }

  Future<Response> getFinalFare(String tripId) async {
    return Response();
  }

}
  