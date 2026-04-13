  import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/refer_and_earn/domain/models/refer_and_earn_model.dart';
  import '../domain/services/refer_and_earn_service_interface.dart';

  class ReferAndEarnController extends GetxController implements GetxService{
    final ReferEarnServiceInterface referEarnServiceInterface;
    ReferAndEarnController({required this.referEarnServiceInterface});

    List<String> referralType =['referral_details', 'earning'];
    int referralTypeIndex = 0;
    ScrollController scrollController = ScrollController();
    ReferEarningModel? referralModel;
    bool isLoading = false;

    String? _dateRange = 'this_year';
    String? get dateRange => _dateRange;

    String _startDate = '';
    String get startDate => _startDate;

    String _endDate = '';
    String get endDate => _endDate;

    void setReferralTypeIndex(int index, {bool isUpdate = false}){
      referralTypeIndex = index;
      if(isUpdate){
        update();
      }
    }

    void setDateRange(String dateRange, {String? startDate, String? endDate}){
      _dateRange = dateRange;
      _startDate = startDate?.split(' ').first??'';
      _endDate = endDate?.split(' ').first??'';
    }

    Future<Response> getEarningHistoryList (int offset) async{
      isLoading = true;
      update();

      Response response = await referEarnServiceInterface.getEarningHistoryList(offset, _dateRange??'this_year', _startDate, _endDate);
      if (response.statusCode == 200) {
        isLoading = false;
        if(offset == 1){
          referralModel = ReferEarningModel.fromJson(response.body);
        }else{
          referralModel!.refrealEarnings!.addAll(ReferEarningModel.fromJson(response.body).refrealEarnings!);
          referralModel!.offset = ReferEarningModel.fromJson(response.body).offset;
          referralModel!.total = ReferEarningModel.fromJson(response.body).total;
        }

      }else{
        isLoading = false;
      }
      update();
      return response;
    }

  }