import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart_delivery/api/api_client.dart';
import 'ride_order_repository_interface.dart';

class RideOrderRepository implements RideOrderRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  RideOrderRepository({required this.apiClient, required this.sharedPreferences});
}
  