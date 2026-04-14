import 'dart:async';
import 'dart:io';
import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/disbursement/helper/disbursement_helper.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/ride_module/ride_order/screens/pending_ride_list_screen.dart';
import 'package:sixam_mart_delivery/features/ride_module/ride_order/screens/ride_order_screen.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/helper/incoming_offer_dispatcher.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_alert_dialog_widget.dart';
import 'package:sixam_mart_delivery/features/dashboard/widgets/bottom_nav_item_widget.dart';
import 'package:sixam_mart_delivery/features/dashboard/widgets/new_request_dialog_widget.dart';
import 'package:sixam_mart_delivery/features/home/screens/home_screen.dart';
import 'package:sixam_mart_delivery/features/profile/screens/profile_screen.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/screens/order_request_screen.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/screens/order_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/util/enums.dart';
import 'package:sixam_mart_delivery/util/images.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  final bool fromOrderDetails;
  const DashboardScreen({super.key, required this.pageIndex, this.fromOrderDetails = false});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  PageController? _pageController;
  int _pageIndex = 0;
  late List<Widget> _screens;
  final _channel = const MethodChannel('com.sixamtech/app_retain');
  DisbursementHelper disbursementHelper = DisbursementHelper();
  bool _canExit = false;
  bool isRideActive = AppConstants.appMode == AppMode.ride;
  @override
  void initState() {
    super.initState();

    _pageIndex = widget.pageIndex;
    _pageController = PageController(initialPage: widget.pageIndex);

    _screens = [
      HomeScreen(onNavigateToOrders: () => _setPage(2)),
      isRideActive
          ? RideRequestScreen(onTap: () => _setPage(0))
          : OrderRequestScreen(onTap: () => _setPage(0)),
      isRideActive
          ? RideOrderScreen()
          : const OrderScreen(),
      const ProfileScreen(),
    ];

    showDisbursementWarningMessage();
    Get.find<OrderController>().getLatestOrders();
    
    IncomingOfferDispatcher.instance.registerOfferPresenter((IncomingOfferPresentation presentation) {
      if (!mounted || Get.isDialogOpen == true) {
        return;
      }

      if (presentation.isRequest) {
        Get.dialog(NewRequestDialogWidget(
          isRequest: true,
          onTap: _navigateRequestPage,
          orderId: presentation.orderId,
          hideItemCount: presentation.hideItemCount,
        ));
      } else {
        Get.dialog(NewRequestDialogWidget(
          isRequest: false,
          orderId: presentation.orderId,
          hideItemCount: presentation.hideItemCount,
          onTap: () {
            Get.offAllNamed(RouteHelper.getOrderDetailsRoute(presentation.orderId, fromNotification: true));
          },
        ));
      }
    });

  }

  Future<void> showDisbursementWarningMessage() async{
    if(!widget.fromOrderDetails){
      disbursementHelper.enableDisbursementWarningMessage(true);
    }
  }

  void _navigateRequestPage() {
    if(isDeliveryManActive()){
      _setPage(1);
    }
  }

  @override
  void dispose() {
    super.dispose();

    IncomingOfferDispatcher.instance.unregisterOfferPresenter();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async{
        if(_pageIndex != 0) {
          _setPage(0);
        }else {
          if(_canExit) {
            if (GetPlatform.isAndroid) {
              if (Get.find<ProfileController>().profileModel!.active == 1) {
                _channel.invokeMethod('sendToBackground');
              }
              SystemNavigator.pop();
            } else if (GetPlatform.isIOS) {
              exit(0);
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('back_press_again_to_exit'.tr, style: const TextStyle(color: Colors.white)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          ));
          _canExit = true;

          Timer(const Duration(seconds: 2), () {
            _canExit = false;
          });
        }
      },
      child: Scaffold(
        bottomNavigationBar: GetPlatform.isDesktop ? const SizedBox() : Container(
          height: 70 + MediaQuery.of(context).padding.bottom,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)],
          ),
          padding: EdgeInsets.only(top: 14),
          child: Row(children: [
            BottomNavItemWidget(iconData: Images.home, label: 'home'.tr, isSelected: _pageIndex == 0, onTap: () => _setPage(0)),
            BottomNavItemWidget(iconData: Images.request, label: 'request'.tr, isSelected: _pageIndex == 1, pageIndex: 1, onTap: () {
              _navigateRequestPage();
            }),
            BottomNavItemWidget(iconData: Images.bag, label: isRideActive ? "history".tr : 'orders'.tr, isSelected: _pageIndex == 2, onTap: () => _setPage(2)),
            BottomNavItemWidget(iconData: Images.userP, label: 'profile'.tr, isSelected: _pageIndex == 3, onTap: () => _setPage(3)),
          ]),
        ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: _screens.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return _screens[index];
          },
        ),
      ),
    );
  }

  void _setPage(int pageIndex) {
    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }
}

bool isDeliveryManActive({bool showPopUp = true}){
  if(Get.find<ProfileController>().profileModel != null && Get.find<ProfileController>().profileModel!.active == 1
      && Get.find<OrderController>().currentOrderList != null && Get.find<OrderController>().currentOrderList!.isEmpty) {
    return true;
  }else {
    if(Get.find<ProfileController>().profileModel == null || Get.find<ProfileController>().profileModel!.active == 0) {
      if(showPopUp){
        WidgetsBinding.instance.addPostFrameCallback((_){
          Get.dialog(CustomAlertDialogWidget(description: 'you_are_offline_now'.tr, onOkPressed: () => Get.back()));
        });
      }
      return false;
    }else {
      return true;
    }
  }
}