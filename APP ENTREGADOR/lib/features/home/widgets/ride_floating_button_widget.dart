import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_alert_dialog_widget.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/ride_module/map/controllers/ride_map_controller.dart';
import 'package:sixam_mart_delivery/features/ride_module/map/screens/map_screen.dart';
import 'package:sixam_mart_delivery/features/ride_module/ride_order/controllers/ride_controller.dart';
import 'package:sixam_mart_delivery/util/images.dart';

class RideMapNavigationWidget extends StatelessWidget {
  const RideMapNavigationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100, right: 0,
      child: GestureDetector(
        onTap: () async {
          if(Get.find<RideController>().rideId !=null && isDeliveryManActive()){
            Response res = await Get.find<RideController>().getRideDetailsFromMapIcon(Get.find<RideController>().rideId ?? '0');
            if(res.statusCode == 403 || Get.find<RideController>().tripDetail?.currentStatus == 'returning' || Get.find<RideController>().tripDetail?.currentStatus == 'returned'){
              Get.find<RiderMapController>().setRideCurrentState(RideState.initial);
            }
          }else{
            Get.find<RiderMapController>().setRideCurrentState(RideState.initial);
          }
          Get.to(()=> const MapScreen());
        },
        onHorizontalDragEnd: (DragEndDetails details){
          _onHorizontalDrag(details);
          Get.to(()=> const MapScreen());
        },
        child: Stack(
          children: [
            Image.asset(Images.mapFrame, height: 120),
            Positioned(
              top: 40, right: 3,
              child: Image.asset(Images.mapIcon, height: 20, width: 20,),
            ),
          ],
        ),
      ),
    );
  }

  void _onHorizontalDrag(DragEndDetails details) {
    if(details.primaryVelocity == 0) return;

    if (details.primaryVelocity!.compareTo(0) == -1) {
      debugPrint('dragged from left');
    } else {
      debugPrint('dragged from right');
    }
  }

  bool isDeliveryManActive({bool showPopUp = true}){
    if(Get.find<ProfileController>().profileModel != null && Get.find<ProfileController>().profileModel!.active == 1
        && Get.find<OrderController>().currentOrderList != null && Get.find<OrderController>().currentOrderList!.isEmpty) {
      return true;
    }else {
      if(Get.find<ProfileController>().profileModel == null || Get.find<ProfileController>().profileModel!.active == 0) {
        if(showPopUp){
          WidgetsBinding.instance.addPostFrameCallback((_){
            Get.dialog(CustomAlertDialogWidget(description: 'you_are_offline_now'.tr, onOkPressed: () => Get.back()));
          });
        }
        return false;
      }else {
        return true;
      }
    }
  }
}
