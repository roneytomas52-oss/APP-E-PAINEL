import 'dart:convert';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/models/config_model.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/auth/domain/enum/centralize_login_enum.dart';
import 'package:sixam_mart/features/auth/screens/new_user_setup_screen.dart';
import 'package:sixam_mart/features/auth/widgets/sign_in/manual_login_widget.dart';
import 'package:sixam_mart/features/auth/widgets/sign_in/otp_login_widget.dart';
import 'package:sixam_mart/features/auth/widgets/social_login_widget.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/verification/domein/enum/verification_type_enum.dart';
import 'package:sixam_mart/features/verification/screens/verification_screen.dart';
import 'package:sixam_mart/helper/centralize_login_helper.dart';
import 'package:sixam_mart/helper/custom_validator.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/helper/validate_check.dart';

class SignInView extends StatefulWidget {
  final bool exitFromApp;
  final bool backFromThis;
  final bool fromResetPassword;
  final Function(bool val)? isOtpViewEnable;
  const SignInView({super.key, required this.exitFromApp, required this.backFromThis, this.fromResetPassword = false, this.isOtpViewEnable});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _countryDialCode;
  GlobalKey<FormState>? _formKeyLogin;
  bool _prevOtpViewEnable = false;

  @override
  void initState() {
    super.initState();
    _formKeyLogin = GlobalKey<FormState>();
    AuthController authController  = Get.find<AuthController>();
    SplashController splashController = Get.find<SplashController>();

    WidgetsBinding.instance.addPostFrameCallback((_){
      CentralizeLoginType loginType = CentralizeLoginHelper.getPreferredLoginMethod(
        splashController.configModel!.centralizeLoginSetup!, authController.isOtpViewEnable,
      ).type;

      bool isOtpActive = loginType == CentralizeLoginType.otp || loginType == CentralizeLoginType.otpAndSocial;

      if (isOtpActive) {
        // Pre-fill from OTP-specific storage
        String otpNumber = authController.getOtpUserNumber();
        String otpCountryCode = authController.getOtpUserCountryCode();
        _countryDialCode = otpCountryCode.isNotEmpty
            ? otpCountryCode
            : CountryCode.fromCountryCode(splashController.configModel!.country!).dialCode;
        _phoneController.text = otpNumber;
      } else {
        // Pre-fill from manual-specific storage
        String manualNumber = authController.getUserNumber();
        String manualCountryCode = authController.getUserCountryCode();
        _countryDialCode = manualCountryCode.isNotEmpty
            ? manualCountryCode
            : CountryCode.fromCountryCode(splashController.configModel!.country!).dialCode;
        _phoneController.text = manualNumber;
        _passwordController.text = authController.getUserPassword();
      }

      if (_phoneController.text.isNotEmpty && !_phoneController.text.contains('@')) {
        authController.toggleIsNumberLogin(value: true);
      } else {
        authController.toggleIsNumberLogin(value: false);
      }
      authController.initCountryCode(countryCode: _countryDialCode != "" ? _countryDialCode : null);
    });

    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 800), () {
          FocusScope.of(Get.context!).requestFocus(_phoneFocus);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (authController) {
      // Restore manual credentials when navigating back from OTP view
      if (_prevOtpViewEnable && !authController.isOtpViewEnable) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _phoneController.text = authController.getUserNumber();
          _passwordController.text = authController.getUserPassword();
          String savedCountryCode = authController.getUserCountryCode();
          if (savedCountryCode.isNotEmpty) {
            _countryDialCode = savedCountryCode;
            authController.initCountryCode(countryCode: savedCountryCode);
          }
          if (_phoneController.text.isNotEmpty && !_phoneController.text.contains('@')) {
            authController.toggleIsNumberLogin(value: true);
          } else {
            authController.toggleIsNumberLogin(value: false);
          }
        });
      }
      _prevOtpViewEnable = authController.isOtpViewEnable;

      return Form(
        key: _formKeyLogin,
        child: activeCentralizeLogin(Get.find<SplashController>().configModel!.centralizeLoginSetup!, authController),
      );
    });
  }

  Widget activeCentralizeLogin(CentralizeLoginSetup centralizeLoginSetup, AuthController authController) {
    CentralizeLoginType centralizeLogin = CentralizeLoginHelper.getPreferredLoginMethod(centralizeLoginSetup, authController.isOtpViewEnable).type;
    switch (centralizeLogin) {
      case CentralizeLoginType.otp:
        return OtpLoginWidget(
          phoneController: _phoneController, phoneFocus: _phoneFocus,
          countryDialCode: _countryDialCode, backFromThis: widget.backFromThis,
          onCountryChanged: (CountryCode countryCode) => _countryDialCode = countryCode.dialCode,
          onClickLoginButton: () {
            _otpLogin(Get.find<AuthController>(), _countryDialCode!, CentralizeLoginType.otp);
          },
        );

      case CentralizeLoginType.manual:
        return ManualLoginWidget(
          phoneController: _phoneController, passwordController: _passwordController,
          phoneFocus: _phoneFocus, passwordFocus: _passwordFocus, onWebSubmit: (){}, backFromThis: widget.backFromThis,
          onClickLoginButton: () {
            _login(Get.find<AuthController>(), CentralizeLoginType.manual);
          },
        );

      case CentralizeLoginType.social:
        return SocialLoginWidget(onlySocialLogin: true, backFromThis: widget.backFromThis);

      case CentralizeLoginType.manualAndSocial:
        return ManualLoginWidget(
          phoneController: _phoneController, passwordController: _passwordController, phoneFocus: _phoneFocus, passwordFocus: _passwordFocus,
          socialEnable: true, backFromThis: widget.backFromThis,
          onWebSubmit: (){}, onClickLoginButton: () {
            _login(Get.find<AuthController>(), CentralizeLoginType.manual);
          },
        );

      case CentralizeLoginType.manualAndOtp:
        return ManualLoginWidget(
          phoneController: _phoneController, passwordController: _passwordController, phoneFocus: _phoneFocus,
          passwordFocus: _passwordFocus, backFromThis: widget.backFromThis,
          onOtpViewClick: () {
            widget.isOtpViewEnable!(true);
            // Always replace phone field with OTP-remembered number (clears manual number)
            AuthController ac = Get.find<AuthController>();
            String otpNumber = ac.getOtpUserNumber();
            String otpCountryCode = ac.getOtpUserCountryCode();
            _phoneController.text = otpNumber;
            if (otpCountryCode.isNotEmpty) {
              _countryDialCode = otpCountryCode;
            }
            setState(() {
              authController.enableOtpView(enable: true);
            });
          },
          onWebSubmit: (){},
          onClickLoginButton: () {
            _login(Get.find<AuthController>(), CentralizeLoginType.manual);
          },
        );

      case CentralizeLoginType.otpAndSocial:
        return SocialLoginWidget(onlySocialLogin: true, backFromThis: widget.backFromThis, onOtpViewClick: (){
          widget.isOtpViewEnable!(true);
          if(_countryDialCode != "" && _phoneController.text != "" && _phoneController.text.contains('@')) {
            _phoneController.text = '';
          }
          setState(() {
            authController.enableOtpView(enable: true);
          });
        });

      case CentralizeLoginType.manualAndSocialAndOtp:
        return ManualLoginWidget(
          phoneController: _phoneController, passwordController: _passwordController, phoneFocus: _phoneFocus, passwordFocus: _passwordFocus,
          onWebSubmit: (){}, socialEnable: true, backFromThis: widget.backFromThis,
          onClickLoginButton: () {
            _login(Get.find<AuthController>(), CentralizeLoginType.manual);
          },
          onOtpViewClick: () {
            widget.isOtpViewEnable!(true);
            // Always replace phone field with OTP-remembered number (clears manual number)
            AuthController ac = Get.find<AuthController>();
            String otpNumber = ac.getOtpUserNumber();
            String otpCountryCode = ac.getOtpUserCountryCode();
            _phoneController.text = otpNumber;
            if (otpCountryCode.isNotEmpty) {
              _countryDialCode = otpCountryCode;
            }
            setState(() {
              authController.enableOtpView(enable: true);
            });
          },
        );

      }
  }
  
  void _otpLogin(AuthController authController, String countryDialCode, CentralizeLoginType loginType) async {
    String phone = _phoneController.text.trim();
    String numberWithCountryCode = countryDialCode+phone;
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if(_formKeyLogin!.currentState!.validate()) {
      if(!phoneValid.isValid) {
        showCustomSnackBar('invalid_phone_number'.tr);
      } else {
        authController.otpLogin(phone: numberWithCountryCode, otp: '', loginType: loginType.name, verified: '', alreadyInApp: widget.backFromThis).then((response) {
          if (response.isSuccess) {
            _processOtpSuccessSetup(response, authController, phone, countryDialCode);
          } else {
            showCustomSnackBar(response.message);
          }
        });
      }
    }
  }

  void _login(AuthController authController, CentralizeLoginType loginType) async {
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    String numberWithCountryCode = authController.countryDialCode + phone;
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if(_formKeyLogin!.currentState!.validate()) {

      String isPhone = ValidateCheck.getValidPhone(authController.countryDialCode + _phoneController.text.trim(), withCountryCode: true);

      if(isPhone != "" && !phoneValid.isValid) {
        showCustomSnackBar('invalid_phone_number'.tr);
      } else {
        authController.login(
          emailOrPhone: isPhone != "" ? isPhone : phone, password: password,
          loginType: loginType.name, fieldType: isPhone !="" ? VerificationTypeEnum.phone.name : VerificationTypeEnum.email.name,
          alreadyInApp: widget.backFromThis,
        ).then((status) async {
          if (status.isSuccess) {
            if(status.isSuccess && !status.authResponseModel!.isPersonalInfo!) {
              if(ResponsiveHelper.isDesktop(Get.context)) {
                Get.back();
                Get.dialog(NewUserSetupScreen(name: '', loginType: loginType.name, phone: numberWithCountryCode, email: '', backFromThis: widget.backFromThis));
              } else {
                Get.toNamed(RouteHelper.getNewUserSetupScreen(name: '', loginType: loginType.name, phone: numberWithCountryCode, email: '', backFromThis: widget.backFromThis));
              }
            } else {
              _processSuccessSetup(authController, phone, isPhone, password, status);
            }
          } else {
            showCustomSnackBar(status.message);
          }
        });
      }

    }
  }

  Future<void> _processSuccessSetup(AuthController authController, String phone, String email, String password, ResponseModel status) async {
    // Manual login remember me — saves to manual-specific keys only
    if (authController.isActiveRememberMe) {
      authController.saveUserNumberAndPassword(phone, password, authController.countryDialCode);
    } else {
      authController.clearUserNumberAndPassword();
    }
    if(GetPlatform.isWeb){
      // await Get.find<FavouriteController>().getFavouriteList();
    }
    if(status.authResponseModel != null && !status.authResponseModel!.isPhoneVerified!) {
      List<int> encoded = utf8.encode(password);
      String data = base64Encode(encoded);
      String token = status.authResponseModel!.token??'';
      if(Get.find<SplashController>().configModel!.firebaseOtpVerification!) {
        Get.find<AuthController>().firebaseVerifyPhoneNumber(phone, token, CentralizeLoginType.manual.name, fromSignUp: true);
      } else {
        Get.toNamed(RouteHelper.getVerificationRoute(phone, null, token, RouteHelper.signUp, data, CentralizeLoginType.manual.name),
        );
      }
    } else if(status.authResponseModel != null && !status.authResponseModel!.isEmailVerified!) {
      List<int> encoded = utf8.encode(password);
      String data = base64Encode(encoded);
      String token = status.authResponseModel!.token??'';
      Get.toNamed(RouteHelper.getVerificationRoute(null, email, token, RouteHelper.signUp, data, CentralizeLoginType.manual.name));
    } else {
      if(widget.backFromThis) {
        if(ResponsiveHelper.isDesktop(Get.context) || widget.fromResetPassword){
          Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: false));
        } else {
          Get.back();
        }
      } else {
        Get.find<LocationController>().navigateToLocationScreen('sign-in', offNamed: true);
      }
    }
  }

  void _processOtpSuccessSetup(ResponseModel response, AuthController authController, String phone, String countryDialCode) async {
    // OTP login remember me — saves to OTP-specific keys only
    if (authController.isActiveRememberMeOtp) {
      authController.saveOtpUserNumber(phone, countryDialCode);
    } else {
      authController.clearOtpUserNumber();
    }
    if(GetPlatform.isWeb && response.authResponseModel == null){
      await Get.find<FavouriteController>().getFavouriteList();
    }
    if(response.authResponseModel != null && !response.authResponseModel!.isPhoneVerified!) {
      if(Get.find<SplashController>().configModel!.firebaseOtpVerification!) {
        Get.find<AuthController>().firebaseVerifyPhoneNumber(countryDialCode + phone, '', CentralizeLoginType.otp.name, fromSignUp: true);
      } else {
        if(ResponsiveHelper.isDesktop(Get.context)) {
          Get.back();
          Get.dialog(VerificationScreen(
            number: countryDialCode + phone, email: null, token: '', fromSignUp: true,
            fromForgetPassword: false, loginType: CentralizeLoginType.otp.name, password: '',
          ));
        } else {
          Get.toNamed(RouteHelper.getVerificationRoute(
            countryDialCode + phone, null, '', RouteHelper.signUp, null, CentralizeLoginType.otp.name,
            backFromThis: widget.backFromThis,
          ));
        }
      }
    } else {
      if(widget.backFromThis) {
        if(ResponsiveHelper.isDesktop(Get.context)){
          Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: false));
        } else {
          Get.back();
        }
      }else {
        Get.find<LocationController>().navigateToLocationScreen('sign-in', offNamed: true);
      }
    }
  }
}