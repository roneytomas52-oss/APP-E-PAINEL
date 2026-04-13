import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_loader.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/screens/order_request_screen.dart';
import 'package:sixam_mart_delivery/features/ride_module/map/controllers/ride_map_controller.dart';
import 'package:sixam_mart_delivery/features/ride_module/map/screens/map_screen.dart';
import 'package:sixam_mart_delivery/features/ride_module/ride_order/controllers/ride_controller.dart';
import 'package:sixam_mart_delivery/features/ride_module/safety/controllers/safety_alert_controller.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import '../features/ride_module/ride_order/screens/ride_details_screen.dart';

class RideHelper{
  static void navigateToNextScreen({String? id, bool fromRideListScreen = false}) async {

    Get.dialog(const CustomLoaderWidget());

    await Get.find<RideController>().getRideDetails(id!).then((rideDetails){
      if(Get.isDialogOpen!) {
        Get.back();
      }
      if(rideDetails != null){
        if(rideDetails.currentStatus == AppConstants.accepted || rideDetails.currentStatus == AppConstants.ongoing || rideDetails.currentStatus == AppConstants.outForPickup){

          if(rideDetails.currentStatus == AppConstants.accepted){
            Get.find<RiderMapController>().setRideCurrentState(RideState.accepted);
          } else if(rideDetails.currentStatus == AppConstants.ongoing){
            Get.find<SafetyAlertController>().checkDriverNeedSafety();
            Get.find<RiderMapController>().setRideCurrentState(RideState.ongoing);
          } else {
            Get.find<RiderMapController>().setRideCurrentState(RideState.outForPickup);
          }

          // Get.find<RideController>().remainingDistance(id,mapBound: false);
          Get.find<RiderMapController>().setMarkersInitialPosition();
          // Get.find<RideController>().updateRoute(false, notify: true);
          Get.to(() => const MapScreen(fromScreen: 'splash'));

        }else if(rideDetails.currentStatus == AppConstants.pending){
          Get.to(() =>  OrderRequestScreen(onTap: (){}));
        }else{
          if(rideDetails.driverSafetyAlert != null){
            Get.find<SafetyAlertController>().updateSafetyAlertState(SafetyAlertState.afterSendAlert);
          }
          Get.to(()=> RideDetailsScreen(rideId: rideDetails.id!, rideDetails: rideDetails, fromListScreen: fromRideListScreen,));
        }
      }
    });
  }

}

