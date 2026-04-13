import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/util/app_constants.dart';

class AddressHelper {

  static Future<bool> saveUserAddressInSharedPref(AddressModel address, {bool isInRideModule = false, bool isInServiceModule = false}) async {
    SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
    String userAddress = jsonEncode(address.toJson());
    bool isRide = false;
    bool isService = false;
    try{
      isRide = Get.find<SplashController>().module != null && (Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ride);
      isService = Get.find<SplashController>().module != null && (Get.find<SplashController>().module!.moduleType.toString() == AppConstants.service);
      isInRideModule = isRide;
      isInServiceModule = isService;
    }catch(_) {}
    print('======== address.zoneId: ${address.zoneId} // ride selected: $isInRideModule // is ride = $isInServiceModule');

    Get.find<ApiClient>().updateHeader(
      sharedPreferences.getString(AppConstants.token),
      address.zoneIds,[],
      sharedPreferences.getString(AppConstants.languageCode),
      Get.find<SplashController>().module?.id?.toString(),
      address.latitude,
      address.longitude,
      isInRideModule ? address.rideZoneId : (address.serviceZoneId ?? address.zoneId),
      fromModule: isInRideModule || isInServiceModule,
    );
    return await sharedPreferences.setString(AppConstants.userAddress, userAddress);
  }

  static AddressModel? getUserAddressFromSharedPref() {
    SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
    AddressModel? addressModel;
    try {
      addressModel = AddressModel.fromJson(jsonDecode(sharedPreferences.getString(AppConstants.userAddress)!));
    }catch(e) {
      if(!GetPlatform.isWeb) {
        debugPrint('Address Catch exception : $e');
      }
    }
    return addressModel;
  }

  static bool clearAddressFromSharedPref() {
    SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
    sharedPreferences.remove(AppConstants.userAddress);
    return true;
  }

  //getIndexByAddressId
  static int getIndexByAddressId(List<AddressModel> addressList, String addressId) {
    int index = -1;
    for(int i=0; i<addressList.length; i++) {
      if(addressList[i].id.toString() == addressId) {
        index = i;
        break;
      }
    }
    return index;
  }

}