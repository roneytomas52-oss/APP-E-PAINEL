import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/title_widget.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
class RideActivityView extends StatelessWidget {
  const RideActivityView({super.key});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<ProfileController>(
      builder: (profileController) {
        int activeSec = 0, offlineSec = 0, drivingSec = 0, idleSec = 0;
        if(profileController.profileModel != null && profileController.profileModel!.timeTrack != null){
          activeSec = profileController.profileModel!.timeTrack!.totalOnline!.floor();
          drivingSec = profileController.profileModel!.timeTrack!.totalDriving!.floor();
          idleSec = profileController.profileModel!.timeTrack!.totalIdle!.floor();
          offlineSec = profileController.profileModel!.timeTrack!.totalOffline!.floor();
        }
        List<ActivityModel> activityList = [
          ActivityModel(title: 'active'.tr, value: activeSec, color: Colors.green),
          ActivityModel(title: 'on_riding'.tr, value: drivingSec, color: Colors.indigo),
          ActivityModel(title: 'idle_time'.tr, value: idleSec, color: Colors.orange),
          ActivityModel(title: 'offline'.tr, value: offlineSec, color: Colors.red),
        ];
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(color: Theme.of(context).disabledColor, width: 0.2),
            boxShadow: [BoxShadow(color: Get.isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), blurRadius: 20, spreadRadius: 0, offset: const Offset(0, 5))],
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          margin: const EdgeInsets.only(bottom: 15, left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
          child: Column(
            children: [
              TitleWidget(title: 'ride_activity'.tr),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              GridView.builder(
                  itemCount: activityList.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: Dimensions.paddingSizeSmall,
                    mainAxisSpacing: Dimensions.paddingSizeSmall,
                    // childAspectRatio: (1 / 0.6),
                    mainAxisExtent: 70,
                  ),
                  itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(activityList[index].title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5))),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Text(formatMinutes(activityList[index].value), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: activityList[index].color)),
                  ]),
                );
              },
              ),
            ],
          ),
        );
      }
    );
  }

  String formatMinutes(int minutes) {
    if (minutes < 60) {
      return '$minutes ${'min'.tr}';
    } else {
      double hours = minutes / 60;
      return '${hours.toStringAsFixed(hours % 1 == 0 ? 0 : 1)} ${'hour'.tr}';
    }
  }
}

class ActivityModel {
  final String title;
  final int value;
  final Color color;
  ActivityModel({required this.title, required this.value, required this.color});
}
