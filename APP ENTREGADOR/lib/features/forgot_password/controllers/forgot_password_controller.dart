import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sixam_mart_delivery/features/profile/domain/models/profile_model.dart';
import 'package:sixam_mart_delivery/common/models/response_model.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/forgot_password/domain/services/forgot_password_service_interface.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';

class ForgotPasswordController extends GetxController implements GetxService {
  final ForgotPasswordServiceInterface forgotPasswordServiceInterface;
  ForgotPasswordController({required this.forgotPasswordServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _resendOtpLoading = false;
  bool get resendOtpLoading => _resendOtpLoading;

  String _verificationCode = '';
  String get verificationCode => _verificationCode;

  Future<bool> changePassword(ProfileModel updatedUserModel, String password) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await forgotPasswordServiceInterface.changePassword(updatedUserModel, password);
    _isLoading = false;
    if (responseModel.isSuccess) {
      Get.back();
      showCustomSnackBar(responseModel.message, isError: false);
    } else {
      showCustomSnackBar(responseModel.message, isError: true);
    }
    update();
    return responseModel.isSuccess;
  }

  Future<ResponseModel> forgetPassword(String? email) async {
    _resendOtpLoading = true;
    update();
    ResponseModel responseModel = await forgotPasswordServiceInterface.forgetPassword(email);
    _resendOtpLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> verifyToken(String? number) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await forgotPasswordServiceInterface.verifyToken(number, _verificationCode);
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> verifyFirebaseOtp({required String phoneNumber, required String session, required String otp}) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await forgotPasswordServiceInterface.verifyFirebaseOtp(phoneNumber: phoneNumber, session: session, otp: otp);
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> resetPassword(String? resetToken, String phone, String password, String confirmPassword) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await forgotPasswordServiceInterface.resetPassword(resetToken, phone, password, confirmPassword);
    _isLoading = false;
    update();
    return responseModel;
  }

  void updateVerificationCode(String query) {
    _verificationCode = query;
    update();
  }

  Future<void> firebaseVerifyPhoneNumber(String phoneNumber, {bool canRoute = true}) async {
    _resendOtpLoading = true;
    update();

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        _resendOtpLoading = false;
        update();

        if(e.code == 'invalid-phone-number') {
          showCustomSnackBar('please_submit_a_valid_phone_number'.tr);
        }else{
          showCustomSnackBar(e.message?.replaceAll('_', ' '));
        }

      },
      codeSent: (String vId, int? resendToken) {
        _resendOtpLoading = false;
        update();

        if(canRoute) {
          Get.toNamed(RouteHelper.getVerificationRoute(phoneNumber, session: vId));
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

}