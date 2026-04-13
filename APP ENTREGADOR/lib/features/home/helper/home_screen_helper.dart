
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/ride_module/ride_order/controllers/ride_controller.dart';
import 'package:sixam_mart_delivery/helper/pusher_helper.dart';

class HomeScreenHelper {




  void pendingListPusherImplementation(){
    for(int i =0 ;i<Get.find<RideController>().pendingRideRequestModel!.data!.length; i++){
      PusherHelper().customerInitialTripCancel(Get.find<RideController>().pendingRideRequestModel!.data![i].id!,Get.find<ProfileController>().profileModel!.id!.toString());
      PusherHelper().anotherDriverAcceptedTrip(Get.find<RideController>().pendingRideRequestModel!.data![i].id!,Get.find<ProfileController>().profileModel!.id!.toString());
    }
  }


  void ongoingLastRidePusherImplementation(){
    List<String> data = ["ongoing","accepted"];

    for(int i =0 ;i < Get.find<RideController>().ongoingRide!.length; i++){
      if(data.contains(Get.find<RideController>().ongoingRide![i].currentStatus)){
        PusherHelper().tripCancelAfterOngoing(Get.find<RideController>().ongoingRide![i].id!);
        PusherHelper().customerInitialTripCancel(Get.find<RideController>().ongoingRide![i].id!, Get.find<ProfileController>().profileModel!.id!.toString());
        PusherHelper().tripPaymentSuccessful(Get.find<RideController>().ongoingRide![i].id!);
      }
    }
  }
}