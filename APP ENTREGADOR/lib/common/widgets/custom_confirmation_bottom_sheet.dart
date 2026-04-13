import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class CustomConfirmationBottomSheet extends StatelessWidget {
  final String? image;
  final String title;
  final String? description;
  final String? confirmButtonText;
  final String? cancelButtonText;
  final Function? onConfirm;
  final Widget? buttonWidget;
  const CustomConfirmationBottomSheet({super.key, this.image, required this.title, this.description, this.confirmButtonText, this.cancelButtonText, this.onConfirm, this.buttonWidget});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(builder: (orderController) {
      return GetBuilder<ProfileController>(builder: (profileController) {
        return GetBuilder<AuthController>(builder: (authController) {
          return Container(
            width: context.width,
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Get.isDarkMode ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge),
              ),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [

              Container(
                height: 5, width: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Image.asset(
                image ?? Images.warning, height: 60, width: 60,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Text(title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge), textAlign: TextAlign.center),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: Text(
                  description ?? '',
                  style: robotoRegular.copyWith(color: Theme.of(context).hintColor), textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),

              buttonWidget ?? Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeLarge),
                child: Row(children: [

                  Expanded(
                    child: CustomButtonWidget(
                      onPressed: () {
                        Get.back();
                      },
                      buttonText: cancelButtonText ?? 'cancel'.tr,
                      backgroundColor: Theme.of(context).disabledColor,
                      fontColor: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  Expanded(
                    child: CustomButtonWidget(
                      onPressed: () => onConfirm as void Function()?,
                      isLoading: orderController.isLoading || authController.isLoading || profileController.isLoading,
                      buttonText: confirmButtonText ?? 'accept'.tr,
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                  ),

                ]),
              ),

            ]),

          );
        });
      });
    });
  }
}
