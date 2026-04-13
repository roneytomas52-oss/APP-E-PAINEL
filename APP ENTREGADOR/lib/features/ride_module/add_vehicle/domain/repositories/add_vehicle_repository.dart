   
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart_delivery/features/ride_module/add_vehicle/domain/models/vehicle_body.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';

import '../../../../../api/api_client.dart';
import 'add_vehicle_repository_interface.dart';

class AddVehicleRepository implements AddVehicleRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  AddVehicleRepository({required this.sharedPreferences, required this.apiClient});
}
  