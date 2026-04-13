import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/enums.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';


class ReferralEarnBottomSheetWidget extends StatelessWidget {
  const ReferralEarnBottomSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {

    var config = Get.find<SplashController>().configModel;
    bool isRideActive = AppConstants.appMode == AppMode.ride;
    double referralAmount = isRideActive ? (config?.riderReferralData?.referalAmount ?? 0) :  (config?.dmReferralData?.referalAmount ?? 0);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius:const BorderRadius.only(
              topRight: Radius.circular(Dimensions.paddingSizeLarge),
              topLeft: Radius.circular(Dimensions.paddingSizeLarge),
            )
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          InkWell(
            onTap: ()=> Get.back(),
            child: Align(alignment: Alignment.topRight,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),

                child: Image.asset(Images.crossIcon,height: 10,width: 10),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Text('how_referrer_earn_work'.tr,style: robotoBold),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge * 2),
            child: Text('following_you_will_know'.tr,style: robotoRegular,textAlign: TextAlign.center),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Container(width: Get.width,
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeSmall)),
            ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            margin: const EdgeInsets.symmetric(vertical:Dimensions.paddingSizeSmall),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 10, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  margin:const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  height: 4,width: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).textTheme.bodyMedium!.color?.withValues(alpha: 0.6),
                    borderRadius: const BorderRadius.all(Radius.circular(100)),
                  ),
                ),

                Expanded(
                    child: Text('share_your_referral'.tr,  style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodyMedium!.color?.withValues(alpha: 0.7),
                      height: 1.5,
                    ),)
                ),
              ]),


              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  margin:const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  height: 4,width: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).textTheme.bodyMedium!.color?.withValues(alpha: 0.6),
                    borderRadius: const BorderRadius.all(Radius.circular(100)),
                  ),
                ),

                Expanded(
                    child: Text('when_your_friend_or_family'.tr,  style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodyMedium!.color?.withValues(alpha: 0.7),
                      height: 1.5,
                    ),)
                ),
              ]),


              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  margin:const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  height: 4,width: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).textTheme.bodyMedium!.color?.withValues(alpha: 0.6),
                    borderRadius: const BorderRadius.all(Radius.circular(100)),
                  ),
                ),

                Expanded(
                  child: RichText(text: TextSpan(
                      text: '${'you_will_receive_a'.tr} ',
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodyMedium!.color?.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: '${PriceConverterHelper.convertPrice(referralAmount)} ',
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                        ),
                        TextSpan(
                          text: '${'when_your_friend_complete'.tr} ',
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).textTheme.bodyMedium!.color?.withValues(alpha: 0.7),
                            height: 1.5,
                          ),
                        )
                      ]
                  )),
                ),
              ]),


              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  margin:const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  height: 4,width: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).textTheme.bodyMedium!.color?.withValues(alpha: 0.6),
                    borderRadius: const BorderRadius.all(Radius.circular(100)),
                  ),
                ),

                Expanded(
                  child: Text('your_friend_will'.tr,  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodyMedium!.color?.withValues(alpha: 0.7),
                    height: 1.5,
                  )),
                ),
              ]),


            ]),
          ),
        ]),
      ),
    );
  }
}