import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class SuccessDialogWidget extends StatelessWidget {
  const SuccessDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
      insetPadding: const EdgeInsets.all(20),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Stack(children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 50),

            Image.asset(Images.coin, height: 75, width: 90),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Text(
              'your_request_successfully_sent'.tr,
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
              child: Text(
                'the_request_just_sent_to_admin'.tr,
                textAlign: TextAlign.center,
                style: robotoRegular.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.6),
                  fontSize: Dimensions.fontSizeSmall,
                ),
              ),
            ),

            const SizedBox(height: 50),
          ]),
        ),

        Positioned(
          top: 10, right: 10,
          child: InkWell(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.clear, color: Theme.of(context).cardColor, size: 16),
            ),
          ),
        ),
      ]),
    );
  }
}
