import '../repositories/safety_alert_repository_interface.dart';
import 'safety_alert_service_interface.dart';

class SafetyAlertService implements SafetyAlertServiceInterface {
  final SafetyAlertRepositoryInterface safetyAlertRepositoryInterface;
  SafetyAlertService({required this.safetyAlertRepositoryInterface});

}
  