import 'package:sixam_mart_delivery/common/models/response_model.dart';
import 'package:sixam_mart_delivery/features/forgot_password/domain/repositories/forgot_password_repository_interface.dart';
import 'package:sixam_mart_delivery/features/forgot_password/domain/services/forgot_password_service_interface.dart';
import 'package:sixam_mart_delivery/features/profile/domain/models/profile_model.dart';

class ForgotPasswordService implements ForgotPasswordServiceInterface {
  final ForgotPasswordRepositoryInterface forgotPasswordRepositoryInterface;
  ForgotPasswordService({required this.forgotPasswordRepositoryInterface});

  @override
  Future<ResponseModel> changePassword(ProfileModel userInfoModel, String password) async {
    return await forgotPasswordRepositoryInterface.changePassword(userInfoModel, password);
  }

  @override
  Future<ResponseModel> forgetPassword(String? phone) async {
    return await forgotPasswordRepositoryInterface.forgetPassword(phone);
  }

  @override
  Future<ResponseModel> verifyToken(String? phone, String token) async {
    return await forgotPasswordRepositoryInterface.verifyToken(phone, token);
  }

  @override
  Future<ResponseModel> verifyFirebaseOtp({required String phoneNumber, required String session, required String otp}) async {
    return await forgotPasswordRepositoryInterface.verifyFirebaseOtp(phoneNumber: phoneNumber, session: session, otp: otp);
  }

  @override
  Future<ResponseModel> resetPassword(String? resetToken, String phone, String password, String confirmPassword) async {
    return await forgotPasswordRepositoryInterface.resetPassword(resetToken, phone, password, confirmPassword);
  }

}