import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class ExtraPackagingWidget extends StatelessWidget {
  final CartController cartController;
  const ExtraPackagingWidget({super.key, required this.cartController});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return GetBuilder<StoreController>(builder: (storeController) {
      return storeController.store?.extraPackagingStatus ?? false ? Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        margin: isDesktop ? const EdgeInsets.all(Dimensions.paddingSizeDefault) : null,
        decoration: BoxDecoration(
          color: isDesktop ? Theme.of(context).disabledColor.withValues(alpha: 0.1) : Theme.of(context).cardColor,
          borderRadius: isDesktop ? BorderRadius.circular(Dimensions.radiusDefault) : null,
          boxShadow: isDesktop ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, spreadRadius: 1, offset: const Offset(0, 1))],
        ),
        child: Row(children: [

          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('need_extra_packaging'.tr, style: robotoMedium),

              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: '(${'additional'.tr}', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.6), fontSize: Dimensions.fontSizeSmall)),
                    TextSpan(text: ' ${PriceConverter.convertPrice(storeController.store?.extraPackagingAmount)} ', style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeSmall)),
                    TextSpan(text: '${'change_will_be_added_for_extra_packaging'.tr})', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.6), fontSize: Dimensions.fontSizeSmall)),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),

          Checkbox(
            activeColor: Theme.of(context).primaryColor,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            value: cartController.needExtraPackage,
            onChanged: (bool? isChecked) {
              cartController.toggleExtraPackage();
            },
          ),

        ]),
      ) : const SizedBox();
    });
  }
}
