import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/ride_module/safety/domain/services/safety_alert_service_interface.dart';


 enum SafetyAlertState{initialState,predefineAlert,afterSendAlert,otherNumberState}

class SafetyAlertController extends GetxController implements GetxService {
  final SafetyAlertServiceInterface safetyAlertServiceInterface;
  SafetyAlertController({required this.safetyAlertServiceInterface});

  SafetyAlertState currentState = SafetyAlertState.initialState;

  void updateSafetyAlertState(SafetyAlertState state,{bool isUpdate = true}){}
  void getSafetyAlertDetails(String tripId) async{}
  void checkDriverNeedSafety() async{}
  void cancelDriverNeedSafetyStream(){}

}