  import 'package:get/get_connect/http/src/response/response.dart';

import '../repositories/refer_and_earn_repository_interface.dart';
  import 'refer_and_earn_service_interface.dart';

  class ReferEarnService implements ReferEarnServiceInterface{
    ReferEarnRepositoryInterface referEarnRepositoryInterface;

    ReferEarnService({required this.referEarnRepositoryInterface});

    @override
    Future<Response> getEarningHistoryList(int offset, String type, String? startDate, String? endDate) async{
      return await referEarnRepositoryInterface.getEarningHistoryList(offset, type, startDate, endDate);
    }

    @override
    Future<Response> getReferralDetails() async{
      return await referEarnRepositoryInterface.getReferralDetails();
    }
  }
  