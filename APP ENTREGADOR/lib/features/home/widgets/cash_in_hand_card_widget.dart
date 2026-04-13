import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/color_resources.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class CashInHandCardWidget extends StatelessWidget {
  final ProfileController profileController;
  const CashInHandCardWidget({super.key, required this.profileController});

  @override
  Widget build(BuildContext context) {

    bool isPayable = profileController.profileModel != null && profileController.profileModel?.showPayNowButton == true;

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Theme.of(context).disabledColor, width: 0.2),
        boxShadow: [BoxShadow(color: Get.isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), blurRadius: 20, spreadRadius: 0, offset: const Offset(0, 5))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeLarge),
      margin: EdgeInsets.only(bottom: Dimensions.paddingSizeLarge, left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),

      child: Column(children: [

        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.all(10),
          child: Image.asset(Images.payMoney, height: 40,),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Text(
          PriceConverterHelper.convertPrice(profileController.profileModel!.cashInHands),
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: 'cash_in_your_hand'.tr, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.8))),

              if((profileController.profileModel!.dmMaxMyAccount != null) && (profileController.profileModel!.dmMaxMyAccount! > 0) && (profileController.profileModel!.cashInHands! > profileController.profileModel!.dmMaxMyAccount!))
                TextSpan(text: ' (${'limit_exceeded'.tr})', style: robotoRegular.copyWith(color: ColorResources.red, fontSize: Dimensions.fontSizeSmall - 2)),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        if(isPayable) CustomButtonWidget(
          width: 90, height: 40,
          isBold: false,
          fontSize: Dimensions.fontSizeDefault,
          buttonText: 'pay_now'.tr,
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () => Get.toNamed(RouteHelper.getMyAccountRoute()),
        ),

      ]),
    );
  }
}
