import 'dart:async';
import 'package:sixam_mart_delivery/api/api_client.dart';
import 'package:sixam_mart_delivery/features/auth/domain/models/delivery_man_body_model.dart';
import 'package:sixam_mart_delivery/common/models/response_model.dart';
import 'package:sixam_mart_delivery/features/auth/domain/models/vehicle_model.dart';
import 'package:sixam_mart_delivery/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_delivery/helper/pusher_helper.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart_delivery/features/auth/domain/services/auth_service_interface.dart';

class AuthController extends GetxController implements GetxService {
  final AuthServiceInterface authServiceInterface;
  AuthController({required this.authServiceInterface}){
    _notification = authServiceInterface.isNotificationActive();
  }

  bool _isActiveRememberMe = false;
  bool get isActiveRememberMe => _isActiveRememberMe;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  bool _notification = true;
  bool get notification => _notification;
  
  XFile? _pickedImage;
  XFile? get pickedImage => _pickedImage;
  
  List<XFile> _pickedIdentities = [];
  List<XFile> get pickedIdentities => _pickedIdentities;
  
  final List<String> _identityTypeList = ['passport', 'driving_license', 'nid'];
  List<String> get identityTypeList => _identityTypeList;

  String? _selectedIdentityType;
  String? get selectedIdentityType => _selectedIdentityType;
  
  final List<String> _dmTypeList = ['freelancer', 'salary_based'];
  List<String> get dmTypeList => _dmTypeList;

  String? _selectedDmType;
  String? get selectedDmType => _selectedDmType;

  String? _selectedDmTypeId;
  String? get selectedDmTypeId => _selectedDmTypeId;
  
  List<VehicleModel>? _vehicles;
  List<VehicleModel>? get vehicles => _vehicles;
  
  List<int?>? _vehicleIds;
  List<int?>? get vehicleIds => _vehicleIds;

  String? _selectedVehicleId;
  String? get selectedVehicleId => _selectedVehicleId;
  
  double _dmStatus = 0.4;
  double get dmStatus => _dmStatus;
  
  bool _lengthCheck = false;
  bool get lengthCheck => _lengthCheck;
  
  bool _numberCheck = false;
  bool get numberCheck => _numberCheck;
  
  bool _uppercaseCheck = false;
  bool get uppercaseCheck => _uppercaseCheck;
  
  bool _lowercaseCheck = false;
  bool get lowercaseCheck => _lowercaseCheck;
  
  bool _spatialCheck = false;
  bool get spatialCheck => _spatialCheck;
  
  bool _showPassView = false;
  bool get showPassView => _showPassView;
  
  bool _acceptTerms = true;
  bool get acceptTerms => _acceptTerms;

  bool _notificationLoading = false;
  bool get notificationLoading => _notificationLoading;

  Future<ResponseModel> login(String phone, String password, String type) async {
    _isLoading = true;
    update();
    Response response = await authServiceInterface.login(phone, password, type);
    ResponseModel responseModel;
    if (response.statusCode == 200) {

      if(Get.find<SplashController>().configModel?.webSocketStatus ?? false){
        PusherHelper.initializePusher();
      }

      authServiceInterface.saveUserToken(response.body['token'], response.body['zone_topic'], response.body['topic']);
      await authServiceInterface.updateToken();
      responseModel = ResponseModel(true, 'successful');
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<void> registerDeliveryMan(DeliveryManBodyModel deliveryManBody) async {
    _isLoading = true;
    update();
    List<MultipartBody> multiParts = authServiceInterface.prepareMultiPartsBody(_pickedImage, _pickedIdentities);
    bool isSuccess = await authServiceInterface.registerDeliveryMan(deliveryManBody, multiParts);
    if (isSuccess) {
      Get.offAllNamed(RouteHelper.getDmRegistrationSuccessRoute());
    }
    _isLoading = false;
    update();
  }

  void setSelectedDmType(String? dmType) {
    _selectedDmType = dmType;
    _selectedDmTypeId = _selectedDmType == 'freelancer' ? '1' : '0';
    update();
  }

  void setSelectedVehicleType({String? vehicleId}) {
    _selectedVehicleId = vehicleId;
    update();
  }

  void setSelectedIdentityType(String? identityType) {
    _selectedIdentityType = identityType;
    update();
  }

  Future<void> getVehicleList() async {
    List<VehicleModel>? vehicles = await authServiceInterface.getVehicleList();
    if (vehicles != null) {
      _vehicles = [];
      _vehicleIds = [];
      _vehicles!.addAll(vehicles);
      _vehicleIds!.addAll(authServiceInterface.vehicleIds(vehicles));
    }
    update();
  }

  Future<void> updateToken() async {
    await authServiceInterface.updateToken();
  }

  void dmStatusChange(double value, {bool isUpdate = true}){
    _dmStatus = value;
    if(isUpdate) {
      update();
    }
  }

  void toggleTerms() {
    _acceptTerms = !_acceptTerms;
    update();
  }

  void toggleRememberMe() {
    _isActiveRememberMe = !_isActiveRememberMe;
    update();
  }

  bool isLoggedIn() {
    return authServiceInterface.isLoggedIn();
  }

  Future<bool> clearSharedData() async {
    return await authServiceInterface.clearSharedData();
  }

  void saveUserNumberAndPassword(String number, String password, String countryDialCode, String countryCode) {
    authServiceInterface.saveUserNumberAndPassword(number, password, countryDialCode, countryCode);
  }

  String getUserNumber() {
    return authServiceInterface.getUserNumber();
  }

  String getUserCountryDialCode() {
    return authServiceInterface.getUserCountryDialCode();
  }

  String getUserCountryCode() {
    return authServiceInterface.getUserCountryCode();
  }

  String getUserPassword() {
    return authServiceInterface.getUserPassword();
  }

  Future<bool> clearUserNumberAndPassword() async {
    return authServiceInterface.clearUserNumberAndPassword();
  }

  String getUserToken() {
    return authServiceInterface.getUserToken();
  }

  Future<bool> setNotificationActive(bool isActive) async {
    _notificationLoading = true;
    update();
    _notification = isActive;
    authServiceInterface.setNotificationActive(isActive);
    _notificationLoading = false;
    update();
    return _notification;
  }

  void pickDmImageForRegistration(bool isLogo, bool isRemove) async {
    if(isRemove) {
      _pickedImage = null;
      _pickedIdentities = [];
    }else {
      if (isLogo) {
        _pickedImage = await authServiceInterface.pickImageFromGallery();
      } else {
        XFile? pickedIdentities = await authServiceInterface.pickImageFromGallery();
        if(pickedIdentities != null) {
          _pickedIdentities.add(pickedIdentities);
        }
      }
      update();
    }
  }

  void removeIdentityImage(int index) {
    _pickedIdentities.removeAt(index);
    update();
  }

  void showHidePass({bool isUpdate = true}){
    _showPassView = ! _showPassView;
    if(isUpdate) {
      update();
    }
  }

  void validPassCheck(String pass, {bool isUpdate = true}){
    _lengthCheck = false;
    _numberCheck = false;
    _uppercaseCheck = false;
    _lowercaseCheck = false;
    _spatialCheck = false;

    if(pass.length > 7){
      _lengthCheck = true;
    }
    if(pass.contains(RegExp(r'[a-z]'))){
      _lowercaseCheck = true;
    }
    if(pass.contains(RegExp(r'[A-Z]'))){
      _uppercaseCheck = true;
    }
    if(pass.contains(RegExp(r'[ .!@#$&*~^%]'))){
      _spatialCheck = true;
    }
    if(pass.contains(RegExp(r'[\d+]'))){
      _numberCheck = true;
    }
    if(isUpdate) {
      update();
    }
  }

  void resetDmRegistrationData(){
    _pickedImage = null;
    _pickedIdentities = [];
    _selectedIdentityType = null;
    _selectedDmType = null;
    _selectedDmTypeId = null;
    _selectedVehicleId = null;
    _dmStatus = 0.4;
    _showPassView = false;
    _lengthCheck = false;
    _numberCheck = false;
    _uppercaseCheck = false;
    _lowercaseCheck = false;
    _spatialCheck = false;
  }

  void saveRideCreatedTime(){
    authServiceInterface.saveRideCreatedTime(DateTime.now());
  }
  
}