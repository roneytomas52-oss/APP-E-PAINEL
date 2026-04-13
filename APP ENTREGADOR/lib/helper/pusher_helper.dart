import 'dart:convert';
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/screens/order_request_screen.dart';
import 'package:sixam_mart_delivery/features/ride_module/map/controllers/ride_map_controller.dart';
import 'package:sixam_mart_delivery/features/ride_module/map/screens/map_screen.dart';
import 'package:sixam_mart_delivery/features/ride_module/ride_order/controllers/ride_controller.dart';
import 'package:sixam_mart_delivery/features/ride_module/ride_order/screens/ongoing_ride_list_screen.dart';
import 'package:sixam_mart_delivery/features/ride_module/ride_order/screens/ride_details_screen.dart';
import 'package:sixam_mart_delivery/features/ride_module/safety/controllers/safety_alert_controller.dart';
import 'package:sixam_mart_delivery/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_delivery/helper/ride_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';


class PusherHelper{

  static PusherChannelsClient?  pusherClient;

  static Future<void> initializePusher() async{
    PusherChannelsOptions testOptions = PusherChannelsOptions.fromHost(
      host: Get.find<SplashController>().configModel!.webSocketUri?.replaceAll("wss://", "").replaceAll("ws://", "") ?? '',
      scheme: Get.find<SplashController>().configModel!.websocketScheme == 'https' ? 'wss' : 'ws',
      key: Get.find<SplashController>().configModel!.webSocketKey ?? '',
      port: int.parse(Get.find<SplashController>().configModel?.webSocketPort ?? '6001'),
    );

    if( Get.find<SplashController>().configModel?.webSocketStatus ?? false){

      print("Inside here -----------");
      pusherClient = PusherChannelsClient.websocket(
        options: testOptions,
        connectionErrorHandler: (exception, trace, refresh) async {
          log('=================$exception');
          Get.find<SplashController>().setPusherStatus('Disconnected');
          refresh();
        },
      );
      await pusherClient?.connect();
    }

    String? pusherChannelId =  pusherClient?.channelsManager.channelsConnectionDelegate.socketId;

    print("Pusher Channel Id : ${pusherChannelId}");

      if(pusherChannelId != null){
        if (kDebugMode) {
          print("Pusher connection Status ====> Connected");
        }
        Get.find<SplashController>().setPusherStatus('Connected');
      }


     pusherClient?.lifecycleStream.listen((event) {
       Get.find<SplashController>().setPusherStatus('Disconnected');
     });


  }


  late PrivateChannel driverTripSubscribe;
  void driverTripRequestSubscribe(String id){

    if (Get.find<SplashController>().pusherConnectionStatus != null || Get.find<SplashController>().pusherConnectionStatus == 'Connected'){
      driverTripSubscribe = pusherClient!.privateChannel("private-customer-trip-request.$id", authorizationDelegate:
      EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint: Uri.parse('${AppConstants.baseUrl}${AppConstants.broadcastingAuthUrl}'),
        headers:  {
          "Accept": "application/json",
          "Authorization": "Bearer ${Get.find<AuthController>().getUserToken()}",
          "Access-Control-Allow-Origin": "*",
          'Access-Control-Allow-Methods':"PUT, GET, POST, DELETE, OPTIONS"
        },
      ));


      if(driverTripSubscribe.currentStatus == null){
        driverTripSubscribe.subscribeIfNotUnsubscribed();

        Future.delayed(Duration(seconds: 2), (){
          // if (kDebugMode) {
          //   print("Subscription Status --->> ${driverTripSubscribe.currentStatus}");
          // }
        });

        driverTripSubscribe.bind("customer-trip-request.$id").listen((event) {

          if (kDebugMode) {
            print("Connected =====> Connection get from pusher > customer-trip-request");
          }

          Get.find<RideController>().ongoingTripList().then((value){
            if((Get.find<RideController>().ongoingRide ?? []).isEmpty){
              Get.find<RideController>().getPendingRideRequestList(1);
              AudioPlayer audio = AudioPlayer();
              audio.play(AssetSource('notification.mp3'));
              Get.find<RideController>().setRideId(jsonDecode(event.data!)['trip_id'].toString());
              Get.find<RideController>().getRideDetailBeforeAccept(jsonDecode(event.data!)['trip_id'].toString()).then((value) {
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


          customerInitialTripCancel(jsonDecode(event.data!)['trip_id'].toString(), id);
          anotherDriverAcceptedTrip(jsonDecode(event.data!)['trip_id'].toString(), id);

        });
      }

    }

  }

  late PrivateChannel customerInitialTripCancelChannel;

  void customerInitialTripCancel(String tripId, String userId){
    if (Get.find<SplashController>().pusherConnectionStatus != null || Get.find<SplashController>().pusherConnectionStatus == 'Connected'){
      customerInitialTripCancelChannel = pusherClient!.privateChannel("private-customer-trip-cancelled.$tripId.$userId", authorizationDelegate:
      EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint: Uri.parse('${AppConstants.baseUrl}${AppConstants.broadcastingAuthUrl}'),
        headers:  {
          "Accept": "application/json",
          "Authorization": "Bearer ${Get.find<AuthController>().getUserToken()}",
          "Access-Control-Allow-Origin": "*",
          'Access-Control-Allow-Methods':"PUT, GET, POST, DELETE, OPTIONS"
        },
      ));

      if(customerInitialTripCancelChannel.currentStatus == null){
        customerInitialTripCancelChannel.subscribeIfNotUnsubscribed();
        customerInitialTripCancelChannel.bind("customer-trip-cancelled.$tripId.$userId").listen((event) async {

          if (kDebugMode) {
            print("Connected =====> Connection get from pusher > customer-trip-cancelled");
          }
          if (kDebugMode) {
            print("Connected =====> ${Get.find<RideController>().tripDetail?.id} > ${jsonDecode(event.data!)}");
          }

          if(Get.find<RideController>().tripDetail?.id == jsonDecode(event.data!)['trip_id'].toString()){
            Get.find<SafetyAlertController>().cancelDriverNeedSafetyStream();
            await Get.find<RideController>().getPendingRideRequestList(1);
            Get.find<RiderMapController>().setRideCurrentState(RideState.initial);
            await Get.find<RideController>().getLastRideDetail();
            Get.find<RideController>().tripDetail = null;

          }else{
            Get.find<RideController>().ongoingTripList();
            Get.find<RideController>().getPendingRideRequestList(1,limit: 100);
          }

        });
      }

    }

  }


  late PrivateChannel anotherDriverAcceptedTripChannel;

  void anotherDriverAcceptedTrip(String tripId, String userId){
    if (Get.find<SplashController>().pusherConnectionStatus != null || Get.find<SplashController>().pusherConnectionStatus == 'Connected'){
      anotherDriverAcceptedTripChannel = pusherClient!.privateChannel("private-another-driver-trip-accepted.$tripId.$userId", authorizationDelegate:
      EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint: Uri.parse('${AppConstants.baseUrl}${AppConstants.broadcastingAuthUrl}'),
        headers:  {
          "Accept": "application/json",
          "Authorization": "Bearer ${Get.find<AuthController>().getUserToken()}",
          "Access-Control-Allow-Origin": "*",
          'Access-Control-Allow-Methods':"PUT, GET, POST, DELETE, OPTIONS"
        },
      ));

      if(anotherDriverAcceptedTripChannel.currentStatus == null){
        anotherDriverAcceptedTripChannel.subscribe();
        anotherDriverAcceptedTripChannel.bind("another-driver-trip-accepted.$tripId.$userId").listen((event) {

          if (kDebugMode) {
            print("Connected =====> Connection get from pusher > another-driver-trip-accepted");
          }

          if(Get.find<RideController>().tripDetail?.id == jsonDecode(event.data!)['trip_id'].toString()){
            Get.find<SafetyAlertController>().cancelDriverNeedSafetyStream();
            Get.find<RideController>().getPendingRideRequestList(1).then((value) {
              if (value?.statusCode == 200) {
                Get.find<RiderMapController>().setRideCurrentState(RideState.initial);
                Get.find<RideController>().getPendingRideRequestList(1,limit: 100);
                ///Get.offAllNamed(RouteHelper.getInitialRoute());
              }
            });
          }else{
            Get.find<RideController>().ongoingTripList();
            Get.find<RideController>().getPendingRideRequestList(1,limit: 100);
          }
        });
      }

    }
  }

  late PrivateChannel tripCancelAfterOngoingChannel;

  void tripCancelAfterOngoing(String tripId){
    if (Get.find<SplashController>().pusherConnectionStatus != null || Get.find<SplashController>().pusherConnectionStatus == 'Connected'){
      tripCancelAfterOngoingChannel = pusherClient!.privateChannel("private-customer-trip-cancelled-after-ongoing.$tripId", authorizationDelegate:
      EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint: Uri.parse('${AppConstants.baseUrl}${AppConstants.broadcastingAuthUrl}'),
        headers:  {
          "Accept": "application/json",
          "Authorization": "Bearer ${Get.find<AuthController>().getUserToken()}",
          "Access-Control-Allow-Origin": "*",
          'Access-Control-Allow-Methods':"PUT, GET, POST, DELETE, OPTIONS"
        },
      ));

      if(tripCancelAfterOngoingChannel.currentStatus == null){
        tripCancelAfterOngoingChannel.subscribe();
        tripCancelAfterOngoingChannel.bind("customer-trip-cancelled-after-ongoing.$tripId").listen((event) {

          print("Connected =====> Connection get from pusher > customer-trip-cancelled-after-ongoing");

          Get.find<SafetyAlertController>().cancelDriverNeedSafetyStream();
          Get.offAll(()=> RideDetailsScreen(rideId: jsonDecode(event.data!)['id'].toString()));
          // pusherClient!.unsubscribe('private-customer-trip-cancelled-after-ongoing.$tripId');
        });
      }

    }

  }

  late PrivateChannel tripPaymentSuccessfulChannel;

  void tripPaymentSuccessful(String tripId){
    if (Get.find<SplashController>().pusherConnectionStatus != null || Get.find<SplashController>().pusherConnectionStatus == 'Connected'){
      tripPaymentSuccessfulChannel = pusherClient!.privateChannel("private-customer-trip-payment-successful.$tripId", authorizationDelegate:
      EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint: Uri.parse('${AppConstants.baseUrl}${AppConstants.broadcastingAuthUrl}'),
        headers:  {
          "Accept": "application/json",
          "Authorization": "Bearer ${Get.find<AuthController>().getUserToken()}",
          "Access-Control-Allow-Origin": "*",
          'Access-Control-Allow-Methods':"PUT, GET, POST, DELETE, OPTIONS"
        },
      ));

      if(tripPaymentSuccessfulChannel.currentStatus == null){
        tripPaymentSuccessfulChannel.subscribe();
        tripPaymentSuccessfulChannel.bind("customer-trip-payment-successful.$tripId").listen((event) {

          if (kDebugMode) {
            print("Connected =====> Connection get from pusher > customer-trip-payment-successful");
          }

          Get.find<RideController>().ongoingTripList().then((value){
            if((Get.find<RideController>().ongoingRide ?? []).isEmpty){
              RideHelper.navigateToNextScreen(id: jsonDecode(event.data!)['id'].toString());
            }else{
              Get.offAll(()=> const OngoingRideScreen());
            }
          });

        });
      }


    }

  }



  void pusherDisconnectPusher(){
    pusherClient?.disconnect();
  }


   static void recordLocationViaPusher({
    required String token,
    required double latitude,
    required double longitude,
    required String location,
  }) async {

    if (Get.find<SplashController>().pusherConnectionStatus != null || Get.find<SplashController>().pusherConnectionStatus == 'Connected'){
      final recordLocationChannel = pusherClient!.privateChannel( 'private-user-location', authorizationDelegate:
      EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint: Uri.parse('${AppConstants.baseUrl}${AppConstants.broadcastingAuthUrl}'),
        headers:  {
          "Accept": "application/json",
          "Authorization": "Bearer ${Get.find<AuthController>().getUserToken()}",
          "Access-Control-Allow-Origin": "*",
          'Access-Control-Allow-Methods':"PUT, GET, POST, DELETE, OPTIONS"
        },
      ));

      recordLocationChannel.subscribeIfNotUnsubscribed();

      Future.delayed(Duration(seconds: 2), (){
        if (kDebugMode) {
          print("<<<<-------- Location update via websocket ------->>>>> Lat: $latitude / Lon : $longitude");
        }
        recordLocationChannel.trigger(
          eventName: 'client-location-update',
          data: {
            'token': token,
            'latitude': latitude.toString(),
            'longitude': longitude.toString(),
            'location': location,
          },
        );
      });
    }

  }


}