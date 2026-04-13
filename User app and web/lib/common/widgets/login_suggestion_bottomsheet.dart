import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/auth/domain/enum/centralize_login_enum.dart';
import 'package:sixam_mart/features/auth/domain/models/social_log_in_body.dart';
import 'package:sixam_mart/features/auth/screens/new_user_setup_screen.dart';
import 'package:sixam_mart/features/auth/widgets/sign_in/existing_user_bottom_sheet.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
class LoginSuggestionBottomSheet extends StatelessWidget {
  final bool fromCartPage;
  const LoginSuggestionBottomSheet({super.key, this.fromCartPage = false});

  @override
  Widget build(BuildContext context) {
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;
    bool googleLoginActive = Get.find<SplashController>().configModel!.socialLogin![0].status! && Get.find<SplashController>().configModel!.centralizeLoginSetup!.socialLoginStatus!
        && Get.find<SplashController>().configModel!.centralizeLoginSetup!.googleLoginStatus!;

    bool facebookLoginActive = Get.find<SplashController>().configModel!.socialLogin![1].status! && Get.find<SplashController>().configModel!.centralizeLoginSetup!.socialLoginStatus!
        && Get.find<SplashController>().configModel!.centralizeLoginSetup!.facebookLoginStatus!;

    bool canAppleLogin = Get.find<SplashController>().configModel!.appleLogin!.isNotEmpty && Get.find<SplashController>().configModel!.appleLogin![0].status!
        && !GetPlatform.isAndroid;
    bool appleLoginActive = canAppleLogin && Get.find<SplashController>().configModel!.centralizeLoginSetup!.socialLoginStatus!
        && Get.find<SplashController>().configModel!.centralizeLoginSetup!.appleLoginStatus!;

    bool isOtpActive = Get.find<SplashController>().configModel!.centralizeLoginSetup!.otpLoginStatus!;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusLarge),
          topRight: Radius.circular(Dimensions.radiusLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[

                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 5, width: 50,
                      margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeExtremeLarge),
                    child: Column(
                      children: [
                        Text(
                          fromCartPage ? 'create_account'.tr : "you_are_almost_there".tr,
                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Text(
                          fromCartPage ? 'login_or_signup_to_view_and_track_your_orders'.tr : "log_in_or_sign_up_to_enjoy_a_personalized_experience".tr,
                          style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeExtremeLarge),

                        CustomButton(
                          height: 50,
                          buttonText: 'login_sign_up'.tr,
                          onPressed: () async {
                            Get.back(result: true);
                            await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
                          },
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        if(isOtpActive)
                          CustomButton(
                            height: 50,
                            buttonText: 'otp_login'.tr,
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            textColor: Theme.of(context).textTheme.bodyLarge!.color,
                            onPressed: () async {
                              Get.back();
                              Get.find<AuthController>().enableOtpView(enable: true);
                              await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
                            },
                          ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        if(facebookLoginActive || googleLoginActive || appleLoginActive)
                          Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                child: Text(
                                  "or_continue_with".tr,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        Wrap(
                          spacing: 15,
                          runSpacing: 15,
                          children: <Widget>[
                            if(facebookLoginActive)
                              SocialLoginButton(
                                iconPath: Images.facebook2,
                                label: 'facebook'.tr,
                                onTap: () {
                                  Get.back();
                                  _facebookLogin();
                                },
                              ),

                            if(googleLoginActive)
                              SocialLoginButton(
                                iconPath: Images.google,
                                label: 'google'.tr,
                                onTap: () {
                                  Get.back();
                                  _googleLogin(googleSignIn);
                                },
                              ),

                            if(appleLoginActive)
                              SocialLoginButton(
                                iconPath: Images.appleLogo,
                                label: 'apple'.tr,
                                onTap: () {
                                  Get.back();
                                  _appleLogin();
                                },
                              ),
                          ],
                        ),

                        const SizedBox(height: Dimensions.paddingSizeDefault),

                      ],
                    ),
                  ),

                ],
              ),

              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.close, color: Theme.of(context).disabledColor),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _googleLogin(GoogleSignIn googleSignIn) async {
    if(kIsWeb) {
      await _googleWebSignIn();

    }else{
      try{
        if(googleSignIn.supportsAuthenticate()) {
          await googleSignIn.initialize(serverClientId: AppConstants.googleServerClientId).then((_) async {

            googleSignIn.signOut();
            GoogleSignInAccount googleAccount = await googleSignIn.authenticate();
            const List<String> scopes = <String>['email'];
            GoogleSignInClientAuthorization? auth = await googleAccount.authorizationClient.authorizationForScopes(scopes);

            SocialLogInBody googleBodyModel = SocialLogInBody(
              email: googleAccount.email, token: auth?.accessToken, uniqueId: googleAccount.id,
              medium: 'google', accessToken: 1, loginType: CentralizeLoginType.social.name,
            );

            Get.find<AuthController>().loginWithSocialMedia(googleBodyModel).then((response) {
              if (response.isSuccess) {
                _processSocialSuccessSetup(response, googleBodyModel, null, null);
              } else {
                showCustomSnackBar(response.message);
              }
            });
          });
        }else {
          debugPrint("Google Sign-In not supported on this device.");
        }
      }catch(e){
        debugPrint('Error in google sign in: $e');
      }
    }
  }

  Future<void> _googleWebSignIn() async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      UserCredential userCredential = await auth.signInWithPopup(googleProvider);

      SocialLogInBody googleBodyModel =  SocialLogInBody(
        uniqueId: userCredential.credential?.accessToken,
        token: userCredential.credential?.accessToken,
        accessToken: 1,
        medium: 'google',
        email: userCredential.user?.email,
        loginType: CentralizeLoginType.social.name,
      );

      Get.find<AuthController>().loginWithSocialMedia(googleBodyModel).then((response) {
        if (response.isSuccess) {
          _processSocialSuccessSetup(response, googleBodyModel, null, null);
        } else {
          showCustomSnackBar(response.message);
        }
      });

    } catch (e) {
      showCustomSnackBar(e.toString());
    }
  }

  void _facebookLogin() async {
    LoginResult result = await FacebookAuth.instance.login(permissions: ["public_profile", "email"]);
    if (result.status == LoginStatus.success) {
      Map userData = await FacebookAuth.instance.getUserData();

      SocialLogInBody facebookBodyModel = SocialLogInBody(
        email: userData['email'], token: result.accessToken!.tokenString, uniqueId: userData['id'],
        medium: 'facebook', loginType: CentralizeLoginType.social.name,
      );

      Get.find<AuthController>().loginWithSocialMedia(facebookBodyModel).then((response) {
        if (response.isSuccess) {
          _processSocialSuccessSetup(response, null, null, facebookBodyModel);
        } else {
          showCustomSnackBar(response.message);
        }
      });
    }
  }

  void _appleLogin() async {
    String clientID = Get.find<SplashController>().configModel!.appleLogin![0].clientId!;
    String redirectURL = Get.find<SplashController>().configModel!.appleLogin![0].redirectUrl!;

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      webAuthenticationOptions: GetPlatform.isIOS ? null : WebAuthenticationOptions(
        clientId: clientID,
        redirectUri: Uri.parse(redirectURL),
      ),
    );

    SocialLogInBody appleBodyModel = SocialLogInBody(
      email: credential.email, token: credential.authorizationCode, uniqueId: credential.authorizationCode,
      medium: 'apple', loginType: CentralizeLoginType.social.name, platform: GetPlatform.isIOS ? 'flutter_app' : 'flutter_web',
    );

    Get.find<AuthController>().loginWithSocialMedia(appleBodyModel).then((response) {
      if (response.isSuccess) {
        _processSocialSuccessSetup(response, null, appleBodyModel, null);
      } else {
        showCustomSnackBar(response.message);
      }
    });
  }

  void _processSocialSuccessSetup(ResponseModel response, SocialLogInBody? googleBodyModel, SocialLogInBody? appleBodyModel, SocialLogInBody? facebookBodyModel) {
    String? email = googleBodyModel != null ? googleBodyModel.email : appleBodyModel != null ? appleBodyModel.email : facebookBodyModel?.email;
    if(response.isSuccess && response.authResponseModel != null && response.authResponseModel!.isExistUser != null) {
      if(appleBodyModel != null) {
        email = response.authResponseModel!.email;
        appleBodyModel.email = email;
      }
      if(ResponsiveHelper.isDesktop(Get.context)) {
        Get.back();
        Get.dialog(Center(
          child: ExistingUserBottomSheet(
            userModel: response.authResponseModel!.isExistUser!, email: email, loginType: CentralizeLoginType.social.name,
            socialLogInBodyModel: googleBodyModel ?? appleBodyModel ?? facebookBodyModel, backFromThis: true,
          ),
        ));
      } else {
        Get.bottomSheet(ExistingUserBottomSheet(
          userModel: response.authResponseModel!.isExistUser!, loginType: CentralizeLoginType.social.name,
          socialLogInBodyModel: googleBodyModel ?? appleBodyModel ?? facebookBodyModel, email: email, backFromThis: true,
        ));
      }
    } else if(response.isSuccess && response.authResponseModel != null && !response.authResponseModel!.isPersonalInfo!) {

      String? displayName = googleBodyModel != null ? googleBodyModel.email?.split('@')[0] : appleBodyModel != null ? appleBodyModel.email?.split('@')[0] : facebookBodyModel?.email?.split('@')[0];

      if(appleBodyModel != null) {
        email = response.authResponseModel!.email;
      }
      if(ResponsiveHelper.isDesktop(Get.context)){
        Get.back();
        Get.dialog(NewUserSetupScreen(name: displayName ?? '', loginType: CentralizeLoginType.social.name, phone: '', email: email, backFromThis: true));
      } else {
        Get.toNamed(RouteHelper.getNewUserSetupScreen(name: displayName ?? '', loginType: CentralizeLoginType.social.name, phone: '', email: email, backFromThis: true));
      }
    } else {
      Get.find<LocationController>().syncZoneData();
      // Get.back();
      // Get.find<LocationController>().navigateToLocationScreen('sign-in', offNamed: true);
    }
  }
}

class SocialLoginButton extends StatelessWidget {
  final String label;
  final String iconPath;
  final VoidCallback onTap;

  const SocialLoginButton({
    super.key, required this.label,
    required this.iconPath, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomInkWell(
      onTap: onTap,
      radius: Dimensions.radiusDefault,
      child: Container(
        height: 50, width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Image.asset(iconPath, height: 24, width: 24),
            const SizedBox(width: 8),

            Text(
              label,
              style: robotoBold,
            ),
          ],
        ),
      ),
    );
  }
}