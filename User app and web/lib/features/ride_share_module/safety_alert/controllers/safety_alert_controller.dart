
import 'package:get/get.dart';
import '../domain/services/safety_alert_service_interface.dart';

enum SafetyAlertState{initialState,predefineAlert,afterSendAlert,otherNumberState}

class SafetyAlertController extends GetxController implements GetxService {
  final SafetyAlertServiceInterface safetyAlertServiceInterface;

  SafetyAlertController({required this.safetyAlertServiceInterface});

  void updateSafetyAlertState(SafetyAlertState state,{bool isUpdate = true}){
  }

  void checkDriverNeedSafety() async{
  }

  void cancelDriverNeedSafetyStream(){
  }

  void getSafetyAlertDetails(String tripId) async{
  }

}
  