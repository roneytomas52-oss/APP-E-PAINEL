import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/features/refer_and_earn/screens/refer_and_earn_screen.dart';
import 'package:sixam_mart_delivery/features/refer_and_earn/widgets/refer_bottom_sheet.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class ReferralCardWidget extends StatelessWidget {
  const ReferralCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(()=> const ReferAndEarnScreen());
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).disabledColor.withValues(alpha: 0.125),
        ),
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeLarge),
        margin: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('invite_and_get_rewards'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text('share_code_with_your_friends'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.7))),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Row(
                children: [
                  CustomButtonWidget(
                    height: 30, width: 130,
                    buttonText: 'invite_friends'.tr,
                    fontSize: Dimensions.fontSizeSmall,
                    onPressed: (){
                      Get.bottomSheet(const ReferBottomSheet(), isScrollControlled: true);
                    },
                  ),
                ],
              ),

            ]),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Image.asset(Images.shareImage, width: 100,)
        ]),
      ),
    );
  }
}
