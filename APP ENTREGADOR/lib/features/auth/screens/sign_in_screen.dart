import 'package:country_code_picker/country_code_picker.dart';
import 'package:sixam_mart_delivery/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_delivery/helper/custom_validator_helper.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/enums.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  String? _countryDialCode;
  String? _countryCode;


  @override
  void initState() {
    super.initState();
    _countryDialCode = Get.find<AuthController>().getUserCountryDialCode().isNotEmpty ? Get.find<AuthController>().getUserCountryDialCode()
        : CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;
    _countryCode = Get.find<AuthController>().getUserCountryCode().isNotEmpty ? Get.find<AuthController>().getUserCountryCode()
        : CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code;
    _phoneController.text =  Get.find<AuthController>().getUserNumber();
    _passwordController.text = Get.find<AuthController>().getUserPassword();
  }

  @override
  Widget build(BuildContext context) {

    bool isRideActive = AppConstants.appMode == AppMode.ride;
    final config = Get.find<SplashController>().configModel;
    bool isSelfRegistrationActive = isRideActive ? (config?.toggleRiderRegistration ?? false) : (config?.toggleDmRegistration ?? false);

    return Scaffold(
      body: SafeArea(child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: GetBuilder<AuthController>(builder: (authController) {

            return Column(children: [

              Image.asset(Images.logo, width: 200),
              const SizedBox(height: 50),

              Text('login'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Text('welcome_back'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.7))),
              const SizedBox(height: 40),

              CustomTextFieldWidget(
                hintText: 'xxx-xxxx-xxxx',
                labelText: 'phone_number'.tr,
                controller: _phoneController,
                focusNode: _phoneFocus,
                nextFocus: _passwordFocus,
                inputType: TextInputType.phone,
                isPhone: true,
                isRequired: true,
                onCountryChanged: (CountryCode countryCode) {
                  _countryDialCode = countryCode.dialCode;
                  _countryCode = countryCode.code;
                },
                countryDialCode: _countryCode ?? CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code,
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              CustomTextFieldWidget(
                hintText: '********',
                labelText: 'password'.tr,
                controller: _passwordController,
                focusNode: _passwordFocus,
                inputAction: TextInputAction.done,
                inputType: TextInputType.visiblePassword,
                isPassword: true,
                isRequired: true,
                onSubmit: (text) => GetPlatform.isWeb ? _login(
                  authController, _phoneController, _passwordController, _countryDialCode!, _countryCode!, context,
                ) : null,
              ),

              Row(children: [
                Expanded(
                  child: ListTile(
                    onTap: () => authController.toggleRememberMe(),
                    leading: Checkbox(
                      activeColor: Theme.of(context).primaryColor,
                      value: authController.isActiveRememberMe,
                      onChanged: (bool? isChecked) => authController.toggleRememberMe(),
                    ),
                    title: Text('remember_me'.tr),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    horizontalTitleGap: 0,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.toNamed(RouteHelper.getForgotPassRoute()),
                  child: Text('${'forgot_password'.tr}?'),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              CustomButtonWidget(
                buttonText: 'log_in'.tr,
                isLoading: authController.isLoading,
                onPressed: () => _login(authController, _phoneController, _passwordController, _countryDialCode!, _countryCode!, context),
              ),
              SizedBox(height: isSelfRegistrationActive ? Dimensions.paddingSizeSmall : 0),

              isSelfRegistrationActive ? Text('or'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)) : const SizedBox(),

              isSelfRegistrationActive ? TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(1, 40),
                ),
                onPressed: () {
                  Get.toNamed(RouteHelper.getDeliverymanRegistrationRoute());
                },
                child: RichText(text: TextSpan(children: [
                  TextSpan(text: '${'join_as_a'.tr} ', style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
                  TextSpan(text: isRideActive ? "rider".tr : 'delivery_man'.tr, style: robotoBold.copyWith(color: Theme.of(context).primaryColor, decoration: TextDecoration.underline, decorationColor: Theme.of(context).primaryColor)),
                ])),
              ) : const SizedBox(),

            ]);
          }),
        ),
      )),
    );
  }

  void _login(AuthController authController, TextEditingController phoneText, TextEditingController passText, String countryDialCode, String countryCode, BuildContext context) async {
    String phone = phoneText.text.trim();
    String password = passText.text.trim();
    String type = AppConstants.appMode == AppMode.delivery ? AppConstants.isDelivery : AppConstants.isRide;

    String numberWithCountryCode = countryDialCode + phone;
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if (phone.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    }else if (!phoneValid.isValid) {
      showCustomSnackBar('invalid_phone_number'.tr);
    }else if (password.isEmpty) {
      showCustomSnackBar('enter_password'.tr);
    }else if (password.length < 6) {
      showCustomSnackBar('password_should_be'.tr);
    }else {
      authController.login(numberWithCountryCode, password, type).then((status) async {
        if (status.isSuccess) {
          if (authController.isActiveRememberMe) {
            authController.saveUserNumberAndPassword(phone, password, countryDialCode, countryCode);
          } else {
            authController.clearUserNumberAndPassword();
          }
          await Get.find<ProfileController>().getProfile();
          Get.offAllNamed(RouteHelper.getInitialRoute());
        }else {
          showCustomSnackBar(status.message);
        }
      });
    }
  }
}
