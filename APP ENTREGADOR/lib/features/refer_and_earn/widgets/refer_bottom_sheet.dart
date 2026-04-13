import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/enums.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class ReferBottomSheet extends StatefulWidget {
  const ReferBottomSheet({super.key});

  @override
  State<ReferBottomSheet> createState() => _ReferBottomSheetState();
}

class _ReferBottomSheetState extends State<ReferBottomSheet> {
  @override
  Widget build(BuildContext context) {

    var config = Get.find<SplashController>().configModel;
    bool isRideActive = AppConstants.appMode == AppMode.ride;
    double referralAmount = isRideActive ? (config?.riderReferralData?.referalAmount ?? 0) :  (config?.dmReferralData?.referalAmount ?? 0);
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Container(
            height: 4, width: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Image.asset(Images.shareImage, width: 140),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Text('invite_friend_getRewards'.tr,style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35),
            child: RichText(text: TextSpan(
                text: 'referral_bottom_sheet_note'.tr,
                style: robotoRegular.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                  fontSize: Dimensions.fontSizeDefault - 1, height: 1.5,
                ),
                children: [TextSpan(
                  text: '  ${PriceConverterHelper.convertPrice(referralAmount)}  ',
                  style: robotoBold,
                ),
                  TextSpan(
                    text: 'wallet_balance'.tr,
                    style: robotoRegular.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                      fontSize: Dimensions.fontSizeDefault - 1, height: 1.5,
                    ),
                  )
                ]
            ),textAlign: TextAlign.center),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

          Container(
            width: Get.width * 0.9,
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.25))
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(Get.find<ProfileController>().profileModel?.refCode ?? '',style: robotoBold),

              InkWell(
                onTap: (){
                  Clipboard.setData(ClipboardData(text: Get.find<ProfileController>().profileModel?.refCode ?? '')).then((_){
                    showCustomSnackBar('copied'.tr,isError: false);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).highlightColor.withValues(alpha: 0.2),
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(Dimensions.radiusDefault), bottomRight: Radius.circular(Dimensions.radiusDefault)),
                  ),
                  child: Icon(Icons.copy_rounded,color: Get.isDarkMode ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).primaryColor),
                ),
              )
            ]),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge * 2),

          CustomButtonWidget(
            onPressed: () async{
              await SharePlus.instance.share(
                ShareParams(
                  text: 'Greetings, \n${Get.find<SplashController>().configModel?.businessName} is the best delivery platform in the country. Use my referral code "${Get.find<ProfileController>().profileModel?.refCode ?? ''}" while sign-up and get a discount on your first ride/order!',
                ),
              );
            },
            width: Get.width * 0.5,
            buttonText: 'invite_friends'.tr,
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),
        ]),
      ),
    );
  }
}
