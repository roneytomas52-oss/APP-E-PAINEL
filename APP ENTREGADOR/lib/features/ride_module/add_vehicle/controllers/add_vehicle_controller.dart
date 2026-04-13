import 'package:get/get.dart';
import '../domain/services/add_vehicle_service_interface.dart';

class AddVehicleController extends GetxController implements GetxService {
  final AddVehicleServiceInterface addVehicleServiceInterface;

  AddVehicleController({required this.addVehicleServiceInterface});
}
