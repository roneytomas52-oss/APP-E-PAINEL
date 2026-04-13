import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_ink_well_widget.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/ride_module/ride_order/controllers/ride_controller.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/enums.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class BottomNavItemWidget extends StatelessWidget {
  final String iconData;
  final Function() onTap;
  final bool isSelected;
  final int? pageIndex;
  final String label;
  final bool isShowRequestAvailableIcon;
  const BottomNavItemWidget({super.key, required this.iconData, required this.onTap, this.isSelected = false, this.pageIndex, required this.label, this.isShowRequestAvailableIcon = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: CustomInkWellWidget(
      onTap: onTap,
      radius: Dimensions.radiusExtraLarge,
      child: Column(children: [
        Stack(clipBehavior: Clip.none, children: [
          Image.asset(iconData, color: isSelected ? Theme.of(context).primaryColor : Colors.grey, height: 20),

          pageIndex == 1 ? Positioned(
            top: -5, right: -5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: GetBuilder<RideController>(builder: (rideController){
                return GetBuilder<OrderController>(builder: (orderController) {
                  bool isRideActive = AppConstants.appMode == AppMode.ride;
                  int orderCount  =  isRideActive ? (rideController.pendingRideRequestModel?.totalSize ?? 0) : (orderController.latestOrderList?.length ?? 0);
                  return Text( "$orderCount",
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Colors.white),
                  );
                });
              })
            ),
          ) : const SizedBox(),
        ]),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        Text(label, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),)

      ]),
    ));
  }
}
