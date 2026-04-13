import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/models/response_model.dart';
import 'package:sixam_mart_delivery/features/my_account/domain/models/earning_report_model.dart';
import 'package:sixam_mart_delivery/features/my_account/domain/models/loyalty_report_model.dart';
import 'package:sixam_mart_delivery/features/my_account/domain/models/referral_report_model.dart';
import 'package:sixam_mart_delivery/features/my_account/domain/models/wallet_payment_model.dart';
import 'package:sixam_mart_delivery/features/my_account/domain/models/withdraw_request_model.dart';

abstract class MyAccountServiceInterface {
  Future<ResponseModel> makeCollectCashPayment(double amount, String paymentGatewayName);
  Future<List<Transactions>?> getWalletPaymentList();
  Future<List<Transactions>?> getWalletProvidedEarningList();
  Future<ResponseModel> makeWalletAdjustment();
  Future<EarningReportModel?> getEarningReport({String? offset, String? type, String? dateRange, String? startDate, String? endDate});
  Future<ReferralReportModel?> getReferralReport({String? offset, String? type, String? dateRange, String? startDate, String? endDate});
  Future<LoyaltyReportModel?> getLoyaltyReport({String? offset, String? type, String? dateRange, String? startDate, String? endDate});
  Future<Response> downloadEarningInvoice({required int dmId, String? earningType});
  Future<List<WithdrawRequestModel>?> getWithdrawRequestList();
  Future<Response?> getLoyaltyPointList({String? offset, String? dateRange, String? startDate, String? endDate, String? transactionType, bool? fromFilter});
  Future<Response> convertPoint(String point, {required bool isRideActive});
}