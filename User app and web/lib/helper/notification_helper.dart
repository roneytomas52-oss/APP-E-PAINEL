import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/common/widgets/demo_reset_dialog_widget.dart';
import 'package:sixam_mart/common/widgets/taxi_make_payment_bottomsheet.dart';
import 'package:sixam_mart/features/chat/controllers/chat_controller.dart';
import 'package:sixam_mart/features/chat/enums/user_type_enum.dart';
import 'package:sixam_mart/features/notification/controllers/notification_controller.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_order/controllers/taxi_order_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_order/screens/taxi_order_details_screen.dart';
import 'package:sixam_mart/features/ride_share_module/common/controllers/map_controller.dart';
import 'package:sixam_mart/features/ride_share_module/common/widgets/confirmation_trip_dialog.dart';
import 'package:sixam_mart/features/ride_share_module/ride_home/widgets/driver_request_dialog.dart';
import 'package:sixam_mart/features/ride_share_module/ride_order/controllers/ride_controller.dart';
import 'package:sixam_mart/features/ride_share_module/ride_order/screens/ride_order_complete_screen.dart';
import 'package:sixam_mart/features/ride_share_module/ride_payment/screens/ride_payment_screen.dart';
import 'package:sixam_mart/features/ride_share_module/safety_alert/controllers/safety_alert_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:sixam_mart/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixam_mart/features/notification/widgets/notifiation_popup_dialog_widget.dart';

import '../features/ride_share_module/ride_location/screens/map_screen.dart';

class NotificationHelper {

  static Future<void> initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize = const AndroidInitializationSettings('notification_icon');
    var iOSInitialize = const DarwinInitializationSettings();
    var initializationsSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation < AndroidFlutterLocalNotificationsPlugin>()!.requestNotificationsPermission();
    flutterLocalNotificationsPlugin.initialize(initializationsSettings, onDidReceiveNotificationResponse: (NotificationResponse load) async {
      try{
        if(load.payload!.isNotEmpty) {

          NotificationBodyModel payload = NotificationBodyModel.fromJson(jsonDecode(load.payload!));

          if (payload.notificationType == NotificationType.ride_request) {
            await rideNotificationRouteCheck(payload.toJson());
            return;
          }

          final Map<NotificationType, Function> notificationActions = {
            NotificationType.order: () {
              if(AuthHelper.isGuestLoggedIn()) {
                Get.to(()=> const DashboardScreen(pageIndex: 3, fromSplash: false));
              } else {
                Get.toNamed(RouteHelper.getOrderDetailsRoute(int.parse(payload.orderId.toString()), fromNotification: true));
              }
            },
            NotificationType.block: () => Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.notification)),
            NotificationType.unblock: () => Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.notification)),
            NotificationType.message: () => Get.toNamed(RouteHelper.getChatRoute(notificationBody: payload, conversationID: payload.conversationId, fromNotification: true)),
            NotificationType.otp: () => null,
            NotificationType.add_fund: () => Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true)),
            NotificationType.referral_earn: () => Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true)),
            NotificationType.cashback: () => Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true)),
            NotificationType.loyalty_point: () => Get.toNamed(RouteHelper.getLoyaltyRoute(fromNotification: true)),
            NotificationType.general: () => Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true)),
            NotificationType.trip: () => Get.to(()=> TaxiOrderDetailsScreen(tripId: int.parse(payload.orderId.toString()))),
          };

          notificationActions[payload.notificationType]?.call();
        }
      }catch (_) {}
      return;
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (kDebugMode) {
        print("onMessage: ${message.data['type']}/${message.data}");
      }


      bool pusherDisConnected = Get.find<SplashController>().pusherConnectionStatus == null || Get.find<SplashController>().pusherConnectionStatus == 'Disconnected' || Get.find<SplashController>().configModel!.webSocketStatus == false;

      if (kDebugMode) {
        print('pusher Disconnected: $pusherDisConnected [${Get.find<SplashController>().pusherConnectionStatus == null} || ${Get.find<SplashController>().pusherConnectionStatus} || ${Get.find<SplashController>().configModel!.webSocketStatus == false}]');
      }
      /// For Ride Share
      if (message.data['action'] == 'customer_driver_on_the_way' && pusherDisConnected) {
        print('=======from notification=====1===');
        Get.back();
        Get.find<RideController>().getRideDetails(
            message.data['ride_request_id']).then((value) {
          if (value.statusCode == 200) {
            Get.find<RideController>().updateRideCurrentState(RideState.acceptingRider);
            Get.find<RideController>().startLocationRecord();
            Get.find<MapController>().notifyMapController();
            // if(Get.currentRoute == '/MapScreen') {
            //   Get.back();
            // }
            Get.to(() => const MapScreen(fromScreen: MapScreenType.splash));
          }
        });
      }
      else if (message.data['action'] == 'customer_trip_started' && message.data['type'] == 'ride_request' && pusherDisConnected) {
        Get.find<SafetyAlertController>().checkDriverNeedSafety();
        Get.find<RideController>().updateRideCurrentState(RideState.ongoingRide);
        Get.find<RideController>().getCurrentRideStatus(navigateToMap: true);

      }
      else if ((message.data['action'] == 'customer_trip_resumed' || message.data['action'] == 'customer_trip_paused') && message.data['type'] == 'ride_request') {
        Get.find<RideController>().getRideDetails(message.data['ride_request_id']);
      }
      else if (message.data['action'] == 'payment_successful') {
        if (message.data['type'] == 'ride_request') {
          Get.off(() => RideOrderCompleteScreen(tripId: message.data['ride_request_id']));
          Get.find<RideController>().tripDetails = null;
        }
      }
      else if (message.data['action'] == 'customer_trip_completed' && message.data['type'] == 'ride_request' && pusherDisConnected) {
        Get.find<SafetyAlertController>().cancelDriverNeedSafetyStream();
        Get.dialog(
          const ConfirmationTripDialog(isStartedTrip: false),
          barrierDismissible: false,
        );
        Get.find<RideController>().getFinalFare(message.data['ride_request_id']).then((value) {
          if (value.statusCode == 200) {
            Get.find<RideController>().updateRideCurrentState(RideState.completeRide);
            Get.find<MapController>().notifyMapController();
            Get.back();
            Get.off(() => RidePaymentScreen(rideId: message.data['ride_request_id']));
          }
        });
      }
      else if (message.data['action'] == 'customer_trip_canceled' && message.data['type'] == 'ride_request' && pusherDisConnected) {
        Get.find<SafetyAlertController>().cancelDriverNeedSafetyStream();
        Get.find<RideController>().getCurrentRide();
        await Get.find<RideController>().getCurrentRideStatus(fromRefresh: true);
        if(Get.currentRoute == '/MapScreen') {
          Get.off(() => RideOrderCompleteScreen(tripId: message.data['ride_request_id']));
        } else {
          Get.to(() => RideOrderCompleteScreen(tripId: message.data['ride_request_id']));
        }
      }
      else if (message.data['action'] == 'driver_trip_request_canceled' && message.data['type'] == 'ride_request' && pusherDisConnected) {
        Get.find<RideController>().getCurrentRide();
        Get.find<RideController>().stopLocationRecord();
        Get.find<SafetyAlertController>().cancelDriverNeedSafetyStream();
        Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: false));
      }
      else if (message.data['action'] == 'driver_customer_canceled_trip' && message.data['type'] == 'ride_request' && pusherDisConnected) {
        Get.find<SafetyAlertController>().cancelDriverNeedSafetyStream();
        Get.find<RideController>().getCurrentRide();
        await Get.find<RideController>().getCurrentRideStatus(fromRefresh: true);
        Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: false));
      }
      else if (message.data['action'] == 'driver_received_new_bid') {
        Get.find<RideController>().getBiddingList(
            message.data['ride_request_id'], 1).then((value) {
          if (value.statusCode == 200) {
            Get.find<RideController>().biddingList.length != 1 ? Get.back() : null;

            Get.dialog(
                barrierDismissible: true,
                barrierColor: Colors.black.withValues(alpha: 0.5),
                transitionDuration: const Duration(milliseconds: 500),
                DriverRideRequestDialog(tripId: message.data['ride_request_id'])
            );
          }
        });
      }
      else if (message.data['action'] == 'driver_canceled_ride_request') {
        Get.find<RideController>().getBiddingList(
            message.data['ride_request_id'], 1).then((value) {
          if (value.statusCode == 200) {
            if (Get.find<RideController>().biddingList.isEmpty && Get.isDialogOpen!) {
              Get.back();
            }
          }
        });
      }
      else if (message.data['action'] == 'referral_reward_received') {
        ///
      } else if (message.data['action'] == 'safety_problem_resolved') {
        Get.find<SafetyAlertController>().getSafetyAlertDetails(message.data['ride_request_id']);
      } else if( message.data['action'] == 'customer_payment_successful' && Get.currentRoute.contains('/RidePaymentScreen')) {
        Get.offAll(() => RideOrderCompleteScreen(tripId: message.data['ride_request_id'], fromNotification: true));
      }


      ///Existing Notifications

      if(message.data['type'] == 'demo_reset') {
        Get.dialog(const DemoResetDialogWidget(), barrierDismissible: false);
      }
      if(message.data['type'] == 'message' && Get.currentRoute.startsWith(RouteHelper.messages)) {
        if(AuthHelper.isLoggedIn()) {
          Get.find<ChatController>().getConversationList(1);
          if(Get.find<ChatController>().messageModel!.conversation!.id.toString() == message.data['conversation_id'].toString()) {
            Get.find<ChatController>().getMessages(
              1, NotificationBodyModel(
              notificationType: NotificationType.message, adminId: message.data['sender_type'] == UserType.admin.name ? 0 : null,
              restaurantId: message.data['sender_type'] == UserType.vendor.name ? 0 : null,
              deliverymanId: message.data['sender_type'] == UserType.delivery_man.name ? 0 : null,
            ),
              null, int.parse(message.data['conversation_id'].toString()),
            );
          }else {
            NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin);
          }
        }
      } else if(message.data['type'] == 'message' && Get.currentRoute.startsWith(RouteHelper.conversation)) {
        if(AuthHelper.isLoggedIn()) {
          Get.find<ChatController>().getConversationList(1);
        }
        NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin);
      } else if(message.data['type'] == 'demo_reset'){
      } else if(message.data['type'] == 'trip_status' && message.data['status'] == 'completed' && message.data['order_id'] != '' && message.data['order_id'] != null) {
        if(!Get.currentRoute.contains('/TaxiOrderDetailsScreen')) {
          Get.bottomSheet(TaxiMakePaymentBottomSheet(orderId: message.data['order_id']));
        }
        Get.find<TaxiOrderController>().getTripList(1, isRunning: true);
        Get.find<TaxiOrderController>().getTripList(1, isRunning: false);
        if(Get.currentRoute.contains('/TaxiOrderDetailsScreen')) {
          Get.find<TaxiOrderController>().getTripDetails(int.parse(message.data['order_id']), willUpdate: false);
        }
      }
      else {
        NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin);
        if(AuthHelper.isLoggedIn()) {
          if(message.data['type'] == 'message' && Get.currentRoute.startsWith('/MapScreen')) {
            Get.find<RideController>().setRideGetMessage(true);
          }
          if(message.data['type'] != 'trip_status') {
            Get.find<OrderController>().getRunningOrders(1);
            Get.find<OrderController>().getHistoryOrders(1);
          }

          Get.find<NotificationController>().getNotificationList(true);
          if(message.data['type'] == 'trip_status' && message.data['order_id'] != '' && message.data['order_id'] != null) {
            if(Get.isBottomSheetOpen!) {
              Get.back();
            }
            if(Get.currentRoute.contains('/TaxiOrderDetailsScreen')) {
             await Get.find<TaxiOrderController>().getTripDetails(int.parse(message.data['order_id']), willUpdate: false);
            }
            Get.find<TaxiOrderController>().getTripList(1, isRunning: true);
            Get.find<TaxiOrderController>().getTripList(1, isRunning: false);
          }

        } else if(message.data['type'] == 'trip_status' && message.data['order_id'] != '' && message.data['order_id'] != null) {
          if(Get.isBottomSheetOpen!) {
            Get.back();
          }
          if(Get.currentRoute.contains('/TaxiOrderDetailsScreen')) {
            await Get.find<TaxiOrderController>().getTripDetails(int.parse(message.data['order_id']), willUpdate: false);
          }
        }
      }

      Map<String, String> payloadData = {
        'title' : '${message.data['title']}',
        'body' : '${message.data['body']}',
        'order_id' : '${message.data['order_id']}',
        'image' : '${message.data['image']}',
        'type' : '${message.data['type']}',
      };

      PayloadModel payload = PayloadModel.fromJson(payloadData);

      if(kIsWeb) {
        showDialog(context: Get.context!, builder: (context) => Center(
          child: NotificationPopUpDialogWidget(payload),
        ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (kDebugMode) {
        print("onOpenApp: ${message.data}");
      }
      try{
        if(message.data.isNotEmpty) {
          NotificationBodyModel notificationBody = convertNotification(message.data);

          if (notificationBody.notificationType == NotificationType.ride_request) {
            await rideNotificationRouteCheck(message.data);
            return;
          }

          final Map<NotificationType, Function> notificationActions = {
            NotificationType.order: () => Get.toNamed(RouteHelper.getOrderDetailsRoute(int.parse(message.data['order_id']), fromNotification: true)),
            NotificationType.block: () => Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.notification)),
            NotificationType.unblock: () => Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.notification)),
            NotificationType.message: () => Get.toNamed(RouteHelper.getChatRoute(notificationBody: notificationBody, conversationID: notificationBody.conversationId, fromNotification: true)),
            NotificationType.otp: () => null,
            NotificationType.add_fund: () => Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true)),
            NotificationType.referral_earn: () => Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true)),
            NotificationType.cashback: () => Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true)),
            NotificationType.loyalty_point: () => Get.toNamed(RouteHelper.getLoyaltyRoute(fromNotification: true)),
            NotificationType.general: () => Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true)),
            NotificationType.trip: () => Get.to(()=> TaxiOrderDetailsScreen(tripId: int.parse(message.data['order_id']))),
          };

          notificationActions[notificationBody.notificationType]?.call();
        }
      }catch (_) {}
    });
  }

  static Future<void> showNotification(RemoteMessage message, FlutterLocalNotificationsPlugin fln) async {
    if(!GetPlatform.isIOS) {
      String? title;
      String? body;
      String? orderID;
      String? image;
      NotificationBodyModel notificationBody = convertNotification(message.data);

      title = message.data['title'];
      body = message.data['body'];
      orderID = message.data['order_id'];
      image = (message.data['image'] != null && message.data['image'].isNotEmpty) ? message.data['image'].startsWith('http') ? message.data['image']
        : '${AppConstants.baseUrl}/storage/app/public/notification/${message.data['image']}' : null;

      if(image != null && image.isNotEmpty) {
        try{
          await showBigPictureNotificationHiddenLargeIcon(title, body, orderID, notificationBody, image, fln);
        }catch(e) {
          await showBigTextNotification(title, body!, orderID, notificationBody, fln);
        }
      }else {
        await showBigTextNotification(title, body!, orderID, notificationBody, fln);
      }
    }
  }

  static Future<void> showTextNotification(String title, String body, String orderID, NotificationBodyModel? notificationBody, FlutterLocalNotificationsPlugin fln) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '6ammart', AppConstants.appName, playSound: true,
      importance: Importance.max, priority: Priority.max, sound: RawResourceAndroidNotificationSound('notification'),
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics, payload: notificationBody != null ? jsonEncode(notificationBody.toJson()) : null);
  }

  static Future<void> showBigTextNotification(String? title, String body, String? orderID, NotificationBodyModel? notificationBody, FlutterLocalNotificationsPlugin fln) async {
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

  static Future<void> showBigPictureNotificationHiddenLargeIcon(String? title, String? body, String? orderID, NotificationBodyModel? notificationBody, String image, FlutterLocalNotificationsPlugin fln) async {
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

  static NotificationBodyModel convertNotification(Map<String, dynamic> data) {
    final type = data['type'];

    final rideRequestId = data['ride_request_id'];
    final action = data['action'];
    final nextLevel = data['next_level'];
    final rewardAmount = data['reward_amount'];
    final rewardType = data['reward_Type'];

    switch (type) {
      case 'referral_code':
        return NotificationBodyModel(notificationType: NotificationType.general);
      case 'referral_earn':
        return NotificationBodyModel(notificationType: NotificationType.referral_earn);
      case 'cashback':
        return NotificationBodyModel(notificationType: NotificationType.cashback);
      case 'loyalty_point':
        return NotificationBodyModel(notificationType: NotificationType.loyalty_point);
      case 'otp':
        return NotificationBodyModel(notificationType: NotificationType.otp);
      case 'add_fund':
        return NotificationBodyModel(notificationType: NotificationType.add_fund);
      case 'block':
        return NotificationBodyModel(notificationType: NotificationType.block);
      case 'unblock':
        return NotificationBodyModel(notificationType: NotificationType.unblock);
      case 'order_status':
        return _handleOrderNotification(data);
      case 'trip_status':
        return _handleTripNotification(data);
      case 'message':
        return _handleMessageNotification(data);
      case 'ride_request':
        return NotificationBodyModel(
          type: type,
          notificationType: NotificationType.ride_request,
          rideRequestId: rideRequestId,
          action: action,
          nextLevel: nextLevel,
          rewardAmount: rewardAmount,
          rewardType: rewardType,
        );
      default:
        return NotificationBodyModel(notificationType: NotificationType.general);
    }
  }

  static NotificationBodyModel _handleOrderNotification(Map<String, dynamic> data) {
    final orderId = data['order_id'];
    return NotificationBodyModel(
      orderId: int.tryParse(orderId) ?? 0,
      notificationType: NotificationType.order,
    );
  }

  static NotificationBodyModel _handleTripNotification(Map<String, dynamic> data) {
    final orderId = data['order_id'];
    return NotificationBodyModel(
      orderId: int.tryParse(orderId) ?? 0,
      notificationType: NotificationType.trip,
    );
  }

  static NotificationBodyModel _handleMessageNotification(Map<String, dynamic> data) {
    final conversationId = data['conversation_id'];
    final senderType = data['sender_type'];

    return NotificationBodyModel(
      notificationType: NotificationType.message,
      deliverymanId: senderType == 'delivery_man' ? 0 : null,
      adminId: senderType == 'admin' ? 0 : null,
      restaurantId: senderType == 'vendor1' ? 0 : null,
      conversationId: int.parse(conversationId.toString()),
    );
  }

  static Future<void> rideNotificationRouteCheck(Map<String,dynamic> data, {bool formSplash = false , String? userName}) async {

    // Handle ride_request type notifications based on action
    if(data['type'] == 'ride_request') {
      //getmodule


      if(Get.find<SplashController>().module?.moduleType == null) {
        await Get.find<SplashController>().getModules();

      }

      // Check if current module is not ride-share, then switch to ride-share module
      if(Get.find<SplashController>().module?.moduleType != AppConstants.ride) {
        for(ModuleModel module in Get.find<SplashController>().moduleList!) {

          if(module.moduleType == AppConstants.ride) {
            await Get.find<SplashController>().setModule(module);

            // Execute the action after module is set
            _executeRideRequestAction(data, formSplash);
            break;
          }
        }
        // Execute the action after module is set
      } else {
        // Execute the action directly if already in ride-share module
        _executeRideRequestAction(data, formSplash);
      }

      return; // Exit early for ride_request type
    }


    /*if (data['action'] == "new_message") {
      Get.find<MessageController>().getConversation(data['type'], 1);
      _toRoute(formSplash, MessageScreen(channelId: data['type'], tripId: data['ride_request_id'], userName: userName ?? data['user_name']));

    }else*/ if(data['action'] == 'customer_driver_on_the_way'){
      notificationToRouteNavigate(data['ride_request_id'], formSplash);

    }else if(data['action'] == 'customer_trip_started' && data['type'] == 'ride_request'){
      notificationToRouteNavigate(data['ride_request_id'], formSplash);

    }else if((data['action'] == 'customer_trip_resumed' || data['action'] == 'customer_trip_paused') && data['type'] == 'ride_request'){
      notificationToRouteNavigate(data['ride_request_id'], formSplash);

    }/*else if(data['action'] == 'customer_trip_started' && data['type'] == 'parcel'){
      notificationToRouteNavigate(data['ride_request_id'], formSplash);

    }*/else if(data['action'] == 'payment_successful'){
      notificationToRouteNavigate(data['ride_request_id'], formSplash);

    }else if(data['action'] == 'customer_trip_completed' && data['type'] == 'ride_request'){
      notificationToRouteNavigate(data['ride_request_id'], formSplash);

    }/*else if(data['action'] == 'trip_completed' || data['action'] == 'parcel_completed'){
      notificationToRouteNavigate(data['ride_request_id'], formSplash);

    }*/else if(data['action'] == 'customer_trip_canceled' && data['type'] == 'ride_request'){
      notificationToRouteNavigate(data['ride_request_id'], formSplash);

    }else if(data['action'] == 'driver_received_new_bid'){
      Get.find<RideController>().getRideDetails(data['ride_request_id']).then((value) => {
        if(Get.currentRoute != '/MapScreen'){
          Get.find<RideController>().updateRideCurrentState(RideState.findingRider),

          _toRoute(formSplash, const MapScreen(fromScreen: MapScreenType.ride)),

        },
        Get.find<RideController>().getBiddingList(data['ride_request_id'], 1).then((value) async {
          if (value.statusCode == 200) {
            Get.dialog(
              barrierDismissible: true,
              barrierColor: Colors.black.withValues(alpha:0.5),
              transitionDuration: const Duration(milliseconds: 500),
              DriverRideRequestDialog(tripId: data['ride_request_id']),
            );
          }
        })
      });

    }
    /*else if(data['action'] == 'level_up'){
      Get.find<LevelController>().getProfileLevelInfo();

      if(formSplash) {
        Get.offAllNamed(RouteHelper.getInitialRoute());
      }

      showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (_) => LevelCompleteDialogWidget(
          levelName: data['next_level'],
          rewardType: data['reward_type'],
          reward: data['reward_amount'],
        ),
      );

    }*/
    /*else if(data['action'] == 'privacy_policy_page_updated'){
      Get.find<ConfigController>().getConfigData().then((value){

        _toRoute(formSplash, PolicyScreen(
          htmlType: HtmlType.privacyPolicy,
          image: Get.find<ConfigController>().config?.privacyPolicy?.image??'',
        ));


      });

    }else if(data['action'] == 'legal_updated'){
      Get.find<ConfigController>().getConfigData().then((value){
        _toRoute(formSplash, PolicyScreen(
          htmlType: HtmlType.legal,
          image: Get.find<ConfigController>().config?.legal?.image??'',
        ));
      });

    }else if(data['action'] == 'terms_and_conditions_updated'){
      Get.find<ConfigController>().getConfigData().then((value){

        _toRoute(formSplash, PolicyScreen(
          htmlType: HtmlType.termsAndConditions,
          image: Get.find<ConfigController>().config?.termsAndConditions?.image??'',
        ));

      });

    }*/
    /*else if(data['action'] == 'referral_reward_received'){
      Get.find<ReferAndEarnController>().updateCurrentTabIndex(1);
      _toRoute(formSplash, const ReferAndEarnScreen());

    }else if(data['action'] == 'someone_used_your_code'){
      _toRoute(formSplash, const ReferAndEarnScreen());

    }else if(data['action'] == 'fund_added_by_admin'){
      _toRoute(formSplash, const WalletScreen());

    }else if(data['action'] == 'review_from_driver'){
      _toRoute(formSplash, TripDetailsScreen(tripId: data['ride_request_id']));

    }else if(data['action'] == 'withdraw_request_rejected'){
      _toRoute(formSplash, const WalletScreen());

    }else if(data['action'] == 'withdraw_request_reversed'){
      _toRoute(formSplash, const WalletScreen());

    }*/
    else if(data['action'] == 'safety_problem_resolved' && data['type'] == 'safety_alert'){
      notificationToRouteNavigate(data['ride_request_id'], formSplash);

    }else{
      Get.offAllNamed(RouteHelper.getInitialRoute());
    }

  }

  static void notificationToRouteNavigate(String tripId, bool formSplash){

    Get.find<RideController>().getRideDetails(tripId).then((value) => {
      if(Get.find<RideController>().tripDetails!.currentStatus == 'accepted' || Get.find<RideController>().tripDetails!.currentStatus == 'ongoing'){
        if(Get.currentRoute != '/MapScreen'){

          if(Get.find<RideController>().tripDetails!.currentStatus == 'accepted'){
            Get.find<RideController>().updateRideCurrentState(RideState.acceptingRider),
            Get.find<RideController>().startLocationRecord(),
            Get.find<MapController>().notifyMapController(),

          }else{
            Get.find<RideController>().updateRideCurrentState(RideState.ongoingRide),
            Get.find<MapController>().notifyMapController(),
          },

          _toRoute(formSplash, const MapScreen(fromScreen: MapScreenType.ride))

        }

      }else if(Get.find<RideController>().tripDetails!.currentStatus == 'cancelled'  || (Get.find<RideController>().tripDetails!.currentStatus == 'completed' && Get.find<RideController>().tripDetails!.paymentStatus == 'paid')){
        if(Get.currentRoute != '/RideOrderCompleteScreen'){
          _toRoute(formSplash, RideOrderCompleteScreen(tripId: tripId,fromNotification: true)),

        }

      }else if((Get.find<RideController>().tripDetails!.currentStatus == 'completed' && Get.find<RideController>().tripDetails!.paymentStatus == 'unpaid')){
        if(Get.currentRoute != '/RidePaymentScreen'){
          Get.find<RideController>().getFinalFare(tripId).then((_){
            _toRoute(formSplash, RidePaymentScreen(rideId: tripId));
          })

        }

      }
    });

  }

  static Future _toRoute(bool formSplash, Widget page) async {
    if(formSplash) {
      await Get.offAll(() => page);

    }else {
      await Get.to(() => page);
    }
  }

  static void _executeRideRequestAction(Map<String,dynamic> data, bool formSplash) {
    if(data['action'] == 'customer_driver_on_the_way'){
      Get.back();
      Get.find<RideController>().getRideDetails(data['ride_request_id']).then((value) {
        if (value.statusCode == 200) {
          Get.find<RideController>().updateRideCurrentState(RideState.acceptingRider);
          Get.find<RideController>().startLocationRecord();
          Get.find<MapController>().notifyMapController();
          if(Get.currentRoute != '/MapScreen'){
            _toRoute(formSplash, const MapScreen(fromScreen: MapScreenType.splash));
          }
        }
      });

    } else if(data['action'] == 'customer_trip_started'){
      Get.find<SafetyAlertController>().checkDriverNeedSafety();
      Get.find<RideController>().updateRideCurrentState(RideState.ongoingRide);
      Get.find<RideController>().updateRideController();
      print('------current route: ${Get.currentRoute}');
      if(Get.currentRoute != '/MapScreen'){
        _toRoute(formSplash, const MapScreen(fromScreen: MapScreenType.splash));
      }

    } else if(data['action'] == 'customer_trip_resumed' || data['action'] == 'customer_trip_paused'){
      print('-----step---1');
      notificationToRouteNavigate(data['ride_request_id'], formSplash);

    } else if(data['action'] == 'payment_successful'){
      if(Get.currentRoute != '/RideOrderCompleteScreen'){
        Get.off(() => RideOrderCompleteScreen(tripId: data['ride_request_id']));
        Get.find<RideController>().tripDetails = null;
      }

    } else if(data['action'] == 'customer_trip_completed'){
      Get.find<SafetyAlertController>().cancelDriverNeedSafetyStream();
      Get.dialog(
        const ConfirmationTripDialog(isStartedTrip: false),
        barrierDismissible: false,
      );
      Get.find<RideController>().getFinalFare(data['ride_request_id']).then((value) {
        if (value.statusCode == 200) {
          Get.find<RideController>().updateRideCurrentState(RideState.completeRide);
          Get.find<MapController>().notifyMapController();
          Get.back();
          if(Get.currentRoute != '/RidePaymentScreen'){
            Get.off(() => RidePaymentScreen(rideId: data['ride_request_id']));
          }
        }
      });

    } else if(data['action'] == 'customer_trip_canceled'){
      Get.find<SafetyAlertController>().cancelDriverNeedSafetyStream();
      Get.find<RideController>().getCurrentRideStatus(fromRefresh: true);
      // Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: false));
      if(Get.currentRoute == '/MapScreen') {
        Get.off(() => RideOrderCompleteScreen(tripId: data['ride_request_id']));
      } else {
        Get.to(() => RideOrderCompleteScreen(tripId: data['ride_request_id']));
      }
    } else if(data['action'] == 'driver_received_new_bid'){
      Get.find<RideController>().getBiddingList(data['ride_request_id'], 1).then((value) {
        if (value.statusCode == 200) {
          Get.find<RideController>().biddingList.length != 1 ? Get.back() : null;

          print('======bid gotten=====');
          Get.dialog(
              barrierDismissible: true,
              barrierColor: Colors.black.withValues(alpha:0.5),
              transitionDuration: const Duration(milliseconds: 500),
              DriverRideRequestDialog(tripId: data['ride_request_id'])
          );
        }
      });

    } else if(data['action'] == 'driver_canceled_ride_request'){
      Get.find<RideController>().getBiddingList(data['ride_request_id'], 1).then((value) {
        if (value.statusCode == 200) {
          if(Get.find<RideController>().biddingList.isEmpty && Get.isDialogOpen!){
            Get.back();
          }
        }
      });

    } else if(data['action'] == 'referral_reward_received'){
      // Get.find<ReferAndEarnController>().getEarningHistoryList(1);
      // Get.find<ProfileController>().getProfileInfo();

    } else if(data['action'] == 'safety_problem_resolved'){
      Get.find<SafetyAlertController>().getSafetyAlertDetails(data['ride_request_id']);
    }
  }

}



@pragma('vm:entry-point')
Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("onBackground: ${message.data}");
  }
}


class PayloadModel {
  PayloadModel({
    this.title,
    this.body,
    this.orderId,
    this.image,
    this.type,
  });

  String? title;
  String? body;
  String? orderId;
  String? image;
  String? type;

  factory PayloadModel.fromRawJson(String str) => PayloadModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PayloadModel.fromJson(Map<String, dynamic> json) => PayloadModel(
    title: json["title"],
    body: json["body"],
    orderId: json["order_id"],
    image: json["image"],
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "body": body,
    "order_id": orderId,
    "image": image,
    "type": type,
  };
}
