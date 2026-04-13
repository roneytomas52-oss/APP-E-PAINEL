import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class OtpDialog extends StatelessWidget {
  final int orderId;
  const OtpDialog({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge)),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: GetBuilder<OrderController>(builder: (orderController) {
        return SizedBox(
          width: 500,
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () => Get.back(),
                child: Container(
                  margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.clear, color: Theme.of(context).cardColor, size: 16),
                ),
              ),
            ),

            Text('enter_cancellation_otp'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
            SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Text(
              'collect_the_otp_from_customer'.tr,
              style: robotoRegular.copyWith(color: Theme.of(context).hintColor),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Dimensions.paddingSizeExtraLarge),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: PinCodeTextField(
                length: 4,
                appContext: context,
                keyboardType: TextInputType.number,
                animationType: AnimationType.slide,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  fieldHeight: 45,
                  fieldWidth: 45,
                  borderWidth: 0.5,
                  activeBorderWidth: 0.5,
                  selectedBorderWidth: 0.7,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  selectedColor: Theme.of(context).primaryColor,
                  selectedFillColor: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                  inactiveFillColor: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                  inactiveColor: Colors.transparent,
                  activeColor: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                  activeFillColor: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                ),
                animationDuration: const Duration(milliseconds: 300),
                backgroundColor: Colors.transparent,
                enableActiveFill: true,
                onChanged: (String text) => orderController.setOtp(text),
                beforeTextPaste: (text) => true,
              ),
            ),
            SizedBox(height: Dimensions.paddingSizeLarge),

            SizedBox(
              width: 200,
              child: CustomButtonWidget(
                isLoading: orderController.isLoading,
                buttonText: 'submit'.tr,
                onPressed: () {
                  orderController.submitParcelReturn(orderId: orderId);
                },
              ),
            ),

            SizedBox(height: 40),

          ]),
        );
      }),
    );
  }
}
