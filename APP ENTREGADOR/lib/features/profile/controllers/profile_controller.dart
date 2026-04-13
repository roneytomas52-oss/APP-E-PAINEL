import 'dart:async';
import 'package:sixam_mart_delivery/common/models/response_model.dart';
import 'package:sixam_mart_delivery/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_delivery/features/profile/domain/models/level_model.dart';
import 'package:sixam_mart_delivery/features/ride_module/map/controllers/ride_map_controller.dart';
import 'package:sixam_mart_delivery/features/ride_module/ride_order/controllers/ride_controller.dart';
import 'package:sixam_mart_delivery/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_delivery/features/address/domain/models/record_location_body_model.dart';
import 'package:sixam_mart_delivery/features/profile/domain/models/profile_model.dart';
import 'package:sixam_mart_delivery/helper/pusher_helper.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart_delivery/features/profile/domain/services/profile_service_interface.dart';

class ProfileController extends GetxController implements GetxService {
  final ProfileServiceInterface profileServiceInterface;
  ProfileController({required this.profileServiceInterface});

  ProfileModel? _profileModel;
  ProfileModel? get profileModel => _profileModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  XFile? _pickedFile;
  XFile? get pickedFile => _pickedFile;

  RecordLocationBodyModel? _recordLocation;
  RecordLocationBodyModel? get recordLocationBody => _recordLocation;

  Timer? _timer;

  bool _backgroundNotification = true;
  bool get backgroundNotification => _backgroundNotification;

  LevelModel? _levelModel;
  LevelModel? get levelModel => _levelModel;

  Future<void> getProfileLevelInfo() async{
    Response response = await profileServiceInterface.getProfileLevelInfo();
    if(response.statusCode == 200){
      _levelModel = LevelModel.fromJson(response.body);

    }/*else{
      ApiChecker.checkApi(response);
    }*/
    update();
  }

  Future<ProfileModel?>  getProfile() async {
    ProfileModel? profileModel = await profileServiceInterface.getProfileInfo();
    if (profileModel != null) {
      _profileModel = profileModel;

      PusherHelper().driverTripRequestSubscribe(_profileModel!.id.toString());

      if (_profileModel!.active == 1) {
        profileServiceInterface.checkPermission(() => startLocationRecord());
      } else {
        stopLocationRecord();
      }
    }
    update();
    return profileModel;
  }

  Future<bool> updateUserInfo(ProfileModel updateUserModel, String token) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await profileServiceInterface.updateProfile(updateUserModel, _pickedFile, token);
    _isLoading = false;
    if (responseModel.isSuccess) {
      _profileModel = updateUserModel;
      Get.back();
      showCustomSnackBar(responseModel.message, isError: false);
    } else {
      showCustomSnackBar(responseModel.message, isError: true);
    }
    update();
    return responseModel.isSuccess;
  }

  void pickImage() async {
    _pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    update();
  }

  void initData() {
    _pickedFile = null;
  }

  Future<bool> updateActiveStatus() async {
    ResponseModel responseModel = await profileServiceInterface.updateActiveStatus();
    if (responseModel.isSuccess) {
      Get.back();
      _profileModel!.active = _profileModel!.active == 0 ? 1 : 0;
      showCustomSnackBar(responseModel.message, isError: false);
      if (_profileModel!.active == 1) {
        profileServiceInterface.checkPermission(() => startLocationRecord());
      } else {
        stopLocationRecord();
      }
    } else {
      showCustomSnackBar(responseModel.message, isError: true);
    }
    update();
    return responseModel.isSuccess;
  }

  Future deleteDriver() async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await profileServiceInterface.deleteDriver();
    _isLoading = false;
    if (responseModel.isSuccess) {
      showCustomSnackBar(responseModel.message, isError: false);
      Get.find<AuthController>().clearSharedData();
      stopLocationRecord();
      PusherHelper().pusherDisconnectPusher();
      Get.offAllNamed(RouteHelper.getSignInRoute());
    }else{
      Get.back();
      showCustomSnackBar(responseModel.message, isError: true);
    }
  }

  void startLocationRecord() {
    recordLocation();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      recordLocation();
    });
  }

  void stopLocationRecord() {
    _timer?.cancel();
  }

  Future<void> recordLocation() async {
    final Position locationResult = await Geolocator.getCurrentPosition();
    String address = await profileServiceInterface.addressPlaceMark(locationResult);
    String zoneId = await profileServiceInterface.getZoneId(locationResult);

    _recordLocation = RecordLocationBodyModel(
      location: address, latitude: locationResult.latitude, longitude: locationResult.longitude, zoneId: zoneId
    );

    List<String> status = ['accepted','ongoing'];
    if(Get.find<RideController>().tripDetail != null && status.contains(Get.find<RiderMapController>().currentRideState.name) && Get.find<AuthController>().getUserToken() != ''){
      Get.find<RideController>().remainingDistance(Get.find<RideController>().tripDetail!.id!);
    }

    //await profileServiceInterface.recordLocation(_recordLocation!);
    /// todo Need to integrate Pusher
    if(Get.find<AuthController>().isLoggedIn()){
      if(Get.find<SplashController>().configModel!.webSocketStatus!) {
        await profileServiceInterface.recordWebSocketLocation(_recordLocation!, zoneId);
      } else {
        await profileServiceInterface.recordLocation(_recordLocation!, zoneId);
      }
    }
  }

  void setBackgroundNotificationActive(bool isActive) {
    _backgroundNotification = isActive;
    update();
  }

}