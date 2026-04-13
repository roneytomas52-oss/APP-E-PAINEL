import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart_delivery/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_delivery/features/my_account/controllers/my_account_controller.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/enums.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class EmptyStateBottomSheet extends StatelessWidget {
  final bool noPaymentMethod;
  const EmptyStateBottomSheet({super.key, this.noPaymentMethod = false});

  @override
  Widget build(BuildContext context) {

    bool isRideActive = AppConstants.appMode == AppMode.ride;
    final config = Get.find<SplashController>().configModel;
    double minimumPayableAmount = isRideActive ? (config?.minAmountToPayRider ?? 0) : (config?.minAmountToPayDm ?? 0);

    return Container(
      width: context.width,
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusExtraLarge),
          topRight: Radius.circular(Dimensions.radiusExtraLarge),
        ),
      ),
      child: GetBuilder<MyAccountController>(builder: (myAccountController) {
        return Column(mainAxisSize: MainAxisSize.min, children: [

          Container(
            height: 5, width: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Text(noPaymentMethod ? 'payment_method'.tr : 'insufficient_balance'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Container(
            padding: const EdgeInsets.all(40),
            width: context.width,
            decoration: BoxDecoration(
              color: Theme.of(context).hintColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Column(children: [

              const CustomAssetImageWidget(
                image: Images.emptyPaymentIcon,
                height: 50, width: 50,
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text(
                noPaymentMethod ? 'no_payment_method_is_available'.tr : '${'you_do_not_have_sufficient_balance_to_pay_the_minimum_payable_balance_is'.tr} ${PriceConverterHelper.convertPrice(minimumPayableAmount)}',
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.5)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: noPaymentMethod ? Dimensions.paddingSizeExtraSmall : 0),

              noPaymentMethod ? Text(
                'please_contact_the_admin'.tr,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.5)),
                textAlign: TextAlign.center,
              ) : const SizedBox(),

            ]),
          ),

        ]);
      }),
    );
  }
}
