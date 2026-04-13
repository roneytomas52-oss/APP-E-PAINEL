import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/title_widget.dart';
import 'package:sixam_mart_delivery/features/home/widgets/count_card_widget.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
class OrdersAndRidesView extends StatelessWidget {
  final ProfileController profileController;
  const OrdersAndRidesView({super.key, required this.profileController});

  @override
  Widget build(BuildContext context) {
    bool isActiveBothDeliveryAndRide = (profileController.profileModel?.isDeliveryOn ?? false) && (profileController.profileModel?.isRideOn ?? false);
    double width = isActiveBothDeliveryAndRide ? Get.width - 90 : Get.width - Dimensions.paddingSizeDefault * 2;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        height: 400,
        child: Row(spacing: Dimensions.paddingSizeSmall, children: [

          if(profileController.profileModel?.isDeliveryOn??false)
            Container(
              width: width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color: Theme.of(context).cardColor,
                boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.3), blurRadius: 10)],
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              margin: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: (profileController.profileModel?.isRideOn??false) ? Dimensions.paddingSizeExtraSmall : 0),
              child: Column(children: [
                TitleWidget(title: 'orders'.tr),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Row(children: [

                  Expanded(child: CountCardWidget(
                    title: 'todays_orders'.tr, backgroundColor: Colors.blueAccent .withValues(alpha: 0.3), height: 180,
                    value: profileController.profileModel?.todaysOrderCount.toString(),
                  )),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(child: CountCardWidget(
                    title: 'this_week_orders'.tr, backgroundColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.3), height: 180,
                    value: profileController.profileModel?.thisWeekOrderCount.toString(),
                  )),

                ]),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                CountCardWidget(
                  title: 'total_orders'.tr, backgroundColor: Colors.lightGreenAccent.withValues(alpha: 0.3), height: 140,
                  value: profileController.profileModel?.orderCount.toString(),
                ),
              ]),
            ),

          if(profileController.profileModel?.isRideOn??false)
            Container(
              width: 350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color: Theme.of(context).cardColor,
                boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.3), blurRadius: 10)],
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeExtraSmall),
              child: Column(children: [
                TitleWidget(title: 'rides'.tr),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Row(children: [

                  Expanded(child: CountCardWidget(
                    title: 'todays_rides'.tr, backgroundColor: Colors.blueAccent .withValues(alpha: 0.3), height: 180,
                    value: profileController.profileModel?.todayRideCount.toString(),
                  )),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(child: CountCardWidget(
                    title: 'this_week_rides'.tr, backgroundColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.3), height: 180,
                    value: profileController.profileModel?.thisWeekRideCount.toString(),
                  )),

                ]),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                CountCardWidget(
                  title: 'total_rides'.tr, backgroundColor: Colors.lightGreenAccent.withValues(alpha: 0.3), height: 140,
                  value: profileController.profileModel?.totalRides.toString(),
                ),
              ]),
            ),
        ]),
      ),
    );
  }
}
