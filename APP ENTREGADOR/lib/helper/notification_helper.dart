import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sixam_mart_delivery/common/widgets/level_congratulations_dialog_widget.dart';
import 'package:sixam_mart_delivery/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_delivery/features/chat/controllers/chat_controller.dart';
import 'package:sixam_mart_delivery/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/services/incoming_offer_dispatcher.dart';
import 'package:sixam_mart_delivery/features/notification/controllers/notification_controller.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart_delivery/features/ride_module/ride_order/screens/pending_ride_list_screen.dart';
import 'package:sixam_mart_delivery/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_delivery/helper/custom_print_helper.dart';
import 'package:sixam_mart_delivery/helper/incoming_offer_dispatcher.dart' show IncomingOfferSource;
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:sixam_mart_delivery/features/my_account/screens/my_account_screen.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/screens/order_request_screen.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/screens/order_screen.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/ride_module/map/controllers/ride_map_controller.dart';
import 'package:sixam_mart_delivery/features/ride_module/map/screens/map_screen.dart';
import 'package:sixam_mart_delivery/features/ride_module/review/screens/review_screen.dart';
import 'package:sixam_mart_delivery/features/ride_module/ride_order/controllers/ride_controller.dart';
import 'package:sixam_mart_delivery/features/ride_module/ride_order/screens/ongoing_ride_list_screen.dart';
import 'package:sixam_mart_delivery/features/ride_module/safety/controllers/safety_alert_controller.dart';
import 'package:sixam_mart_delivery/helper/ride_helper.dart';
import 'package:sixam_mart_delivery/features/ride_module/ride_order/screens/ride_details_screen.dart';




class NotificationHelper {

  static Future<void> initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize = const AndroidInitializationSettings('notification_icon');
    var iOSInitialize = const DarwinInitializationSettings();
    var initializationsSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation < AndroidFlutterLocalNotificationsPlugin>()!.requestNotificationsPermission();
    flutterLocalNotificationsPlugin.initialize(initializationsSettings, onDidReceiveNotificationResponse: (load) async{
      try{
        if(load.payload!.isNotEmpty){
          NotificationBodyModel payload = NotificationBodyModel.fromJson(jsonDecode(load.payload!));

          final Map<NotificationType, Function> notificationActions = {
            NotificationType.order: () => Get.toNamed(RouteHelper.getOrderDetailsRoute(payload.orderId, fromNotification: true)),
            NotificationType.order_request: () => Get.toNamed(RouteHelper.getMainRoute('order-request')),
            NotificationType.block: () => Get.offAllNamed(RouteHelper.getSignInRoute()),
            NotificationType.unblock: () => Get.offAllNamed(RouteHelper.getSignInRoute()),
            NotificationType.otp: () => null,
            NotificationType.unassign: () => Get.to(const DashboardScreen(pageIndex: 1)),
            NotificationType.message: () => Get.toNamed(RouteHelper.getChatRoute(notificationBody: payload, conversationId: payload.conversationId, fromNotification: true)),
            NotificationType.withdraw: () => Get.toNamed(RouteHelper.getMyAccountRoute()),
            NotificationType.general: () => Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true)),
          };

          notificationActions[payload.notificationType]?.call();
        }
      }catch(_){}
      return;
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print("onMessage message type:${message.data['type']}");
        print("onMessage message:${message.data}");
      }

      IncomingOfferDispatcher.instance.dispatchFcmMessage(message, source: 'fcm_foreground');

      bool pusherDisconnected = Get.find<SplashController>().pusherConnectionStatus == null || Get.find<SplashController>().pusherConnectionStatus == 'Disconnected' || (Get.find<SplashController>().configModel?.webSocketStatus == false);
      final bool handledIncomingOffer = IncomingOfferDispatcher.instance.handleRemotePayload(
        message.data,
        source: IncomingOfferSource.fcmForeground,
      );

      if(message.data['type'] == 'message' && Get.currentRoute.startsWith(RouteHelper.chatScreen)){
        if(Get.find<AuthController>().isLoggedIn()) {
          Get.find<ChatController>().getConversationList(1);
          if(Get.find<ChatController>().messageModel!.conversation!.id.toString() == message.data['conversation_id'].toString()) {
            Get.find<ChatController>().getMessages(
              1, NotificationBodyModel(
              notificationType: NotificationType.message,
              customerId: message.data['sender_type'] == AppConstants.user ? 0 : null,
              vendorId: message.data['sender_type'] == AppConstants.vendor ? 0 : null,
              adminId: message.data['sender_type'] == AppConstants.admin ? 0 : null,
            ),
              null, int.parse(message.data['conversation_id'].toString()),
            );
          }else {
            NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin);
          }
        }
      }else if(message.data['type'] == 'message' && Get.currentRoute.startsWith(RouteHelper.conversationListScreen)) {
        if(Get.find<AuthController>().isLoggedIn()) {
          Get.find<ChatController>().getConversationList(1);
        }
        NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin);
      }else if(message.data['type'] == 'otp'){
        NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin);
      }else if(message.data['type'] == 'deliveryman_referral'){
        NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin);
      }else {
        String? type = message.data['type'];

        if(message.data['type'] == 'message' && Get.currentRoute.startsWith('/MapScreen')) {
          Get.find<RideController>().setRideGetMessage(true);
        }

        if (!handledIncomingOffer && type != 'assign' && type != 'new_order' && type != 'order_request') {
          NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin);
          Get.find<OrderController>().getRunningOrders(1, status: 'all');
          Get.find<OrderController>().getOrderCount(Get.find<OrderController>().orderType);
          Get.find<OrderController>().getLatestOrders();
          Get.find<NotificationController>().getNotificationList();
        }
      }

      if (message.data['action'] == "driver_new_ride_request" && pusherDisconnected) {

        print("Connected =====> Connection get from Notification/ Current Pusher Status=====> ${Get.find<SplashController>().pusherConnectionStatus}");

        _whenNewRequestFound(message);

      }
      else if (message.data['action'] == "driver_trip_request_canceled" && pusherDisconnected) {

        Get.find<RideController>().getPendingRideRequestList(1);
        Get.find<RiderMapController>().setRideCurrentState(RideState.initial);

      }
      else if (message.data['action'] == "trip_completed") {
        _whenRideComplete(message);

      }
      else if (message.data['action'] == "driver_bid_accepted") {
        ///Bid Ride Accepted in this case....
        _whenCustomerBidAccept(message);

      }
      else if (message.data['action'] == "coupon_removed" || message.data['action'] == "coupon_applied") {
        Get.find<RideController>().getFinalFare(message.data['ride_request_id']);

      }
      else if (message.data['action'] == "payment_successful" && message.data['type'] == "ride_request") {
        _whenRidePaymentSuccess(message);

      }
      else if (message.data['action'] == "driver_customer_canceled_trip" && pusherDisconnected) {
        print("Connected =====> Connection get from Notification/ Current Pusher Status=====> ${Get.find<SplashController>().pusherConnectionStatus}");
        _whenCustomerCancelTrip(message);

      }
      else if (message.data['action'] == "another_driver_assigned") {
        _whenCustomerCancelTrip(message, isAnotherDriverAssigned: true);

      }
      else if ((message.data['action'] == "customer_trip_completed" || message.data['action'] == "another_driver_assigned") && pusherDisconnected) {
        print("Connected =====> Connection get from Notification/ Current Pusher Status=====> ${Get.find<SplashController>().pusherConnectionStatus}");
        Get.offAll(()=> RideDetailsScreen(rideId: message.data['ride_request_id']));

      }
      else if (message.data['type'] != 'message' && checkContainsAction(message.data['action'])) {
        Get.find<ProfileController>().getProfile().then((value) {
          if (value != null) {
            Get.find<RiderMapController>().setRideCurrentState(RideState.initial);
            Get.offAllNamed(RouteHelper.getInitialRoute());
          }
        });

      }
      else if(message.data['action'] == "customer_rejected_bid"){
        if((Get.find<RideController>().ongoingRide ?? []).isEmpty){
          // Get.offAll(() => const DashboardScreen());
          Get.offAllNamed(RouteHelper.getInitialRoute());
        }else{
          if(Get.currentRoute == '/RideRequestScreen'){
            Get.back();
          }
        }

      }
      else if(message.data['action'] == 'identity_image_approved' || message.data['action'] == 'identity_image_rejected'){
        Get.find<ProfileController>().getProfile();

      }
      else if(message.data['action'] == 'other_level_up'){
        _whenDriverLevelUp(message);

      }
      else if(message.data['action'] == "other_withdraw_request_rejected" || message.data['action'] == "other_withdraw_request_approved"){
        Get.find<ProfileController>().getProfile();
        // Get.find<WalletController>().getWithdrawPendingList(1);

      }
      else if(message.data['action'] == "other_withdraw_request_settled"){
        Get.find<ProfileController>().getProfile();
        // Get.find<WalletController>().getWithdrawSettledList(1);

      }
      else if(message.data['action'] == "other_admin_collected_cash"){
        Get.find<ProfileController>().getProfile();
        // Get.find<WalletController>().getPayableHistoryList(1);

      }
      else if(message.data['action'] == 'trip_canceled'){
        // Get.offAll(const DashboardScreen());
        Get.offAllNamed(RouteHelper.getInitialRoute());

      }
      else if(message.data['action'] == 'other_referral_reward_received' && Get.find<AuthController>().isLoggedIn()){
        // Get.find<TransactionController>().getRideIncomeStatement(1);
        // Get.find<ProfileController>().getProfile();
      }
      else if(message.data['action'] == 'other_safety_problem_resolved'){
        Get.find<SafetyAlertController>().getSafetyAlertDetails(message.data['ride_request_id']);

      }
      else if( message.data['action'] =="customer_payment_successful" && pusherDisconnected){
        print("Connected =====> Connection get from Notification/ Current Pusher Status=====> ${Get.find<SplashController>().pusherConnectionStatus}");
        Get.find<RideController>().getRideDetails(message.data['ride_request_id']);
      }
      else if( message.data['action'] =="customer_another_driver_assigned" && pusherDisconnected){
        print("Connected =====> Connection get from Notification/ Current Pusher Status=====> ${Get.find<SplashController>().pusherConnectionStatus}");
        Get.find<RiderMapController>().setRideCurrentState(RideState.initial);
        Get.offAllNamed(RouteHelper.getInitialRoute());
      }


    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print("onOpenApp message type:${message.data['type']}");
      }
      IncomingOfferDispatcher.instance.handleRemotePayload(
        message.data,
        source: IncomingOfferSource.fcmOpenedApp,
        triggerPresentation: false,
      );

      try{
        if(message.data.isNotEmpty){
          NotificationBodyModel notificationBody = convertNotification(message.data)!;

          final Map<NotificationType, Function> notificationActions = {
            NotificationType.order: () => Get.toNamed(RouteHelper.getOrderDetailsRoute(int.parse(message.data['order_id']), fromNotification: true)),
            NotificationType.order_request: () {
              if(isDeliveryManActive()){
                return Get.toNamed(RouteHelper.getMainRoute('order-request'));
              }
            },
            NotificationType.block: () => Get.offAllNamed(RouteHelper.getSignInRoute()),
            NotificationType.unblock: () => Get.offAllNamed(RouteHelper.getSignInRoute()),
            NotificationType.otp: () => null,
            NotificationType.unassign: () => Get.to(const DashboardScreen(pageIndex: 1)),
            NotificationType.message: () => Get.toNamed(RouteHelper.getChatRoute(notificationBody: notificationBody, conversationId: notificationBody.conversationId, fromNotification: true)),
            NotificationType.withdraw: () => Get.toNamed(RouteHelper.getMyAccountRoute()),
            NotificationType.general: () => Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true)),
            NotificationType.ride_request: () => Get.to(()=> RideDetailsScreen(rideId: notificationBody.rideRequestId ?? "")),
          };

          notificationActions[notificationBody.notificationType]?.call();
        }
      }catch (_) {}
    });
  }


  static Future<void> notificationToRoute(NotificationBodyModel data, {bool formSplash = false, String? userName}) async {
    // if (data['action'] == "new_message") {
    //   Get.find<ChatController>().getConversation(data['type'], 1);
    //   _toRoute(formSplash, MessageScreen(channelId: data['type'], tripId: data['ride_request_id'], userName: userName ?? data['user_name']));
    //
    // }


    if (data.action == "driver_new_ride_request") {

      Get.find<RideController>().ongoingTripList().then((value){
        if((Get.find<RideController>().ongoingRide ?? []).isEmpty){
          Get.find<RideController>().getRideDetailBeforeAccept(data.rideRequestId!).then((value) {
            if (value.statusCode == 200) {
              Get.find<RideController>().getPendingRideRequestList(1, limit: 100);
              // Get.find<RideController>().setRideId(data['ride_request_id']);
              Get.find<RiderMapController>().getPickupToDestinationPolyline();
              Get.find<RiderMapController>().setRideCurrentState(RideState.pending);
              Get.find<RideController>().updateRoute(false, notify: true);

              _toRoute(formSplash, const MapScreen());

            }
          });

        }else{
          if(Get.currentRoute != '/RideRequestScreen'){
            _toRoute(formSplash, const OrderScreen(index: 1));
          }else{
            Get.find<RideController>().getPendingRideRequestList(1, limit: 100);
          }

        }
      });


    }
    else if (data.action == "driver_bid_accepted") {
      ///Bid Ride Accepted in this case....
      Get.find<RideController>().getRideDetails(data.rideRequestId!).then((value) {
        if (value != null) {
          Get.find<RiderMapController>().setRideCurrentState(RideState.accepted);
          Get.find<RideController>().updateRoute(false, notify: true);
          _toRoute(formSplash, const MapScreen());
        }
      });
    }
    else if (data.action == "customer_payment_successful" && data.action == "ride_request") {

      Get.find<RideController>().getRideDetails( data.rideRequestId!).then((value){
        Get.offAll(() => RideDetailsScreen(rideId: data.rideRequestId!));
      });
    }
    else if (data.action == "driver_customer_canceled_trip" || data.action== "customer_another_driver_assigned") {
      Get.find<RideController>().getPendingRideRequestList(1).then((value) {
        Get.find<RideController>().tripDetail = null;
        if (value?.statusCode == 200) {
          Get.find<RiderMapController>().setRideCurrentState(RideState.initial);
          Get.offAllNamed(RouteHelper.getInitialRoute());
        }
      });

    }
    else if (checkContainsAction(data.action!)) {
      Get.find<ProfileController>().getProfile().then((value) {
        if (value != null) {
          Get.find<RiderMapController>().setRideCurrentState(RideState.initial);
          // Get.find<ProfileController>().setProfileTypeIndex(2,isUpdate: true);
          // _toRoute(formSplash, const ProfileScreen());

        }
      });

      if(formSplash){
        Get.offAllNamed(RouteHelper.getInitialRoute());
      }


    }
    else if(data.action == "other_withdraw_request_rejected" || data.action == "other_withdraw_request_approved" ||
        data.action== "other_admin_collected_cash" || data.action == "other_withdraw_request_reversed") {
      // Get.offAllNamed(RouteHelper.getInitialRoute());
      // Get.find<BottomMenuController>().setTabIndex(3);
      _toRoute(formSplash, const MyAccountScreen());

    }
    else if(data.action == "other_withdraw_request_settled") {
      _toRoute(formSplash, const MyAccountScreen());
      // Get.offAll(() => const DashboardScreen());
      // Get.find<BottomMenuController>().setTabIndex(3);
      // Get.find<TransactionController>().setSelectedHistoryIndex(1, true);

    }
    else if(data.action == "customer_rejected_bid"){
      // Get.offAll(() => const DashboardScreen());
      Get.offAllNamed(RouteHelper.getInitialRoute());
    }
    else if(data.action == "other_review_from_customer"){
      _toRoute(formSplash, const ReviewScreen());

    }
    else if(data.action == 'identity_image_approved' || data.action == 'identity_image_rejected'){

      if(formSplash){
        Get.offAllNamed(RouteHelper.getInitialRoute());
      }
      // Get.find<ProfileController>().getProfile().then((value) {
      //   _toRoute(formSplash, ProfileEditScreen(profileInfo: Get.find<ProfileController>().profileInfo!));
      // });

    }
    else if(data.action == 'other_level_up'){

      Get.find<ProfileController>().getProfileLevelInfo();

      _toRoute(formSplash, const DashboardScreen(pageIndex: 3,));

      Future.delayed(Duration(seconds: 3), (){
        showDialog(
          context: Get.context!,
          barrierDismissible: false,
          builder: (_) => LevelCongratulationsDialogWidget(
            levelName: data.nextLevel ?? "",
            rewardType: data.rewardType ?? "",
            reward: data.rewardAmount ?? "",
          ),
        );
      });

    }
    // else if(data['action'] == 'privacy_policy_page_updated'){
    //   Get.find<SplashController>().getConfigData().then((value){
    //     _toRoute(formSplash, PolicyViewerScreen(
    //       htmlType: HtmlType.privacyPolicy,
    //       image: Get.find<SplashController>().config?.privacyPolicy?.image??'',
    //     ));
    //   });
    //
    // }
    // else if(data['action'] == 'legal_updated'){
    //   Get.find<SplashController>().getConfigData().then((value){
    //     _toRoute(formSplash, PolicyViewerScreen(
    //         htmlType: HtmlType.legal,
    //         image: Get.find<SplashController>().config?.legal?.image??''
    //     ));
    //   });
    //
    // }
    // else if(data['action'] == 'terms_and_conditions_updated'){
    //   Get.find<SplashController>().getConfigData().then((value){
    //     _toRoute(formSplash, PolicyViewerScreen(htmlType: HtmlType.termsAndConditions,
    //         image: Get.find<SplashController>().config?.termsAndConditions?.image??''
    //     ));
    //   });
    //
    // }
    // else if(data['action'] == 'referral_reward_received'){
    //   _toRoute(formSplash, const ReferAndEarnScreen());
    // }
    // else if(data['action'] == 'parcel_amount_deducted'){
    //   _toRoute(formSplash, TripDetails(tripId: data['ride_request_id']));
    // }
    // else if(data['action'] == 'refund_accepted'){
    //   _toRoute(formSplash, TripDetails(tripId: data['ride_request_id']));
    // }
    // else if(data['action'] == 'refund_denied'){
    //   _toRoute(formSplash, TripDetails(tripId: data['ride_request_id']));
    // }
    // else if(data['action'] == 'parcel_amount_debited'){
    //   Get.offAll(() => const DashboardScreen());
    //   Get.find<BottomMenuController>().setTabIndex(3);
    // }
    else if(data.action == 'driver_tips_from_customer' || data.action == 'customer_payment_successful'){
      _toRoute(formSplash, RideDetailsScreen(rideId: data.rideRequestId!));
    }
    else if(data.action == 'other_safety_problem_resolved' && data.action == 'other_safety_alert_sent'){
      Get.find<RideController>().getRideDetails(data.rideRequestId!).then((value) {
        if (value != null) {
          if(Get.find<RideController>().tripDetail?.currentStatus == 'ongoing'){
            if(Get.currentRoute != '/MapScreen') {
              Get.find<RiderMapController>().setRideCurrentState(RideState.ongoing);
              _toRoute(formSplash, const MapScreen());
            }
          }else{
            if(Get.currentRoute != '/RideDetailsScreen') {
              _toRoute(formSplash, RideDetailsScreen(rideId: data.rideRequestId!));
            }
          }
        }
      });

    }
    else {
      Get.offAll(() => const DashboardScreen(pageIndex: 0,));
    }

  }

  static Future _toRoute(bool formSplash, Widget page) async {
    if(formSplash) {
      await Get.offAll(() => page);

    }else {
      await Get.to(() => page);
    }
  }

  static void _whenRideComplete(RemoteMessage message){
    Get.find<SafetyAlertController>().cancelDriverNeedSafetyStream();
    Get.find<RideController>().getRideDetails(message.data['ride_request_id']).then((value) {
      if (value != null) {
        Get.find<RideController>().getFinalFare(message.data['ride_request_id']).then((value) {
          if (value.statusCode == 200) {
            Get.find<RiderMapController>().setRideCurrentState(RideState.initial);
            Get.to(() => RideDetailsScreen(rideId: message.data['ride_request_id']));
          }
        });
      }
    });
  }

  static void _whenNewRequestFound(RemoteMessage message){
    Get.find<RideController>().ongoingTripList().then((value){
      if((Get.find<RideController>().ongoingRide ?? []).isEmpty){
        Get.find<RideController>().getPendingRideRequestList(1);
        AudioPlayer audio = AudioPlayer();
        audio.play(AssetSource('notification.mp3'));
        Get.find<RideController>().setRideId(message.data['ride_request_id']);
        Get.find<RideController>().getRideDetailBeforeAccept(message.data['ride_request_id']).then((value) {
          if (value.statusCode == 200) {
            Get.find<RiderMapController>().getPickupToDestinationPolyline();
            Get.find<RiderMapController>().setRideCurrentState(RideState.pending);
            Get.find<RiderMapController>().setMarkersInitialPosition(bindLocation: true);
            Get.find<RideController>().updateRoute(false, notify: true);
            Get.to(() => const MapScreen());
          }
        });

      }else{
        if(Get.currentRoute == '/MapScreen'){
          Get.find<RideController>().getPendingRideRequestList(1,limit: 100);
        }else{
          Get.to(()=> OrderRequestScreen(onTap: (){}));
        }

      }
    });
  }

  static void _whenDriverLevelUp(RemoteMessage message){
    Get.find<ProfileController>().getProfileLevelInfo();
    Future.delayed(Duration(seconds: 3),(){
      showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (_) => LevelCongratulationsDialogWidget(
          levelName: message.data['next_level'],
          rewardType: message.data['reward_type'],
          reward: message.data['reward_amount'],
        ),
      );
    });
  }

  static bool checkContainsAction(String action){
    List<String> actions = ['driver_registration_vehicle_request_approved','driver_registration_vehicle_request_denied','vehicle_update_approved','driver_registration_vehicle_request_denied'];
    if(actions.contains(action)){
      return true;
    }else{
      return false;
    }
  }

  static void _whenCustomerCancelTrip(RemoteMessage message, {bool isAnotherDriverAssigned = false}){


    if(Get.find<RideController>().tripDetail?.id == message.data['ride_request_id']){
      Get.find<SafetyAlertController>().cancelDriverNeedSafetyStream();
      Get.find<RideController>().tripDetail = null;
      if(isAnotherDriverAssigned) {
        Get.offAll(RideDetailsScreen(rideId: message.data['ride_request_id']));
        Get.find<RideController>().getPendingRideRequestList(1).then((value) {
          if (value?.statusCode == 200) {
            Get.find<RiderMapController>().setRideCurrentState(RideState.initial);
          }
        });
      } else {
        Get.find<RideController>().getPendingRideRequestList(1).then((value) {
          if (value?.statusCode == 200) {
            Get.find<RiderMapController>().setRideCurrentState(RideState.initial);
            Get.find<RideController>().getLastRideDetail();
            //Get.offAllNamed(RouteHelper.getInitialRoute());
          }
        });
      }

    }else{
      Get.find<RideController>().ongoingTripList();
      Get.find<RideController>().getPendingRideRequestList(1,limit: 100);
    }
  }

  static void _whenRidePaymentSuccess(RemoteMessage message){
    Get.find<RideController>().ongoingTripList().then((value){
      if((Get.find<RideController>().ongoingRide ?? []).isEmpty){
        RideHelper.navigateToNextScreen(id: message.data['ride_request_id']);
      }else{
        Get.offAll(()=> const OngoingRideScreen());
      }
    });
  }

  static void _whenCustomerBidAccept(RemoteMessage message){
    Get.find<RideController>().ongoingTripList().then((value){
      if((Get.find<RideController>().ongoingRide ?? []).length <= 1){
        Get.find<RideController>().getRideDetails(message.data['ride_request_id']).then((value) {
          if (value != null) {
            Get.find<RiderMapController>().setRideCurrentState(RideState.accepted);
            Get.find<RideController>().updateRoute(false, notify: true);
            Get.to(() => const MapScreen());
          }
        });

      }else{
        if(Get.currentRoute == '/RideRequestScreen'){
          Get.back();
        }
      }
    });
  }

  static Future<void> showNotification(RemoteMessage message, FlutterLocalNotificationsPlugin fln) async {
    if(!GetPlatform.isIOS) {
      String? title;
      String? body;
      String? image;
      NotificationBodyModel? notificationBody = convertNotification(message.data);

      title = message.data['title'];
      body = message.data['body'];
      image = (message.data['image'] != null && message.data['image'].isNotEmpty) ? message.data['image'].startsWith('http') ? message.data['image']
        : '${AppConstants.baseUrl}/storage/app/public/notification/${message.data['image']}' : null;

      if(image != null && image.isNotEmpty) {
        try{
          await showBigPictureNotificationHiddenLargeIcon(title, body, notificationBody, image, fln);
        }catch(e) {
          await showBigTextNotification(title, body!, notificationBody, fln);
        }
      }else {
        await showBigTextNotification(title, body!, notificationBody, fln);
      }
    }
  }

  static Future<void> showTextNotification(String title, String body, NotificationBodyModel notificationBody, FlutterLocalNotificationsPlugin fln) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '6ammart', AppConstants.appName, playSound: true,
      importance: Importance.max, priority: Priority.max, sound: RawResourceAndroidNotificationSound('notification'),
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics, payload: jsonEncode(notificationBody.toJson()));
  }

  static Future<void> showBigTextNotification(String? title, String body, NotificationBodyModel? notificationBody, FlutterLocalNotificationsPlugin fln) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body, htmlFormatBigText: true,
      contentTitle: title, htmlFormatContentTitle: true,
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '6ammart', AppConstants.appName, importance: Importance.max,
      styleInformation: bigTextStyleInformation, priority: Priority.max, playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics, payload: notificationBody != null ? jsonEncode(notificationBody.toJson()) : null);
  }

  static Future<void> showBigPictureNotificationHiddenLargeIcon(String? title, String? body, NotificationBodyModel? notificationBody, String image, FlutterLocalNotificationsPlugin fln) async {
    final String largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    final String bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
    final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath), hideExpandedLargeIcon: true,
      contentTitle: title, htmlFormatContentTitle: true,
      summaryText: body, htmlFormatSummaryText: true,
    );
    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '6ammart', AppConstants.appName,
      largeIcon: FilePathAndroidBitmap(largeIconPath), priority: Priority.max, playSound: true,
      styleInformation: bigPictureStyleInformation, importance: Importance.max,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics, payload: notificationBody != null ? jsonEncode(notificationBody.toJson()) : null);
  }

  static Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  static NotificationBodyModel? convertNotification(Map<String, dynamic> data){
    final type = data['type'];
    final orderId = data['order_id'];

    switch (type) {
      case 'cash_collect':
        return NotificationBodyModel(notificationType: NotificationType.general);
      case 'unassign':
        return NotificationBodyModel(notificationType: NotificationType.unassign);
      case 'order_status':
        return NotificationBodyModel(orderId: int.parse(orderId), notificationType: NotificationType.order);
      case 'order_request':
        return NotificationBodyModel(orderId: int.parse(orderId), notificationType: NotificationType.order_request);
      case 'block':
        return NotificationBodyModel(notificationType: NotificationType.block);
      case 'unblock':
        return NotificationBodyModel(notificationType: NotificationType.unblock);
      case 'otp':
        return NotificationBodyModel(notificationType: NotificationType.otp);
      case 'message':
        return _handleMessageNotification(data);
      case 'withdraw':
        return NotificationBodyModel(notificationType: NotificationType.withdraw);
      case 'deliveryman_referral':
        return NotificationBodyModel(notificationType: NotificationType.general);
      default:
        return NotificationBodyModel(notificationType: NotificationType.general);
    }
  }

  static NotificationBodyModel _handleMessageNotification(Map<String, dynamic> data) {
    final conversationId = data['conversation_id'];
    final senderType = data['sender_type'];

    return NotificationBodyModel(
      conversationId: (conversationId != null && conversationId.isNotEmpty) ? int.parse(conversationId) : null,
      notificationType: NotificationType.message,
      type: senderType == AppConstants.user ? AppConstants.user : AppConstants.vendor,
    );
  }

}


final AudioPlayer _audioPlayer = AudioPlayer();

/// Background FCM message handler
@pragma('vm:entry-point')
Future<void> myBackgroundMessageHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  customPrint("onBackground: ${message.data}");

  final notificationBody = NotificationHelper.convertNotification(message.data);

  if (notificationBody != null && (notificationBody.notificationType == NotificationType.order || notificationBody.notificationType == NotificationType.order_request)) {

    FlutterForegroundTask.initCommunicationPort();
    await _initService();
    await _startService(notificationBody.orderId?.toString(), notificationBody.notificationType!);
  }
}

/// Initialize Foreground Service
@pragma('vm:entry-point')
Future<void> _initService() async {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: '6ammart',
      channelName: 'Foreground Service Notification',
      channelDescription: 'This notification appears when the foreground service is running.',
      onlyAlertOnce: false,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: false,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(5000),
      autoRunOnBoot: false,
      autoRunOnMyPackageReplaced: false,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );
}

/// Start Foreground Service
@pragma('vm:entry-point')
Future<ServiceRequestResult> _startService(String? orderId, NotificationType notificationType) async {
  if (await FlutterForegroundTask.isRunningService) {
    return FlutterForegroundTask.restartService();
  } else {
    return FlutterForegroundTask.startService(
      serviceId: 256,
      notificationTitle: notificationType == NotificationType.order_request ? 'Order Notification' : 'You have been assigned a new order ($orderId)',
      notificationText: notificationType == NotificationType.order_request ? 'New order request arrived, you can confirm this.' : 'Open app and check order details.',
      callback: startCallback,
    );
  }
}

/// Stop Foreground Service
@pragma('vm:entry-point')
Future<ServiceRequestResult> stopService() async {
  try {
    await _audioPlayer.stop();
    await _audioPlayer.dispose();
  } catch (e) {
    customPrint('Audio dispose error: $e');
  }
  return FlutterForegroundTask.stopService();
}

/// Foreground Service entry point
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

/// Foreground Service Task Handler
class MyTaskHandler extends TaskHandler {
  AudioPlayer? _localPlayer;

  void _playAudio() {
    _localPlayer?.play(AssetSource('notification.mp3'));
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _localPlayer = AudioPlayer();
    _playAudio();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    _playAudio();
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await _localPlayer?.dispose();
    await stopService();
  }

  @override
  void onReceiveData(Object data) {
    _playAudio();
  }

  @override
  void onNotificationButtonPressed(String id) {
    customPrint('onNotificationButtonPressed: $id');
    if (id == '1') {
      FlutterForegroundTask.launchApp('/');
    }
    stopService();
  }

  @override
  void onNotificationPressed() {
    customPrint('onNotificationPressed');
    FlutterForegroundTask.launchApp('/');
    stopService();
  }

  @override
  void onNotificationDismissed() {
    FlutterForegroundTask.updateService(
      notificationTitle: 'You got a new order!',
      notificationText: 'Open app and check order details.',
    );
  }
}
