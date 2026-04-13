
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../api/api_client.dart';
import 'ride_order_repository_interface.dart';

class RideOrderRepository implements RideOrderRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  RideOrderRepository({required this.sharedPreferences, required this.apiClient});

  @override
  Future add(value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) {
    // TODO: implement getList
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    // TODO: implement update
    throw UnimplementedError();
  }

}
  