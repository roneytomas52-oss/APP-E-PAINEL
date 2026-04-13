import 'package:sixam_mart_delivery/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:sixam_mart_delivery/common/models/error_response.dart';

class ApiChecker {
  static void checkApi(Response response) {

    ErrorResponse? errorResponse;

    try{
      errorResponse = ErrorResponse.fromJson(response.body);
    }catch(e){
      if (kDebugMode) {
        print(e);
      }
    }

    if(response.statusCode == 401) {
      Get.find<AuthController>().clearSharedData();
      Get.find<ProfileController>().stopLocationRecord();
      if(Get.currentRoute != RouteHelper.signIn){
        Get.offAllNamed(RouteHelper.getSignInRoute());
      }
    }
    else if(response.statusCode == 403 && (response.body['message'] != null || response.body['errors'] != null)){
      String message = response.body['message'] ?? (response.body['errors'] != null ? errorResponse?.errors?.first.message : response.statusText);
      showCustomSnackBar( message);

    }
    else if((response.statusCode == 400 && errorResponse != null &&   errorResponse.errors !=null && errorResponse.errors!.isNotEmpty) || (response.statusCode == 400 && response.body['message'] != null)){
      showCustomSnackBar( errorResponse != null && errorResponse.errors !=null && errorResponse.errors!.isNotEmpty ? errorResponse.errors?.first.message : response.body['message'] ?? "");
    }
    else if((response.statusCode == 409 && response.body['message'] != null)){
      showCustomSnackBar( response.body['message'] ?? "");
    }
    else {
      showCustomSnackBar(response.statusText);
    }
  }
}