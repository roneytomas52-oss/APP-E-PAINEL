import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';

class OfflineSuccessDialog extends StatelessWidget {
  final int? orderId;
  const OfflineSuccessDialog({super.key, required this.orderId, });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
      insetPadding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: Container(
        width: 500,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        ),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeLarge),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.check_circle, size: 70, color: Theme.of(context).primaryColor),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Text(
              'order_payment_details_submitted_successfully'.tr ,
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            RichText(textAlign: TextAlign.center, text: TextSpan(children: [
              TextSpan(text: 'after_verify_payment_details_your_order'.tr, style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.4))),
              TextSpan(text: ' #$orderId ', style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
              TextSpan(text: 'will_be_confirmed'.tr, style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.4))),
            ])),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),

            GetBuilder<OrderController>(
                builder: (orderController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                      border: Border.all(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.2)),
                    ),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('payment_info'.tr, style: robotoBold),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        orderController.trackModel != null ? ListView.builder(
                            itemCount: orderController.trackModel!.offlinePayment!.input!.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index){
                              Input data = orderController.trackModel!.offlinePayment!.input![index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Expanded(flex: 4, child: Text(data.userInput.toString().replaceAll('_', ' '), maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.6)))),
                                  Text(': '),
                                  Expanded(flex: 8, child: Text(data.userData.toString(), maxLines: 2, overflow: TextOverflow.ellipsis, style: robotoMedium)),
                                ]),
                              );
                            }) : const SizedBox(),
                      ],
                    ),
                  );
                }
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            RichText(textAlign: TextAlign.center, text: TextSpan(children: [
              TextSpan(text: '*', style: robotoMedium.copyWith(color: Colors.red)),
              TextSpan(text: 'offline_order_note'.tr, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.7))),
            ])),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            CustomButton(
              width: 100, height: 40,
              buttonText: 'ok'.tr,
              onPressed: () {
                Get.back();
              },
            )

          ]),
        ),
      ),
    );
  }
}
