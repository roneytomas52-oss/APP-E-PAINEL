import 'package:get/get.dart';
import 'package:sixam_mart/features/ride_share_module/ride_location/domain/models/ride_details_model.dart';
import 'package:sixam_mart/features/ride_share_module/ride_order/domain/models/bidding_model.dart';
import 'package:sixam_mart/features/ride_share_module/ride_order/domain/services/ride_order_service_interface.dart';

enum RideState{initial, riseFare, findingRider, acceptingRider, afterAcceptRider, otpSent, ongoingRide, completeRide}
enum RideType{regularRide, scheduleRide}

class RideController extends GetxController implements GetxService {
  final RideOrderServiceInterface rideOrderServiceInterface;

  RideController({required this.rideOrderServiceInterface});

  RideDetails? tripDetails;
  RideDetails? rideDetails;

  List<Bidding> biddingList = [];
  bool haveRunningTrip = false;

  void updateRideController() {
  }

  void setRideGetMessage(bool value){
  }


  void updateRideCurrentState(RideState newState) {
  }

  Future<void> getRideList(int offset, {bool isUpdate = false, bool isRunning = true, bool fromHome = false}) async {

  }

  Future<Response> getCurrentRide({bool fromRefresh = false, bool navigateToMap = true}) async {
    return Response();
  }

  Future<Response> getRideDetails(String tripId, {bool isUpdate = true}) async {
    return Response();
  }

  Future<Response> getBiddingList(String tripId, int offset) async {
    return Response();
  }

  void startLocationRecord() {
  }

  void stopLocationRecord() {
  }


  Future<Response> getFinalFare(String tripId) async {
    return Response();
  }

  Future<Response> getCurrentRideStatus({bool fromRefresh = false, bool navigateToMap = true, bool showCustomLoader = false}) async {
    return Response();
  }

  Future<Response> remainingDistance(String requestID,{bool mapBound = false}) async {
    return Response();
  }

  Future<Response> getNearestDriverList(String  lat, String lng) async {
    return Response();
  }

  void clearBiddingList(){
  }

}