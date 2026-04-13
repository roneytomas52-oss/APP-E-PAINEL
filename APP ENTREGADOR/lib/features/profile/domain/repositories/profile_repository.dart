import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart_delivery/api/api_client.dart';
import 'package:sixam_mart_delivery/common/models/response_model.dart';
import 'package:sixam_mart_delivery/features/address/domain/models/record_location_body_model.dart';
import 'package:sixam_mart_delivery/features/profile/domain/models/profile_model.dart';
import 'package:sixam_mart_delivery/features/profile/domain/repositories/profile_repository_interface.dart';
import 'package:sixam_mart_delivery/helper/pusher_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';

class ProfileRepository implements ProfileRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  ProfileRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<ProfileModel?> getProfileInfo() async {
    ProfileModel? profileModel;
    Response response = await apiClient.getData(AppConstants.profileUri + _getUserToken());
    if (response.statusCode == 200) {
      profileModel = ProfileModel.fromJson(response.body);
    }
    return profileModel;
  }

  @override
  Future<ResponseModel> updateProfile(ProfileModel userInfoModel, XFile? data, String token) async {
    ResponseModel responseModel;
    Map<String, String> fields = {};
    fields.addAll(<String, String>{
      '_method': 'put', 'f_name': userInfoModel.fName!, 'l_name': userInfoModel.lName!,
      'email': userInfoModel.email!, 'token': _getUserToken()
    });
    Response response = await apiClient.postMultipartData(AppConstants.updateProfileUri, fields, [MultipartBody('image', data)], handleError: false);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body['message']);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  @override
  Future<ResponseModel> updateActiveStatus() async {
    ResponseModel responseModel;
    Response response = await apiClient.postData(AppConstants.activeStatusUri, {'token': _getUserToken()}, handleError: false);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body['message']);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  @override
  Future<void> recordWebSocketLocation(RecordLocationBodyModel recordLocationBody, String zoneId) async {
    apiClient.updateHeader(_getUserToken(), sharedPreferences.getString(AppConstants.languageCode), zoneId: zoneId);
    sharedPreferences.setString(AppConstants.cacheZoneId, zoneId);
    recordLocationBody.token = _getUserToken();
    PusherHelper.recordLocationViaPusher(
      token: _getUserToken(),
      latitude: recordLocationBody.latitude ?? 0.0,
      longitude: recordLocationBody.longitude ?? 0.0,
      location: recordLocationBody.location ?? '',
    );
  }

  @override
  Future<Response> recordLocation(RecordLocationBodyModel recordLocationBody, String zoneId) {
    recordLocationBody.token = _getUserToken();
    apiClient.updateHeader(_getUserToken(), sharedPreferences.getString(AppConstants.languageCode), zoneId: zoneId);
    sharedPreferences.setString(AppConstants.cacheZoneId, zoneId);
    return apiClient.postData(AppConstants.recordLocationUri, recordLocationBody.toJson());
  }

  @override
  Future<String> getZoneId(Position locationResult) async {
    Response response = await apiClient.getData(
      "${AppConstants.getZoneId}?token=${_getUserToken()}&lat=${locationResult.latitude}&lng=${locationResult.longitude}",
      handleError: false,
    );

    String zoneId = "";
    if (response.statusCode == 200) {
      zoneId = response.body['data']['id'].toString();
    }
    return zoneId;
  }

  @override
  Future<ResponseModel> deleteDriver() async {
    ResponseModel responseModel;
    Response response = await apiClient.deleteData(AppConstants.driverRemoveUri + _getUserToken(), handleError: false);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, 'your_account_remove_successfully'.tr);
    }else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  String _getUserToken() {
    return sharedPreferences.getString(AppConstants.token) ?? "";
  }

  @override
  Future<Response> getProfileLevelInfo() async {
    return apiClient.getData('${AppConstants.getProfileLevel}?token=${_getUserToken()}');
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(int? id) {
    throw UnimplementedError();
  }

  @override
  Future getList() {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }

}