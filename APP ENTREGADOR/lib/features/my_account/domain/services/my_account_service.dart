import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/models/response_model.dart';
import 'package:sixam_mart_delivery/features/my_account/domain/models/earning_report_model.dart';
import 'package:sixam_mart_delivery/features/my_account/domain/models/loyalty_report_model.dart';
import 'package:sixam_mart_delivery/features/my_account/domain/models/referral_report_model.dart';
import 'package:sixam_mart_delivery/features/my_account/domain/models/wallet_payment_model.dart';
import 'package:sixam_mart_delivery/features/my_account/domain/models/withdraw_request_model.dart';
import 'package:sixam_mart_delivery/features/my_account/domain/repositories/my_account_repository_interface.dart';
import 'package:sixam_mart_delivery/features/my_account/domain/services/my_account_service_interface.dart';

class MyAccountService implements MyAccountServiceInterface {
  final MyAccountRepositoryInterface myAccountRepositoryInterface;
  MyAccountService({required this.myAccountRepositoryInterface});

  @override
  Future<ResponseModel> makeCollectCashPayment(double amount, String paymentGatewayName) async {
    return await myAccountRepositoryInterface.makeCollectCashPayment(amount, paymentGatewayName);
  }

  @override
  Future<List<Transactions>?> getWalletPaymentList() async {
    return await myAccountRepositoryInterface.getList();
  }

  @override
  Future<List<Transactions>?> getWalletProvidedEarningList() async {
    return await myAccountRepositoryInterface.getWalletProvidedEarningList();
  }

  @override
  Future<ResponseModel> makeWalletAdjustment() async {
    return await myAccountRepositoryInterface.makeWalletAdjustment();
  }

  @override
  Future<EarningReportModel?> getEarningReport({String? offset, String? type, String? dateRange, String? startDate, String? endDate}) async {
    return await myAccountRepositoryInterface.getEarningReport(offset: offset, type: type, dateRange: dateRange, startDate: startDate, endDate: endDate);
  }

  @override
  Future<ReferralReportModel?> getReferralReport({String? offset, String? type, String? dateRange, String? startDate, String? endDate}) async {
    return await myAccountRepositoryInterface.getReferralReport(offset: offset, type: type, dateRange: dateRange, startDate: startDate, endDate: endDate);
  }

  @override
  Future<LoyaltyReportModel?> getLoyaltyReport({String? offset, String? type, String? dateRange, String? startDate, String? endDate}) async {
    return await myAccountRepositoryInterface.getLoyaltyReport(offset: offset, type: type, dateRange: dateRange, startDate: startDate, endDate: endDate);
  }

  @override
  Future<Response> downloadEarningInvoice({required int dmId, String? earningType}) async {
    return await myAccountRepositoryInterface.downloadEarningInvoice(dmId: dmId, earningType: earningType);
  }

  @override
  Future<List<WithdrawRequestModel>?> getWithdrawRequestList() async {
    return await myAccountRepositoryInterface.getWithdrawRequestList();
  }

  @override
  Future<Response?> getLoyaltyPointList({String? offset, String? dateRange, String? startDate, String? endDate, String? transactionType, bool? fromFilter}) async {
    return await myAccountRepositoryInterface.getLoyaltyPointList(offset: offset, dateRange: dateRange, startDate: startDate, endDate: endDate, transactionType: transactionType, fromFilter: fromFilter);
  }

  @override
  Future<Response> convertPoint(String point, {required bool isRideActive}) async {
    return await myAccountRepositoryInterface.convertPoint(point, isRideActive: isRideActive);
  }

}