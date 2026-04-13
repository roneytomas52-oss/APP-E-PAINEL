import 'package:get/get_connect/http/src/response/response.dart';

abstract class ReferEarnServiceInterface{
  Future<Response> getEarningHistoryList (int offset, String type, String? startDate, String? endDate);
  Future<Response> getReferralDetails();
}