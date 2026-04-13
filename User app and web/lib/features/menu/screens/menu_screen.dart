import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/auth/widgets/auth_dialog_widget.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/home/controllers/home_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/controllers/taxi_cart_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/confirmation_dialog.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/menu/widgets/portion_widget.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).cardColor,
      body: GetBuilder<ProfileController>(builder: (profileController) {
        final bool isLoggedIn = AuthHelper.isLoggedIn();

        return Column(children: [

          Container(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Padding(
              padding: const EdgeInsets.only(
                left: Dimensions.paddingSizeLarge, right: Dimensions.paddingSizeLarge,
                top: 45, bottom: Dimensions.paddingSizeDefault,
              ),
              child: Column(
                children: [
                  Row(children: [

                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(1),
                      child: ClipOval(child: CustomImage(
                        placeholder: Images.guestIconLight,
                        image: '${(profileController.userInfoModel != null && isLoggedIn) ? profileController.userInfoModel!.imageFullUrl : ''}',
                        height: 50, width: 50, fit: BoxFit.cover,
                      )),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),

                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        isLoggedIn && profileController.userInfoModel == null ? Shimmer(
                          child: Container(
                            height: 15, width: 150,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ) : Text(
                          isLoggedIn ? '${profileController.userInfoModel?.fName ?? ''} ${profileController.userInfoModel?.lName ?? ''}' : 'guest_user'.tr,
                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).cardColor),
                        ),
                        SizedBox(height: isLoggedIn && profileController.userInfoModel == null ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeExtraSmall),

                        isLoggedIn && profileController.userInfoModel == null ? Shimmer(
                          child: Container(
                            height: 15, width: 100,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ) : isLoggedIn ? Text(
                          '${'joined'.tr} ${profileController.userInfoModel != null ? DateConverter.containTAndZToUTCFormat(profileController.userInfoModel!.createdAt!) : ''}',
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
                        ) : SizedBox(),

                      ]),
                    ),

                    IconButton(
                      onPressed: (){
                        Get.find<ThemeController>().toggleTheme();
                      },
                      icon: Get.find<ThemeController>().darkTheme ? Icon(Icons.sunny, color:Colors.white) : Image.asset(Images.moon, height: 30, color: Colors.white,),
                    ),


                  ]),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  !isLoggedIn ? Column(children: [
                    Divider(
                      thickness: 0.2, color: Theme.of(context).cardColor,
                    ),

                    Row(children: [
                      Expanded(child: Text(
                        'for_more_personalised_and_smooth_experience'.tr,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
                      )),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      TextButton(
                        style:  TextButton.styleFrom(
                          backgroundColor: Theme.of(context).cardColor.withValues(alpha: 0.8),
                          minimumSize: Size(130, 30),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            side: BorderSide.none,
                          ),
                        ),
                        onPressed: () async {
                          if(!ResponsiveHelper.isDesktop(context)) {
                            await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
                            if(AuthHelper.isLoggedIn()) {
                              profileController.getUserInfo();
                            }
                          }else{
                            Get.dialog(const Center(child: AuthDialogWidget(exitFromApp: true, backFromThis: true)));
                          }
                          },
                        child: Text('login_signup'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color),),
                      ),

                    ]),
                  ]) : const SizedBox(),
                ],
              ),
            ),
          ),

          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
            child: Column(children: [

              if(isLoggedIn && profileController.userInfoModel != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  child: Row(children: [
                    infoCard(profileController, context, Images.loyaltyIcon, double.tryParse(profileController.userInfoModel!.loyaltyPoint.toString()) ?? 0, 'loyalty_points'.tr),
                    const SizedBox(width: Dimensions.paddingSizeDefault),

                    infoCard(profileController, context, Images.orderProfile, double.tryParse(profileController.userInfoModel!.orderCount.toString()) ?? 0, 'orders'.tr),
                    const SizedBox(width: Dimensions.paddingSizeDefault),

                    infoCard(profileController, context, Images.walletProfile, double.tryParse(profileController.userInfoModel!.walletBalance.toString()) ?? 0, 'wallet_balance'.tr, isAmount: true),
                  ]),
                ),

              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeSmall),
                  child: Text(
                    'general'.tr,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor),
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
                  margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(children: [
                    PortionWidget(icon: Images.profileIcon, title: 'edit_profile'.tr, route: RouteHelper.getUpdateProfileRoute()),
                    PortionWidget(icon: Images.addressIcon, title: 'my_address'.tr, route: RouteHelper.getAddressRoute()),
                    // PortionWidget(icon: Images.languageIcon, title: 'language'.tr, hideDivider: true, onTap: ()=> _manageLanguageFunctionality(), route: ''),
                    PortionWidget(icon: Images.settings, title: 'settings'.tr, hideDivider: true, route: RouteHelper.getSettingScreen()),
                  ]),
                )

              ]),

              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                  child: Text(
                    'promotional_activity'.tr,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor),
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
                  margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(children: [
                    PortionWidget(
                      icon: Images.couponIcon, title: 'coupon'.tr, route: RouteHelper.getCouponRoute(),
                      hideDivider: Get.find<SplashController>().configModel!.loyaltyPointStatus == 1 || Get.find<SplashController>().configModel!.customerWalletStatus == 1 ? false : true,
                    ),

                    (Get.find<SplashController>().configModel!.loyaltyPointStatus == 1) ? PortionWidget(
                        icon: Images.pointIcon, title: 'loyalty_points'.tr, route: RouteHelper.getLoyaltyRoute(),
                      hideDivider: Get.find<SplashController>().configModel!.customerWalletStatus == 1 ? false : true,
                      // suffix: !isLoggedIn ? null : '${profileController.userInfoModel?.loyaltyPoint != null ? profileController.userInfoModel!.loyaltyPoint.toString() : '0'} ${'points'.tr}' ,
                    ) : const SizedBox(),

                    (Get.find<SplashController>().configModel!.customerWalletStatus == 1) ? PortionWidget(
                        icon: Images.walletIcon, title: 'my_wallet'.tr, hideDivider: true, route: RouteHelper.getWalletRoute(),
                      // suffix: !isLoggedIn ? null : PriceConverter.convertPrice(profileController.userInfoModel != null ? profileController.userInfoModel!.walletBalance : 0),
                    ) : const SizedBox(),
                  ]),
                )
              ]),

              (Get.find<SplashController>().configModel!.refEarningStatus == 1 ) || (Get.find<SplashController>().configModel!.toggleDmRegistration! && !ResponsiveHelper.isDesktop(context)) ||
                  (Get.find<SplashController>().configModel!.toggleStoreRegistration! && !ResponsiveHelper.isDesktop(context)) ?
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                  child: Text(
                    'earnings'.tr,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor),
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
                  margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(children: [

                    (Get.find<SplashController>().configModel!.refEarningStatus == 1 ) ? PortionWidget(
                        icon: Images.referIcon, title: 'refer_and_earn'.tr, route: RouteHelper.getReferAndEarnRoute(),
                      hideDivider: (Get.find<SplashController>().configModel!.toggleDmRegistration! && !ResponsiveHelper.isDesktop(context)) ||
                          (Get.find<SplashController>().configModel!.toggleStoreRegistration! && !ResponsiveHelper.isDesktop(context)) ? false : true,
                    ) : const SizedBox(),

                    (Get.find<SplashController>().configModel!.toggleDmRegistration! && !ResponsiveHelper.isDesktop(context)) ? PortionWidget(
                        icon: Images.dmIcon, title: 'join_as_a_delivery_man'.tr, route: RouteHelper.getDeliverymanRegistrationRoute(),
                      hideDivider: (Get.find<SplashController>().configModel!.toggleStoreRegistration! && !ResponsiveHelper.isDesktop(context)) ? false : true,
                    ) : const SizedBox(),

                    ((Get.find<SplashController>().configModel!.toggleRiderRegistration ?? false) && !ResponsiveHelper.isDesktop(context)) ? PortionWidget(
                      icon: Images.dmIcon, title: 'join_as_a_rider'.tr, route: RouteHelper.getRiderRegistrationRoute(),
                      hideDivider: (Get.find<SplashController>().configModel!.toggleStoreRegistration! && !ResponsiveHelper.isDesktop(context)) ? false : true,
                    ) : const SizedBox(),

                    (Get.find<SplashController>().configModel!.toggleStoreRegistration! && !ResponsiveHelper.isDesktop(context)) ? PortionWidget(
                        icon: Images.storeIcon, title: 'open_vendor'.tr, hideDivider: true, route: RouteHelper.getRestaurantRegistrationRoute(),
                    ) : const SizedBox(),
                  ]),
                )
              ]) : const SizedBox(),

              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                  child: Text(
                    'help_and_support'.tr,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor),
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
                  margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(children: [
                    PortionWidget(icon: Images.chatIcon, title: 'live_chat'.tr, route: RouteHelper.getConversationRoute()),
                    PortionWidget(icon: Images.helpIcon, title: 'help_and_support'.tr, route: RouteHelper.getSupportRoute()),
                    // PortionWidget(icon: Images.aboutIcon, title: 'about_us'.tr, route: RouteHelper.getHtmlRoute('about-us')),
                    PortionWidget(icon: Images.termsIcon, title: 'terms_conditions'.tr, route: RouteHelper.termsAndCondition),
                    PortionWidget(icon: Images.privacyIcon, title: 'privacy_policy'.tr, route: RouteHelper.privacyPolicy),
                    if(Get.find<SplashController>().module?.moduleType == 'ride-share')
                      PortionWidget(icon: Images.privacyIcon, title: 'safety_policy'.tr, route: RouteHelper.safety),

                    (Get.find<SplashController>().configModel!.refundPolicyStatus == 1 ) ? PortionWidget(
                        icon: Images.refundIcon, title: 'refund_policy'.tr, route: RouteHelper.refundPolicy,
                      hideDivider: (Get.find<SplashController>().configModel!.cancellationPolicyStatus == 1 ) ||
                          (Get.find<SplashController>().configModel!.shippingPolicyStatus == 1 ) ? false : true,
                    ) : const SizedBox(),

                    (Get.find<SplashController>().configModel!.cancellationPolicyStatus == 1 ) ? PortionWidget(
                        icon: Images.cancelationIcon, title: 'cancellation_policy'.tr, route: RouteHelper.cancellationPolicy,
                      hideDivider: (Get.find<SplashController>().configModel!.shippingPolicyStatus == 1 ) ? false : true,
                    ) : const SizedBox(),

                    (Get.find<SplashController>().configModel!.shippingPolicyStatus == 1 ) ? PortionWidget(
                        icon: Images.shippingIcon, title: 'shipping_policy'.tr, hideDivider: true, route: RouteHelper.shippingPolicy
                    ) : const SizedBox(),
                  ]),
                )
              ]),

              InkWell(
                onTap: () async {
                  if(AuthHelper.isLoggedIn()) {
                    Get.dialog(ConfirmationDialog(icon: Images.support, description: 'are_you_sure_to_logout'.tr, isLogOut: true, onYesPressed: () async {
                      Get.find<AuthController>().resetOtpView();
                      Get.find<ProfileController>().clearUserInfo();
                      Get.find<AuthController>().socialLogout();
                      Get.find<CartController>().clearCartList(canRemoveOnline: false);
                      Get.find<FavouriteController>().removeFavourite();
                      await Get.find<AuthController>().clearSharedData();
                      Get.find<HomeController>().forcefullyNullCashBackOffers();
                      if(Get.find<SplashController>().module != null) {
                        Get.find<TaxiCartController>().getCarCartList();
                      }
                      // Get.offAllNamed(RouteHelper.getInitialRoute());
                      Get.back();
                      showCustomSnackBar('logout_successful'.tr, isError: false);
                    }), useSafeArea: false);
                  }else {
                    Get.find<FavouriteController>().removeFavourite();
                    await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
                    if(AuthHelper.isLoggedIn()) {
                      await Get.find<FavouriteController>().getFavouriteList();
                      profileController.getUserInfo();
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                      child: Icon(Icons.power_settings_new_sharp, size: 18, color: Theme.of(context).cardColor),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Text(AuthHelper.isLoggedIn() ? 'logout'.tr : 'sign_in'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge))
                  ]),
                ),
              ),

              SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtremeLarge : 100),

            ]),
          )),
        ]);
      }),
    );
  }

  Widget infoCard(ProfileController profileController, BuildContext context, String image, double value, String title, {bool isAmount = false}) {
    return  Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: Theme.of(context).disabledColor, width: 0.2),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
        ),
        // margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall+3),
        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
        child: Column(children: [
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Image.asset(image, height: 30, width: 30),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
            child: Text(
              isAmount ? PriceConverter.convertPrice(value, forMenuWallet: true) : value.toStringAsFixed(0),
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
            child: Text(
              title,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5)),
            ),
          ),
        ]),
      ),
    );
  }

}
