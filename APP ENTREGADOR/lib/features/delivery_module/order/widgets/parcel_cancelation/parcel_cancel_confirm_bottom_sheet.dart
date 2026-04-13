import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ParcelCancelConfirmBottomSheet extends StatelessWidget {
  const ParcelCancelConfirmBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: GetBuilder<OrderController>(builder: (orderController) {
        return Stack(children: [
          Padding(
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeLarge, right: Dimensions.paddingSizeLarge),
            child: Column(mainAxisSize: MainAxisSize.min, children: [

              Container(
                height: 5, width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeOverLarge),

              Text(
                'If you cancel, your parcel will be back to you when rider will be available. You will have to pay a return fee to your delivery man.'.tr, textAlign: TextAlign.center,
                style: robotoRegular.copyWith(color: Theme.of(context).hintColor),
              ),
              const SizedBox(height: Dimensions.paddingSizeOverLarge),

              Text(
                PriceConverterHelper.convertPrice(165), textAlign: TextAlign.center,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge),
              ),

              Text(
                'return_fare'.tr, textAlign: TextAlign.center,
                style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeLarge),
              ),
              const SizedBox(height: Dimensions.paddingSizeOverLarge),

              CustomButtonWidget(
                buttonText: 'yes_cancel'.tr,
                onPressed: () {

                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                child: InkWell(
                  onTap: () => Get.back(),
                  child: Center(
                    child: Text(
                      'continue_delivery'.tr,
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, decoration: TextDecoration.underline),
                    ),
                  ),
                ),
              ),

            ]),
          ),

          Positioned(
            top: 0, right: 0,
            child: InkWell(
              onTap: () => Get.back(),
              child: Icon(Icons.clear, color: Theme.of(context).disabledColor, size: 20),
            ),
          ),
        ]);
      }),
    );
  }
}
