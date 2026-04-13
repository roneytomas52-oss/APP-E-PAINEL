import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/features/profile/domain/models/profile_model.dart';
import 'package:sixam_mart_delivery/features/ride_module/add_vehicle/screens/add_vehicle_screen.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class VehicleAddWidget extends StatelessWidget {
  final Vehicle? vehicle;
  const VehicleAddWidget({super.key, this.vehicle});

  @override
  Widget build(BuildContext context) {
    return  vehicle == null || vehicle?.vehicleRequestStatus == "pending" ? Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.3), blurRadius: 10)],
      ),
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      width: double.infinity,
      child: vehicle?.vehicleRequestStatus == "pending" ? Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('vehicle_approval_pending'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Text('after_approval_vehicle_information'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.7)),),
          ]),
        ),
        Image.asset(Images.rideImage, width: 80,),

      ]) : Column(children: [

        Text('add_vehicle_information'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Text('to_get_ride_request'.tr, textAlign: TextAlign.center, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.7)),),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        Image.asset(Images.rideImage, height: 150),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        CustomButtonWidget(
          height: 40, width: 200,
          buttonText: 'add_vehicle_info'.tr,
          onPressed: (){
            Get.to(()=> const AddVehicleScreen());
          },
        ),
      ]),
    ) : const SizedBox();
  }
}