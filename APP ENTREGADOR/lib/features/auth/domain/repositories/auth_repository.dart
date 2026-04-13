import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart_delivery/api/api_client.dart';
import 'package:sixam_mart_delivery/features/auth/domain/models/delivery_man_body_model.dart';
import 'package:sixam_mart_delivery/features/auth/domain/models/vehicle_model.dart';
import 'package:sixam_mart_delivery/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/enums.dart';

class AuthRepository implements AuthRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  AuthRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<Response> login(String phone, String password, String type) async {
    return await apiClient.postData(AppConstants.loginUri, {"phone": phone, "password": password, "type": type}, handleError: false);
  }

  @override
  Future<bool> registerDeliveryMan(DeliveryManBodyModel deliveryManBody, List<MultipartBody> multiParts) async {
    Response response = await apiClient.postMultipartData(AppConstants.dmRegisterUri, deliveryManBody.toJson(), multiParts);
    return (response.statusCode == 200);
  }

  @override
  Future<List<VehicleModel>?> getList() async {
    List<VehicleModel>? vehicles;
    Response response = await apiClient.getData(AppConstants.vehiclesUri);
    if(response.statusCode == 200) {
      vehicles = [];
      response.body.forEach((vehicle) => vehicles!.add(VehicleModel.fromJson(vehicle)));
    }
    return vehicles;
  }

  @override
  Future<Response> updateToken() async {
    String? deviceToken;
    if (GetPlatform.isIOS) {
      FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true, announcement: false, badge: true, carPlay: false,
        criticalAlert: false, provisional: false, sound: true,
      );
      if(settings.authorizationStatus == AuthorizationStatus.authorized) {
        deviceToken = await _saveDeviceToken();
      }
    }else {
      deviceToken = await _saveDeviceToken();
    }
    if(!GetPlatform.isWeb) {
      if(AppConstants.appMode == AppMode.delivery){
        FirebaseMessaging.instance.subscribeToTopic(AppConstants.topicDeliveryman);
      }else{
        FirebaseMessaging.instance.subscribeToTopic(AppConstants.topicRider);
      }
      FirebaseMessaging.instance.subscribeToTopic(sharedPreferences.getString(AppConstants.zoneTopic)!);
      FirebaseMessaging.instance.subscribeToTopic(sharedPreferences.getString(AppConstants.vehicleWiseTopic)!);
    }
    return await apiClient.postData(AppConstants.tokenUri, {"_method": "put", "token": getUserToken(), "fcm_token": deviceToken}, handleError: false);
  }

  Future<String?> _saveDeviceToken() async {
    String? deviceToken = '';
    if(!GetPlatform.isWeb) {
      deviceToken = (await FirebaseMessaging.instance.getToken())!;
    }
    debugPrint('----Device Token----- $deviceToken');
    return deviceToken;
  }

  @override
  Future<bool> saveUserToken(String token, String zoneTopic, String vehicleWiseTopic) async {
    apiClient.token = token;
    apiClient.updateHeader(token, sharedPreferences.getString(AppConstants.languageCode));
    sharedPreferences.setString(AppConstants.zoneTopic, zoneTopic);
    sharedPreferences.setString(AppConstants.vehicleWiseTopic, vehicleWiseTopic);

    return await sharedPreferences.setString(AppConstants.token, token);
  }

  @override
  String getUserToken() {
    return sharedPreferences.getString(AppConstants.token) ?? "";
  }

  @override
  bool isLoggedIn() {
    return sharedPreferences.containsKey(AppConstants.token);
  }

  @override
  Future<bool> clearSharedData() async {
    if(!GetPlatform.isWeb) {

      try{
        if(AppConstants.appMode == AppMode.delivery){
          await FirebaseMessaging.instance.unsubscribeFromTopic(AppConstants.topicDeliveryman);
        }else{
          await FirebaseMessaging.instance.unsubscribeFromTopic(AppConstants.topicRider);
        }
        FirebaseMessaging.instance.unsubscribeFromTopic(sharedPreferences.getString(AppConstants.zoneTopic)!);
        FirebaseMessaging.instance.unsubscribeFromTopic(sharedPreferences.getString(AppConstants.vehicleWiseTopic)!);
      }catch(e){
        if (kDebugMode) {
          print("");
        }
      }
      apiClient.postData(AppConstants.tokenUri, {"_method": "put", "token": getUserToken()}, handleError: false);
    }
    await sharedPreferences.remove(AppConstants.token);
    await sharedPreferences.setStringList(AppConstants.ignoreList, []);
    await sharedPreferences.remove(AppConstants.userAddress);
    apiClient.updateHeader(null, null);
    return true;
  }

  @override
  Future<void> saveUserNumberAndPassword(String number, String password, String countryDialCode, String countryCode) async {
    try {
      await sharedPreferences.setString(AppConstants.userPassword, password);
      await sharedPreferences.setString(AppConstants.userNumber, number);
      await sharedPreferences.setString(AppConstants.userCountryDialCode, countryDialCode);
      await sharedPreferences.setString(AppConstants.userCountryCode, countryCode);
    } catch (e) {
      rethrow;
    }
  }

  @override
  String getUserNumber() {
    return sharedPreferences.getString(AppConstants.userNumber) ?? "";
  }

  @override
  String getUserCountryDialCode() {
    return sharedPreferences.getString(AppConstants.userCountryDialCode) ?? "";
  }

  @override
  String getUserCountryCode() {
    return sharedPreferences.getString(AppConstants.userCountryCode) ?? "";
  }

  @override
  String getUserPassword() {
    return sharedPreferences.getString(AppConstants.userPassword) ?? "";
  }

  @override
  bool isNotificationActive() {
    return sharedPreferences.getBool(AppConstants.notification) ?? true;
  }

  @override
  void setNotificationActive(bool isActive) {
    if(isActive) {
      updateToken();
    }else {
      if(!GetPlatform.isWeb) {
        apiClient.postData(AppConstants.tokenUri, {"_method": "put", "token": getUserToken()}, handleError: false);
        FirebaseMessaging.instance.unsubscribeFromTopic(AppConstants.topicDeliveryman);
        FirebaseMessaging.instance.unsubscribeFromTopic(AppConstants.topicRider);
        FirebaseMessaging.instance.unsubscribeFromTopic(sharedPreferences.getString(AppConstants.zoneTopic)!);
        FirebaseMessaging.instance.unsubscribeFromTopic(sharedPreferences.getString(AppConstants.vehicleWiseTopic)!);
      }
    }
    sharedPreferences.setBool(AppConstants.notification, isActive);
  }

  @override
  Future<bool> clearUserNumberAndPassword() async {
    await sharedPreferences.remove(AppConstants.userPassword);
    await sharedPreferences.remove(AppConstants.userCountryDialCode);
    await sharedPreferences.remove(AppConstants.userCountryCode);
    return await sharedPreferences.remove(AppConstants.userNumber);
  }

  @override
  Future<void> saveRideCreatedTime(DateTime dateTime) async {
    await sharedPreferences.setString('DateTime', dateTime.toString());
  }

  @override
  Future<String> remainingTime() async {
    return  sharedPreferences.getString('DateTime') ?? '';
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(int? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }

}