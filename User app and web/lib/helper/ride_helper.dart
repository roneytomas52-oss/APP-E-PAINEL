import 'package:get/get.dart';
import 'package:sixam_mart/features/ride_share_module/ride_location/domain/models/ride_details_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/date_converter.dart';

class RideHelper {
  static bool isShowSafetyFeature(RideDetails tripDetails){
    if(tripDetails.rideCompleteTime != null){
      int time = DateTime.now().difference(DateConverter.dateTimeStringToDate(tripDetails.rideCompleteTime!)).inSeconds;
      int activeTime = (Get.find<SplashController>().configModel?.afterTripCompleteSafetyFeatureSetTime ?? 0);
      if(Get.find<SplashController>().configModel?.afterTripCompleteSafetyFeatureSetTimeFormat == 'minute') {
        activeTime = activeTime * 60;
      } else if (Get.find<SplashController>().configModel?.afterTripCompleteSafetyFeatureSetTimeFormat == 'hour') {
        activeTime = activeTime * 3600;
      }
      print('======check==2=> $time and $activeTime // format: ${Get.find<SplashController>().configModel?.afterTripCompleteSafetyFeatureSetTimeFormat}');
      print('======check==3=> ${(Get.find<SplashController>().configModel?.afterTripCompleteSafetyFeatureActiveStatus ?? false)} && ${tripDetails.currentStatus ==  "completed"} && ${tripDetails.type != "parcel"} && ${activeTime > time} && ${tripDetails.customerSafetyAlert == null}');
      return (Get.find<SplashController>().configModel?.afterTripCompleteSafetyFeatureActiveStatus ?? false) && tripDetails.currentStatus ==  "completed" &&
          tripDetails.type != "parcel" && activeTime > time && tripDetails.customerSafetyAlert == null ? true : false;
    }else{
      return false;
    }
  }
}