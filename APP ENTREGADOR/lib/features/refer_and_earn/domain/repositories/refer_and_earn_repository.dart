   
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart_delivery/api/api_client.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'refer_and_earn_repository_interface.dart';

class ReferEarnRepository implements ReferEarnRepositoryInterface{
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  ReferEarnRepository({required this.sharedPreferences, required this.apiClient});


  String _getUserToken() {
    return sharedPreferences.getString(AppConstants.token) ?? "";
  }

  @override
  Future<Response> getEarningHistoryList(int offset, String type, String? startDate, String? endDate) async{
    return await apiClient.getData('${AppConstants.referralEarningList}?limit=10&offset=$offset&date_range=$type&start_date=${startDate??''}&end_date=${endDate??''}&token=${_getUserToken()}');
  }

  @override
  Future<Response> getReferralDetails() async{
    return await apiClient.getData('$AppConstants?token=${_getUserToken()}');
  }
}
  