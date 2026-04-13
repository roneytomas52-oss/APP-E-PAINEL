import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/refer_and_earn/controllers/refer_and_earn_controller.dart';
import 'package:sixam_mart_delivery/features/refer_and_earn/widgets/referral_earn_bottomsheet_widget.dart';
import 'package:sixam_mart_delivery/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/enums.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:share_plus/share_plus.dart';

class ReferralDetails extends StatelessWidget {
  final bool status;
  const ReferralDetails({super.key, required this.status});

  @override
  Widget build(BuildContext context) {

    var config = Get.find<SplashController>().configModel;
    bool isRideActive = AppConstants.appMode == AppMode.ride;
    double referralAmount = isRideActive ? (config?.riderReferralData?.referalAmount ?? 0) :  (config?.dmReferralData?.referalAmount ?? 0);

    return Expanded(
      child: GetBuilder<ReferAndEarnController>(builder: (referAndEarnController){
        var config = Get.find<SplashController>().configModel;
        bool referralStatus = isRideActive ? (config?.riderReferralData?.referalStatus ?? false) : (config?.dmReferralData?.referalStatus ?? false);
        return referralStatus ? SingleChildScrollView(
          child: Column(children: [
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Image.asset(Images.homeReferralIcon,height: 120, width: 120),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Text('invite_friend_getRewards'.tr,style: robotoBold.copyWith(fontSize: 16)),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: RichText(text: TextSpan(
                  text: 'referral_bottom_sheet_note'.tr,
                  style: robotoRegular.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                    fontSize: Dimensions.fontSizeDefault, height: 1.5,
                  ),
                  children: [TextSpan(
                    text: '  ${PriceConverterHelper.convertPrice(referralAmount)}  ',
                    style: robotoBold,
                  ),
                    TextSpan(
                      text: 'wallet_balance'.tr,
                      style: robotoRegular.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                        fontSize: Dimensions.fontSizeDefault, height: 1.5,
                      ),
                    )
                  ]
              ),textAlign: TextAlign.center),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge * 1.5),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: SizedBox(
                height: 150,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    Container(
                      width: 140,
                      padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall,right: Dimensions.paddingSizeSmall,bottom: Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                      ),
                      child: Column(children: [
                        Align(alignment: Alignment.topRight,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).cardColor.withValues(alpha: 0.75),
                                shape: BoxShape.circle
                            ),
                            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),

                            child: const Text('1'),
                          ),
                        ),

                        Image.asset(Images.referralIcon1,height: 24,width: 24,color: Get.isDarkMode ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).textTheme.bodyLarge!.color),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Text('invite_or_share_the_code'.tr, textAlign: TextAlign.center,style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.6)
                        ))
                      ]),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Container(
                      width: 140,
                      padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall,right: Dimensions.paddingSizeSmall,bottom: Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                      ),
                      child: Column(children: [
                        Align(alignment: Alignment.topRight,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).cardColor.withValues(alpha: 0.75),
                                shape: BoxShape.circle
                            ),
                            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),

                            child: const Text('2'),
                          ),
                        ),

                        Image.asset(Images.referralIcon2, height: 24,width: 24,color: Get.isDarkMode ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).textTheme.bodyLarge!.color),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Text('your_friend_sign_up'.tr,textAlign: TextAlign.center,style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.6),
                        ))
                      ]),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Container(
                      width: 140,
                      padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall,right: Dimensions.paddingSizeSmall,bottom: Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                      ),
                      child: Column(children: [
                        Align(alignment: Alignment.topRight,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).cardColor.withValues(alpha: 0.75),
                                shape: BoxShape.circle
                            ),
                            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),

                            child: const Text('3'),
                          ),
                        ),

                        Image.asset(Images.referralIcon3,height: 24,width: 24,color: Get.isDarkMode ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).textTheme.bodyLarge!.color),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Text('both_you_and_friend_will'.tr,textAlign: TextAlign.center,style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.6),
                        ))
                      ]),
                    ),
                  ]),
                ),
              ),
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
            const SizedBox(height: Dimensions.paddingSizeDefault),

            InkWell(
              onTap: () => Get.bottomSheet(const ReferralEarnBottomSheetWidget(),isDismissible: false, isScrollControlled: true),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min,children: [
                Text('how_it_works'.tr,style: robotoMedium.copyWith(
                  decoration: TextDecoration.underline,
                  color: Colors.blue,
                  decorationColor:  Colors.blue,
                )),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                const Icon(Icons.help_outline, size: 20,)
              ]),
            ),

            const SizedBox(height: 30),

          ]),
        ) : Column(children: [
          const SizedBox(height: 100),

          Image.asset(Images.homeReferralIcon,height: 140,width: 140),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Text('stay_tuned_to_earn_big'.tr,
            style: robotoBold.copyWith(fontSize: 16),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge * 1.5),
            child: Text(
              'our_refer_and_earn_program_is_temporarily_paused'.tr,textAlign: TextAlign.center,
              style: robotoRegular.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                height: 1.5
              ),
            ),
          ),
        ]);
      }),
    );
  }

  Widget card({required String image, required String title, required String count}) {
    return Stack(
      children: [
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: Theme.of(Get.context!).disabledColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeDefault),
          margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          child: Column(children: [

            Image.asset(image, height: 30,),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Text(
              title,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(Get.context!).textTheme.bodyLarge!.color!.withValues(alpha: 0.6)),
              textAlign: TextAlign.center, maxLines: 4, overflow: TextOverflow.ellipsis,
            ),
          ]),
        ),

        Positioned(
          top: 0, right: 15,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(Get.context!).cardColor,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            child: Text(count, style: robotoMedium),
          ),
        ),
      ],
    );
  }

}
