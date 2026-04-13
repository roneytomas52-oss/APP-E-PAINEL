import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';

const kLogTag = "[demandium]";
const kLogEnable = true;
DateTime? loginClickTime;

printLog(dynamic data) {
  if (kLogEnable) {
    if (kDebugMode) {
      print("$kLogTag${data.toString()}");
    }
  }
}

bool isRedundentClick(DateTime currentTime){
  if(loginClickTime==null){
    loginClickTime = currentTime;
    return false;
  }
  if(currentTime.difference(loginClickTime!).inSeconds<3){//set this difference time in seconds
    return true;
  }

  loginClickTime = currentTime;
  return false;
}


AlignmentGeometry favButtonAlignment(){
  return Get.find<LocalizationController>().isLtr ? Alignment.topRight : Alignment.topLeft;
}

// onDemandToast(String message,Color color){
//   return  Fluttertoast.showToast(
//       msg: message,
//       toastLength: Toast.LENGTH_SHORT,
//       timeInSecForIosWeb: 1,
//       backgroundColor: Colors.purple,
//       textColor: color,
//       fontSize: 16.0
//   );
// }
