import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class ServicePaymentFailedDialog extends StatelessWidget {
  const ServicePaymentFailedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Image.asset(Images.warning, width: 70, height: 70),
      ),
      Text(
        'are_you_agree_with_this_booking_fail'.tr, textAlign: TextAlign.center,
        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Colors.red),
      ),
      const SizedBox(height: Dimensions.paddingSizeLarge),
      CustomButton(
          onPressed: (){
            Get.back();
            Get.back();
          },
          buttonText: 'retry'.tr),
      const SizedBox(height: Dimensions.paddingSizeDefault,),

      TextButton(
        onPressed: () {
          Get.back();
          Get.back();
          // Get.offAllNamed(RouteHelper.getInitialRoute());
        },
        style: TextButton.styleFrom(
          backgroundColor: Theme.of(context).disabledColor.withValues(alpha: 0.3), minimumSize: const Size(Dimensions.webMaxWidth, 45), padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
        ),
        child: Text('continue_with_order_fail'.tr, textAlign: TextAlign.center, style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color)),
      ),

    ]);
  }
}
