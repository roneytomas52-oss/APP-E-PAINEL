import 'package:permission_handler/permission_handler.dart';
import 'package:sixam_mart_delivery/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_delivery/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixam_mart_delivery/features/home/widgets/active_order_widget.dart';
import 'package:sixam_mart_delivery/features/home/widgets/active_ride_widget.dart';
import 'package:sixam_mart_delivery/features/home/widgets/cash_in_hand_card_widget.dart';
import 'package:sixam_mart_delivery/features/home/widgets/home_earning_widget.dart';
import 'package:sixam_mart_delivery/features/home/widgets/order_count_widget.dart';
import 'package:sixam_mart_delivery/features/home/widgets/referal_card_widget.dart';
import 'package:sixam_mart_delivery/features/home/widgets/ride_activity_view.dart';
import 'package:sixam_mart_delivery/features/home/widgets/ride_floating_button_widget.dart';
import 'package:sixam_mart_delivery/features/home/widgets/ride_order_count_widget.dart';
import 'package:sixam_mart_delivery/features/home/widgets/vehicle_add_widget.dart';
import 'package:sixam_mart_delivery/features/notification/controllers/notification_controller.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/ride_module/ride_order/controllers/ride_controller.dart';
import 'package:sixam_mart_delivery/features/ride_module/trip/controllers/trip_controller.dart';
import 'package:sixam_mart_delivery/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/enums.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onNavigateToOrders});
  final Function()? onNavigateToOrders;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late final AppLifecycleListener _listener;
  bool _isNotificationPermissionGranted = true;
  bool _isBatteryOptimizationGranted = true;
  bool isRideActive = AppConstants.appMode == AppMode.ride;

  @override
  void initState() {
    super.initState();

    _checkSystemNotification();

    _listener = AppLifecycleListener(
      onStateChange: _onStateChanged,
    );

    _loadData();

    Future.delayed(const Duration(milliseconds: 200), () {
      checkPermission();
    });
  }

  Future<void> _loadData() async {

    Get.find<OrderController>().getIgnoreList();
    Get.find<OrderController>().removeFromIgnoreList();

    if(isRideActive){
      Get.find<RideController>().getLastRideDetail();
      Get.find<TripController>().getDailyLog();
      Get.find<TripController>().rideCancellationReasonList();
      Get.find<RideController>().ongoingTripList();
      Get.find<ProfileController>().getProfileLevelInfo();
      await Get.find<TripController>().getTripList(1);
    }else{
      await Get.find<OrderController>().getRunningOrders(1, willUpdate: false);
    }
    await Get.find<ProfileController>().getProfile();
    await Get.find<NotificationController>().getNotificationList();
  }

  Future<void> _checkSystemNotification() async {
    if(await Permission.notification.status.isDenied || await Permission.notification.status.isPermanentlyDenied) {
      await Get.find<AuthController>().setNotificationActive(false);
    }
  }

  // Listen to the app lifecycle state changes
  void _onStateChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.resumed:
        checkPermission();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
      case AppLifecycleState.paused:
        break;
    }
  }

  Future<void> checkPermission() async {
    var notificationStatus = await Permission.notification.status;
    var batteryStatus = await Permission.ignoreBatteryOptimizations.status;

    if(notificationStatus.isDenied || notificationStatus.isPermanentlyDenied) {
      setState(() {
        _isNotificationPermissionGranted = false;
        _isBatteryOptimizationGranted = true;
      });

      await Get.find<AuthController>().setNotificationActive(!notificationStatus.isDenied);

    } else if(batteryStatus.isDenied) {
      setState(() {
        _isBatteryOptimizationGranted = false;
        _isNotificationPermissionGranted = true;
      });
    } else {
      setState(() {
        _isNotificationPermissionGranted = true;
        _isBatteryOptimizationGranted = true;
      });
      Get.find<ProfileController>().setBackgroundNotificationActive(true);
    }

    if(batteryStatus.isDenied) {
      Get.find<ProfileController>().setBackgroundNotificationActive(false);
    }
  }

  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.request().isGranted) {
      checkPermission();
      return;
    } else {
      await openAppSettings();
    }

    checkPermission();
  }

  void requestBatteryOptimization() async {
    var status = await Permission.ignoreBatteryOptimizations.status;

    if (status.isGranted) {
      return;
    } else if(status.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    } else {
      openAppSettings();
    }

    checkPermission();
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(builder: (profileController){

      bool isRideActive = AppConstants.appMode == AppMode.ride;

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).cardColor,
          surfaceTintColor: Theme.of(context).cardColor,
          shadowColor: Theme.of(context).disabledColor.withValues(alpha: 0.5),
          elevation: 2,
          leading: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Image.asset(Images.logo, height: 30, width: 30),
          ),
          titleSpacing: 0,
          title: Text(AppConstants.appName, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoMedium.copyWith(
            color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeDefault,
          )),
          actions: [
            IconButton(
              icon: GetBuilder<NotificationController>(builder: (notificationController) {
                return Stack(children: [

                  Icon(Icons.notifications, size: 25, color: Theme.of(context).textTheme.bodyLarge!.color),

                  notificationController.hasNotification ? Positioned(top: 0, right: 0, child: Container(
                    height: 10, width: 10, decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error, shape: BoxShape.circle,
                    border: Border.all(width: 1, color: Theme.of(context).cardColor),
                  ),
                  )) : const SizedBox(),

                ]);
              }),
              onPressed: () => Get.toNamed(RouteHelper.getNotificationRoute()),
            ),

            const SizedBox(width: Dimensions.paddingSizeSmall),
          ],
        ),

        body: RefreshIndicator(
          onRefresh: () async {
            return await _loadData();
          },
          child: Column(children: [

            if(!_isNotificationPermissionGranted)
              permissionWarning(isBatteryPermission: false, onTap: requestNotificationPermission, closeOnTap: () {
                setState(() {
                  _isNotificationPermissionGranted = true;
                });
              }),

            if(!_isBatteryOptimizationGranted)
              permissionWarning(isBatteryPermission: true, onTap: requestBatteryOptimization, closeOnTap: () {
                setState(() {
                  _isBatteryOptimizationGranted = true;
                });
              }),

            Expanded(
              child: Stack(children: [
                SingleChildScrollView(
                  child: GetBuilder<ProfileController>(builder: (profileController) {

                    var config = Get.find<SplashController>().configModel;

                    bool showReferAndEarn = profileController.profileModel != null && profileController.profileModel!.earnings == 1
                        && (isRideActive ? (config?.riderReferralData?.referalStatus ?? false) : (config?.dmReferralData?.referalStatus ?? false));

                    bool addNewVehicle = profileController.profileModel?.vehicle == null || profileController.profileModel?.vehicle?.vehicleRequestStatus == "pending";

                    bool showEarningWidget = profileController.profileModel != null && profileController.profileModel!.earnings == 1;

                    bool showCashInHandCard = profileController.profileModel != null && profileController.profileModel!.cashInHands! > 0;


                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                      child: Column( children: [

                        if(isRideActive)...[
                         addNewVehicle
                             ? VehicleAddWidget(vehicle: profileController.profileModel?.vehicle)
                             : ActiveRideWidget(),
                        ] else...[
                          ActiveOrderWidget(onNavigateToOrders: ()=> Get.offAll(DashboardScreen(pageIndex: 2)))
                        ],

                        if(showEarningWidget) HomeEarningWidget(profileController: profileController,),

                        isRideActive
                            ? RideOrderCountWidget(profileController: profileController)
                            : OrderCountWidget(profileController: profileController),

                        isRideActive ? RideActivityView() : SizedBox(),

                        if(showCashInHandCard) CashInHandCardWidget(profileController: profileController),

                        if(showReferAndEarn) ReferralCardWidget()

                      ]),
                    );
                  }),
                ),

                if(isRideActive) RideMapNavigationWidget(),
              ]),
            ),
          ]),
        ),
      );
    });
  }

  Widget permissionWarning({required bool isBatteryPermission, required Function() onTap, required Function() closeOnTap}) {
    return GetPlatform.isAndroid ? Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.7),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Row(children: [

            if(isBatteryPermission)
              Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Image.asset(Images.allertIcon, height: 20, width: 20),
              ),

            Expanded(
              child: Row(children: [
                Flexible(
                  child: Text(
                    isBatteryPermission ? 'for_better_performance_allow_notification_to_run_in_background'.tr
                        : 'notification_is_disabled_please_allow_notification'.tr,
                    maxLines: 2, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.white),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                const Icon(Icons.arrow_circle_right_rounded, color: Colors.white, size: 24,),
              ]),
            ),

            // const SizedBox(width: 20),
          ]),
        ),
      ),
    ) : const SizedBox();
  }
}
