import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart_delivery/common/widgets/title_widget.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class HomeEarningWidget extends StatelessWidget {
  final ProfileController profileController;
  const HomeEarningWidget({super.key, required this.profileController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: Column(children: [

        TitleWidget(title: 'earnings'.tr),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: Theme.of(context).primaryColor,
          ),
          child: Column(children: [

            Row(mainAxisAlignment: MainAxisAlignment.start, children: [

              const SizedBox(width: Dimensions.paddingSizeSmall),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall),
                child: Image.asset(Images.wallet, width: 40, height: 40),
              ),
              const SizedBox(width: Dimensions.paddingSizeLarge),

              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Text(
                  'balance'.tr,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor.withValues(alpha: 0.9)),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                profileController.profileModel != null ? Text(
                  PriceConverterHelper.convertPrice(profileController.profileModel!.balance),
                  style: robotoBold.copyWith(fontSize: 24, color: Theme.of(context).cardColor),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ) : Container(height: 30, width: 60, color: Colors.white),

              ]),
            ]),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Row(children: [

              _EarningWidget(
                title: 'today'.tr,
                amount: profileController.profileModel?.todaysEarning,
              ),
              Container(height: 30, width: 1, color: Theme.of(context).cardColor.withValues(alpha: 0.8)),

              _EarningWidget(
                title: 'this_week'.tr,
                amount: profileController.profileModel?.thisWeekEarning,
              ),
              Container(height: 30, width: 1, color: Theme.of(context).cardColor.withValues(alpha: 0.8)),

              _EarningWidget(
                title: 'this_month'.tr,
                amount: profileController.profileModel?.thisMonthEarning,
              ),

            ]),

          ]),
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),
      ]),
    );
  }
}


class _EarningWidget extends StatelessWidget {
  final String title;
  final double? amount;
  const _EarningWidget({required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Column(children: [
      Text(
        title,
        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor.withValues(alpha: 0.8)),
      ),
      const SizedBox(height: Dimensions.paddingSizeSmall),
      amount != null ? Text(
        PriceConverterHelper.convertPrice(amount),
        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).cardColor),
        maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
      ) : Shimmer(
        duration: const Duration(seconds: 2),
        enabled: amount == null,
        color: Colors.grey[500]!,
        child: Container(height: 20, width: 40, color: Colors.white),
      ),
    ]));
  }
}
