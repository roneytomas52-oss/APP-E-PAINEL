import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/widgets/parcel_cancelation/otp_dialog.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CollectMoneyBottomSheet extends StatelessWidget {
  final int orderId;
  const CollectMoneyBottomSheet({super.key, required this.orderId});

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
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall),
            child: Column(mainAxisSize: MainAxisSize.min, children: [

              Container(
                height: 5, width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.5),
                ),
              ),

              Column(children: [
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Image.asset(Images.deliveredSuccess, height: 100, width: 100),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Text(
                  'collect_money_from_customer'.tr, textAlign: TextAlign.center,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    '${'return_fee'.tr} :', textAlign: TextAlign.center,
                    style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeLarge),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                  Text(
                    PriceConverterHelper.convertPrice(orderController.orderModel?.parcelCancellation?.returnFee ?? 0), textAlign: TextAlign.center,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ),
                ]),
              ]),
              const SizedBox(height: Dimensions.paddingSizeOverLarge),

              CustomButtonWidget(
                buttonText: 'ok'.tr,
                radius: Dimensions.radiusDefault,
                margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                onPressed: () {
                  Get.back();
                  Get.dialog(OtpDialog(orderId: orderId));
                },
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
