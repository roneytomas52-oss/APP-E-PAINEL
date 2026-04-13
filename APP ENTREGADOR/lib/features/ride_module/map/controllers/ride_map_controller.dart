import 'package:get/get.dart';
enum RideState{initial, pending, accepted, outForPickup ,ongoing, acceptingRider, completed, fareCalculating}

class RiderMapController extends GetxController implements GetxService {
  RideState currentRideState = RideState.initial;
  void setRideCurrentState(RideState newState, {bool notify = true}){}
  void setMarkersInitialPosition({bool bindLocation = false}){}
  void getPickupToDestinationPolyline({bool updateLiveLocation = false}) async {}
}
  