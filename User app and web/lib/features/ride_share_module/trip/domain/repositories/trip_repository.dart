   
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:sixam_mart/util/app_constants.dart';

import '../../../../../api/api_client.dart';
import 'trip_repository_interface.dart';

class TripRepository implements TripRepositoryInterface {
  final ApiClient apiClient;
  TripRepository({required this.apiClient});

  @override
  Future<Response> getTripList(String tripType, int offset, String from, String to, String filter,String status) async {
    return await apiClient.getData('${AppConstants.tripList}?type=ride_request&limit=20&offset=$offset&filter=$filter&start=$from&end=$to&status=$status');
  }

  @override
  Future getRideCancellationReasonList() async{
    return await apiClient.getData(AppConstants.rideCancellationReasonList);
  }

  @override
  Future<Response> submitReview(String id, int ratting, String comment ) async {
    return await apiClient.postData(AppConstants.submitReview,{
      "ride_request_id" : id,
      "rating" : ratting,
      "feedback" : comment,
    });
  }

  // @override
  // Future getParcelCancellationReasonList() async{
  //   return await apiClient.getData(AppConstants.parcelCancellationReasonList);
  // }

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
  