import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_confirmation_bottom_sheet.dart';
import 'package:sixam_mart_delivery/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_delivery/features/home/widgets/location_access_dialog.dart';
import 'package:sixam_mart_delivery/features/language/controllers/language_controller.dart';
import 'package:sixam_mart_delivery/features/language/widgets/language_bottom_sheet_widget.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/profile/widgets/notification_status_change_bottom_sheet.dart';
import 'package:sixam_mart_delivery/features/profile/widgets/profile_level_details_widget.dart';
import 'package:sixam_mart_delivery/features/refer_and_earn/screens/refer_and_earn_screen.dart';
import 'package:sixam_mart_delivery/features/ride_module/add_vehicle/screens/vehicle_details_screen.dart';
import 'package:sixam_mart_delivery/features/ride_module/help_and_support/screens/help_and_support_screen.dart';
import 'package:sixam_mart_delivery/features/ride_module/leaderboard/screens/leaderboard_screen.dart';
import 'package:sixam_mart_delivery/features/ride_module/review/screens/review_screen.dart';
import 'package:sixam_mart_delivery/features/ride_module/ride_order/controllers/ride_controller.dart';
import 'package:sixam_mart_delivery/features/ride_module/safety/screen/safety_policy_screen.dart';
import 'package:sixam_mart_delivery/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_delivery/common/controllers/theme_controller.dart';
import 'package:sixam_mart_delivery/helper/pusher_helper.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/enums.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/confirmation_dialog_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_delivery/features/profile/widgets/profile_bg_widget.dart';
import 'package:sixam_mart_delivery/features/profile/widgets/profile_button_widget.dart';
import 'package:sixam_mart_delivery/features/profile/widgets/profile_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AppLifecycleListener _listener;

  bool isRideActive = AppConstants.appMode == AppMode.ride;

  @override
  void initState() {
    super.initState();

    _listener = AppLifecycleListener(
      onStateChange: _onStateChanged,
    );
    Get.find<ProfileController>().getProfile();
    if(isRideActive){
      Get.find<ProfileController>().getProfileLevelInfo();
    }
  }

  void _onStateChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.resumed:
        checkBatteryPermission();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
      case AppLifecycleState.paused:
        break;
    }
  }

  void checkBatteryPermission() async {
    Future.delayed(const Duration(milliseconds: 400), () async {
      if(await Permission.ignoreBatteryOptimizations.status.isDenied) {
        Get.find<ProfileController>().setBackgroundNotificationActive(false);
      } else {
        Get.find<ProfileController>().setBackgroundNotificationActive(true);
      }
    });
  }

  @override
  dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: GetBuilder<ProfileController>(builder: (profileController) {

        var config = Get.find<SplashController>().configModel;

        bool showReferAndEarn = profileController.profileModel != null && profileController.profileModel!.earnings == 1
            && (isRideActive ? (config?.riderReferralData?.referalStatus ?? false) : (config?.dmReferralData?.referalStatus ?? false));


        return profileController.profileModel == null ? const Center(child: CircularProgressIndicator()) : ProfileBgWidget(
          backButton: false,
          circularImage: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: Theme.of(context).cardColor),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                ClipOval(child: CustomImageWidget(
                  image: '${profileController.profileModel != null ? profileController.profileModel!.imageFullUrl : ''}',
                  height: 100, width: 100, fit: BoxFit.cover,
                )),

                if(isRideActive && config?.riderLevelStatus == 1 ) Positioned(
                  bottom: -5,
                  child: InkWell(
                    onTap: () {
                      Get.find<ProfileController>().getProfileLevelInfo();
                      Get.bottomSheet(const ProfileLevelDetailsWidget());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 850 : 200]!, spreadRadius: 1, blurRadius: 5)],
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      child: Text('${profileController.levelModel?.data?.currentLevel?.name}',
                          style: robotoRegular.copyWith(color: Theme.of(context).cardColor, fontSize: 12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          mainWidget: SingleChildScrollView(physics: const BouncingScrollPhysics(), child: Center(child: Container(
            width: 1170, color: Theme.of(context).cardColor,
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Column(children: [

              Text(
                '${profileController.profileModel!.fName} ${profileController.profileModel!.lName}',
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              const SizedBox(height: 5),
              if(isRideActive) Row( mainAxisSize: MainAxisSize.min, children: [
                Text('${profileController.profileModel!.avgRating.toString()} ',),

                const Icon(Icons.star_rounded, color: Colors.orange, size: 16),

                Text('(${'reviews'.tr} ${profileController.profileModel?.ratingCount})', style: robotoRegular.copyWith(color: Theme.of(context).hintColor.withValues(alpha: 0.5))),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              ]),
              const SizedBox(height: 15),

              Row(children: [
                ProfileCardWidget(title: 'days_since_joining'.tr, data: '${profileController.profileModel!.memberSinceDays}'),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                isRideActive
                    ? ProfileCardWidget(title: 'total_ride'.tr, data: profileController.profileModel!.totalRides.toString())
                    : ProfileCardWidget(title: 'order_completed'.tr, data: profileController.profileModel!.orderCount.toString()),
              ]),
              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeSmall,
                  vertical: Dimensions.paddingSizeExtraSmall,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 850 : 200]!, spreadRadius: 1, blurRadius: 5)],
                ),
                child: Row(children: [

                  Image.asset(Images.online, height: 25, width: 25, color: Theme.of(context).disabledColor),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('online_status'.tr, style: robotoRegular),
                      Text('manage_your_delivery_availability'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                    ],
                  )),

                  GetBuilder<ProfileController>(builder: (profileController) {
                    return GetBuilder<RideController>(builder: (rideController) {
                        return GetBuilder<OrderController>(builder: (orderController) {
                          bool isRideActive = AppConstants.appMode == AppMode.ride;
                          bool haveRunningRide = rideController.lastRideDetails != null && rideController.lastRideDetails!.isNotEmpty && rideController.lastRideDetails![0].currentStatus != 'completed' && rideController.lastRideDetails![0].currentStatus != 'cancelled';
                          return (profileController.profileModel != null) ? Transform.scale(
                            scale: 0.7,
                            child: CupertinoSwitch(
                              value: profileController.profileModel!.active == 1,
                              activeTrackColor: Theme.of(context).primaryColor,
                              inactiveTrackColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                              onChanged: (bool isActive) async {
                                if(!isRideActive && !isActive && (orderController.currentOrderList?.isNotEmpty ?? false)) {
                                  showCustomBottomSheet(
                                    child: CustomConfirmationBottomSheet(
                                      title: 'you_cant_go_offline'.tr,
                                      description: 'you_can_not_go_offline_now'.tr,
                                      buttonWidget: Padding(
                                        padding: const EdgeInsets.only(bottom: 20, top: 10),
                                        child: CustomButtonWidget(
                                          width: 150,
                                          onPressed: () {
                                            Get.back();
                                          },
                                          buttonText: 'okay'.tr,
                                        ),
                                      ),
                                    ),
                                  );
                                } else if(isRideActive && !isActive && haveRunningRide) {
                                  showCustomBottomSheet(
                                    child: CustomConfirmationBottomSheet(
                                      title: 'you_cant_go_offline'.tr,
                                      description: 'you_can_not_go_offline_now_for_ride'.tr,
                                      buttonWidget: Padding(
                                        padding: const EdgeInsets.only(bottom: 20, top: 10),
                                        child: CustomButtonWidget(
                                          width: 150,
                                          onPressed: () {
                                            Get.back();
                                          },
                                          buttonText: 'okay'.tr,
                                        ),
                                      ),
                                    ),
                                  );

                                } else {
                                  if(!isActive) {
                                    showCustomBottomSheet(
                                      child: CustomConfirmationBottomSheet(
                                        title: 'go_offline'.tr,
                                        description: 'are_you_sure_to_offline'.tr,
                                        image: Images.dmOfflineIcon,
                                        buttonWidget: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 40, right: 40, bottom: 20, top: 10,
                                          ),
                                          child: Row(children: [

                                            Expanded(
                                              child: CustomButtonWidget(
                                                onPressed: () {
                                                  profileController.updateActiveStatus();
                                                },
                                                buttonText: 'yes_proceed'.tr,
                                              ),
                                            ),
                                            const SizedBox(width: Dimensions.paddingSizeDefault),

                                            Expanded(
                                              child: CustomButtonWidget(
                                                onPressed: () {
                                                  Get.back();
                                                },
                                                buttonText: 'cancel'.tr,
                                                backgroundColor: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                                                fontColor: Theme.of(context).disabledColor,
                                                isBorder: true,
                                              ),
                                            ),

                                          ]),
                                        ),
                                      ),
                                    );
                                  }else {
                                    LocationPermission permission = await Geolocator.checkPermission();
                                    if(permission == LocationPermission.denied || permission == LocationPermission.deniedForever || (GetPlatform.isIOS ? false : permission == LocationPermission.whileInUse)) {
                                      _checkPermission(() => profileController.updateActiveStatus());
                                    }else {
                                      profileController.updateActiveStatus();
                                    }
                                  }
                                }
                              },
                            ),
                          ) : const SizedBox();
                        });
                      }
                    );
                  }),
                ]),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              ProfileButtonWidget(icon: Icons.dark_mode_outlined, title: 'dark_mode'.tr, isButtonActive: Get.isDarkMode, onTap: () {
                Get.find<ThemeController>().toggleTheme();
              }),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              GetBuilder<AuthController>(builder: (authController) {
                return ProfileButtonWidget(
                  iconImage: Images.settingIcon,
                  title: 'system_notification'.tr,
                  isButtonActive: authController.notification, onTap: () {
                  showCustomBottomSheet(child: const NotificationStatusChangeBottomSheet());
                  },
                );
              }),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              GetPlatform.isAndroid ? InkWell(
                onTap: () {
                  showBgNotificationBottomSheet(profileController.backgroundNotification);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                    vertical: Dimensions.paddingSizeExtraSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 850 : 200]!, spreadRadius: 1, blurRadius: 5)],
                  ),
                  child: Row(children: [

                    Image.asset(Images.notificationBall, height: 25, width: 25, color: Theme.of(context).disabledColor),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(child: Text('background_notification'.tr, style: robotoRegular)),

                    Transform.scale(
                      scale: 0.7,
                      child: CupertinoSwitch(
                        value: profileController.backgroundNotification,
                        activeTrackColor: Theme.of(context).primaryColor,
                        inactiveTrackColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                        onChanged: (bool isActive) {
                          showBgNotificationBottomSheet(profileController.backgroundNotification);
                        },
                      ),
                    ),
                  ]),
                ),
              ) : SizedBox(),
              SizedBox(height: GetPlatform.isAndroid ? Dimensions.paddingSizeSmall : 0),

              if(profileController.profileModel?.vehicle != null && isRideActive) Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                child: ProfileButtonWidget(iconImage: Images.car, title: 'vehicle_details'.tr, onTap: () {
                  Get.to(()=>  VehicleDetailsScreen());
                }),
              ),

              ProfileButtonWidget(iconImage: Images.security, title: 'change_password'.tr, onTap: () {
                Get.toNamed(RouteHelper.getResetPasswordRoute('', '', 'password-change'));
              }),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              ProfileButtonWidget(iconImage: Images.message, title: 'conversation'.tr, onTap: () {
                Get.toNamed(RouteHelper.getConversationListRoute());
              }),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              ProfileButtonWidget(iconImage: Images.translation, title: 'language'.tr, onTap: () {
                _manageLanguageFunctionality();
              }),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              ProfileButtonWidget(iconImage: Images.editUser, title: 'edit_profile'.tr, onTap: () {
                Get.toNamed(RouteHelper.getUpdateProfileRoute());
              }),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              if(isRideActive) Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                child: ProfileButtonWidget(iconImage: Images.noReview, title: 'my_reviews'.tr, onTap: () {
                  Get.to(()=> const ReviewScreen());
                }),
              ),

              if(isRideActive) Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                child: ProfileButtonWidget(iconImage: Images.leaderBoardIcon, title: 'leader_board'.tr, onTap: () {
                  Get.to(()=> const LeaderboardScreen());
                }),
              ),

              ProfileButtonWidget(iconImage: Images.support, title: 'help_and_support'.tr, onTap: () {
                Get.to(()=> const HelpAndSupportScreen());
              }),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              (profileController.profileModel != null && profileController.profileModel!.earnings == 1) ? Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                child: ProfileButtonWidget(iconImage: Images.earning, title: 'my_earning'.tr, onTap: () {
                  Get.toNamed(RouteHelper.getMyEarningRoute());
                }),
              ) : const SizedBox(),

              (profileController.profileModel != null && profileController.profileModel!.earnings == 1) ? Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                child: ProfileButtonWidget(iconImage: Images.emptyWallet, title: 'my_account'.tr, onTap: () {
                  Get.toNamed(RouteHelper.getMyAccountRoute());
                }),
              ) : const SizedBox(),

              Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                child: ProfileButtonWidget(icon: Icons.money, title: 'withdraw_method'.tr, onTap: () {
                  Get.toNamed(RouteHelper.getWithdrawMethodRoute());
                }),
              ),

              if(Get.find<SplashController>().configModel!.disbursementType == 'automated' && profileController.profileModel!.type != 'store_wise' && profileController.profileModel!.earnings != 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                  child: ProfileButtonWidget(icon: Icons.payments, title: 'disbursement'.tr, onTap: () {
                    Get.toNamed(RouteHelper.getDisbursementRoute());
                  }),
                ),

              if(showReferAndEarn)Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                child: ProfileButtonWidget(iconImage: Images.earning, title: 'refer_and_earn'.tr, onTap: () {
                  Get.to(()=> const ReferAndEarnScreen());
                }),
              ),

              if(isRideActive) Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                child: ProfileButtonWidget(iconImage: Images.shieldTick, title: 'safety'.tr, onTap: () {
                  Get.to(()=> const SafetyPolicyScreen());
                }),
              ),

              ProfileButtonWidget(iconImage: Images.document, title: 'terms_condition'.tr, onTap: () {
                Get.toNamed(RouteHelper.getTermsRoute());
              }),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              ProfileButtonWidget(iconImage: Images.document, title: 'privacy_policy'.tr, onTap: () {
                Get.toNamed(RouteHelper.getPrivacyRoute());
              }),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              ProfileButtonWidget(
                iconImage: Images.trash, title: 'delete_account'.tr,
                onTap: () {
                  Get.dialog(ConfirmationDialogWidget(icon: Images.warning, title: 'are_you_sure_to_delete_account'.tr,
                    description: 'it_will_remove_your_all_information'.tr, isLogOut: true,
                    onYesPressed: () => profileController.deleteDriver()),
                    useSafeArea: false,
                  );
                },
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              ProfileButtonWidget(icon: Icons.logout, title: 'logout'.tr, onTap: () {
                Get.back();
                Get.dialog(ConfirmationDialogWidget(icon: Images.support, description: 'are_you_sure_to_logout'.tr, isLogOut: true, onYesPressed: () {
                  PusherHelper().pusherDisconnectPusher();
                  Get.find<AuthController>().clearSharedData();
                  Get.find<ProfileController>().stopLocationRecord();
                  Get.offAllNamed(RouteHelper.getSignInRoute());
                }));
              }),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('${'version'.tr}:', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Text(AppConstants.appVersion.toString(), style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
              ]),

            ]),
          ))),
        );
      }),
    );
  }

  void showBgNotificationBottomSheet(bool allow) {
    Get.bottomSheet(Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
            
          Container(
            height: 5, width: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
            
          Text(
            '${!allow ? 'allow'.tr : 'disable'.tr} ${AppConstants.appName} ${!allow ? 'to_run_notification_in_background'.tr : 'from_running_notification_in_background'.tr}',
            textAlign: TextAlign.center,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
            
          Text(
            allow ? '(${AppConstants.appName} -> Battery -> Select Optimized or any Recommended)' : 'Or (${AppConstants.appName} ->  Battery -> No restriction)',
            textAlign: TextAlign.center,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
            
          _buildInfoText("you_will_be_able_to_get_order_notification_even_if_you_are_not_in_the_app".tr),
          _buildInfoText("${AppConstants.appName} ${!allow ? 'will_run_notification_service_in_the_background_always'.tr : 'will_not_run_notification_service_in_the_background_always'.tr}"),
          _buildInfoText(!allow ? "notification_will_always_send_alert_from_the_background".tr : 'notification_will_not_always_send_alert_from_the_background'.tr),
          const SizedBox(height: 20.0),
            
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("cancel".tr, style: robotoMedium),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
            
              ElevatedButton(
                onPressed: () async {
                  if(await Permission.ignoreBatteryOptimizations.status.isGranted) {
                    openAppSettings();
                  } else {
                    await Permission.ignoreBatteryOptimizations.request();
                  }
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  "okay".tr,
                  style: robotoMedium.copyWith(color: Theme.of(context).cardColor),
                ),
              ),
            ],
          ),
        ]),
      ),
    ), isScrollControlled: true).then((value) {
      checkBatteryPermission();
    });
  }

  Widget _buildInfoText(String text) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        text,
        style: robotoRegular,
      ),
    );
  }

  void _manageLanguageFunctionality() {
    Get.find<LocalizationController>().saveCacheLanguage(null);
    Get.find<LocalizationController>().searchSelectedLanguage();

    showModalBottomSheet(
      isScrollControlled: true, useRootNavigator: true, context: Get.context!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: const LanguageBottomSheetWidget(),
        );
      },
    ).then((value) => Get.find<LocalizationController>().setLanguage(Get.find<LocalizationController>().getCacheLocaleFromSharedPref()));
  }

  void _checkPermission(Function callback) async {
    LocationPermission permission = await Geolocator.requestPermission();
    permission = await Geolocator.checkPermission();

    while(Get.isDialogOpen == true) {
      Get.back();
    }

    if(permission == LocationPermission.denied) {
      Get.dialog(LocationAccessDialog(onConfirm: () async {
        Get.back();
        final perm = await Geolocator.requestPermission();
        if(perm == LocationPermission.deniedForever) await Geolocator.openAppSettings();
        if(GetPlatform.isAndroid) _checkPermission(callback);
      }));
    }else if(permission == LocationPermission.deniedForever || (GetPlatform.isIOS ? false : permission == LocationPermission.whileInUse)) {
      Get.dialog(LocationAccessDialog(onConfirm: () async {
        Get.back();
        await Geolocator.openAppSettings();
        Future.delayed(const Duration(seconds: 3), () {
          if(GetPlatform.isAndroid) _checkPermission(callback);
        });
      },
      ));
    }else {
      callback();
    }
  }

}
