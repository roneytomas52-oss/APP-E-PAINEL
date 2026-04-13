import 'package:country_code_picker/country_code_picker.dart';
import 'package:sixam_mart_delivery/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_delivery/features/forgot_password/controllers/forgot_password_controller.dart';
import 'package:sixam_mart_delivery/helper/custom_validator_helper.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPassScreen extends StatefulWidget {
  const ForgetPassScreen({super.key});

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen> {
  final TextEditingController _numberController = TextEditingController();
  String? _countryDialCode = CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;
  String? _countryCode = CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: CustomAppBarWidget(title: 'forgot_password'.tr),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(children: [

            Image.asset(Images.forgot, height: 220),

            Padding(
              padding: const EdgeInsets.all(30),
              child: Text('please_enter_mobile'.tr, style: robotoRegular, textAlign: TextAlign.center),
            ),

            CustomTextFieldWidget(
              hintText: 'xxx-xxxx-xxxx',
              labelText: 'phone_number'.tr,
              controller: _numberController,
              inputType: TextInputType.phone,
              inputAction: TextInputAction.done,
              isPhone: true,
              isRequired: true,
              onCountryChanged: (CountryCode countryCode) {
                _countryDialCode = countryCode.dialCode;
                _countryCode = countryCode.code;
              },
              countryDialCode: _countryCode ?? CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code,
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),

            GetBuilder<ForgotPasswordController>(builder: (forgotPasswordController) {
              return !forgotPasswordController.isLoading ? CustomButtonWidget(
                buttonText: 'next'.tr,
                onPressed: () => _forgetPass(_countryDialCode!),
              ) : const Center(child: CircularProgressIndicator());
            }),

          ]),
        ),
      ),
    );
  }

  void _forgetPass(String countryCode) async {
    String phone = _numberController.text.trim();

    String numberWithCountryCode = countryCode+phone;
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if (phone.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    }else if (!phoneValid.isValid) {
      showCustomSnackBar('invalid_phone_number'.tr);
    }else {
      Get.find<ForgotPasswordController>().forgetPassword(numberWithCountryCode).then((status) async {
        if (status.isSuccess) {
          if(Get.find<SplashController>().configModel!.firebaseOtpVerification!) {
            Get.find<ForgotPasswordController>().firebaseVerifyPhoneNumber(numberWithCountryCode);
          } else {
            Get.toNamed(RouteHelper.getVerificationRoute(numberWithCountryCode));
          }
        }else {
          showCustomSnackBar(status.message);
        }
      });
    }
  }
}