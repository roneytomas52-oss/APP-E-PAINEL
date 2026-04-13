
abstract class ReferEarnRepositoryInterface {
  Future<dynamic> getEarningHistoryList (int offset, String type, String? startDate, String? endDate);
  Future<dynamic> getReferralDetails();
}