import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/common/widgets/title_widget.dart';
import 'package:sixam_mart_delivery/features/home/widgets/count_card_widget.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class OrderCountWidget extends StatelessWidget {
  final ProfileController profileController;
  const OrderCountWidget({super.key, required this.profileController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 0,Dimensions.paddingSizeDefault, Dimensions.paddingSizeLarge ),
      child: Column(children: [
        TitleWidget(title: 'orders'.tr),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        (profileController.profileModel != null && profileController.profileModel!.earnings == 1) ? IntrinsicHeight(
          child: Row(children: [
          
            _OrderCountCardWidget(
              title: 'todays_orders'.tr,
              value: profileController.profileModel?.todaysOrderCount.toString(),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),
          
            _OrderCountCardWidget(
              title: 'this_week_orders'.tr,
              value: profileController.profileModel?.thisWeekOrderCount.toString(),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),
          
            _OrderCountCardWidget(
              title: 'total_orders'.tr,
              value: profileController.profileModel?.orderCount.toString(),
            ),
          
          ]),
        ) : Column(children: [

          Row(children: [

            Expanded(child: CountCardWidget(
              title: 'todays_orders'.tr, backgroundColor: const Color(0xffE5EAFF), height: 180,
              value: profileController.profileModel?.todaysOrderCount.toString(),
            )),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            Expanded(child: CountCardWidget(
              title: 'this_week_orders'.tr, backgroundColor: const Color(0xffE84E50).withValues(alpha: 0.2), height: 180,
              value: profileController.profileModel?.thisWeekOrderCount.toString(),
            )),

          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          CountCardWidget(
            title: 'total_orders'.tr, backgroundColor: const Color(0xffE1FFD8), height: 140,
            value: profileController.profileModel?.orderCount.toString(),
          ),

        ])
      ]),
    );
  }
}

class _OrderCountCardWidget extends StatelessWidget {
  final String title;
  final String? value;
  const _OrderCountCardWidget({required this.title, this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomCard(
        isBorder: false,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge, vertical: Dimensions.paddingSizeLarge),
        child: Column(children: [

          value != null ? Text(
            value!, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).textTheme.bodyLarge?.color), textAlign: TextAlign.center,
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ) : Shimmer(
            duration: const Duration(seconds: 2),
            color: Theme.of(context).shadowColor,
            child: Container(height: 15, width: 15, decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(5))),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          Text(
            title,
            style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
            textAlign: TextAlign.center,
          ),

        ]),
      ),
    );
  }
}


