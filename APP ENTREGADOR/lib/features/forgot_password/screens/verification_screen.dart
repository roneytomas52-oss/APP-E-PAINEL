import 'dart:async';
import 'package:sixam_mart_delivery/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_delivery/features/forgot_password/controllers/forgot_password_controller.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerificationScreen extends StatefulWidget {
  final String? number;
  final String? firebaseSession;
  const VerificationScreen({super.key, required this.number, this.firebaseSession});

  @override
  VerificationScreenState createState() => VerificationScreenState();
}

class VerificationScreenState extends State<VerificationScreen> {
  String? _number;
  Timer? _timer;
  int _seconds = 0;
  bool _isError = false;

  @override
  void initState() {
    super.initState();

    _number = widget.number!.startsWith('+') ? widget.number : '+${widget.number!.substring(1, widget.number!.length)}';
    _startTimer();
  }

  void _startTimer() {
    _seconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds = _seconds - 1;
      if(_seconds == 0) {
        timer.cancel();
        _timer?.cancel();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();

    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: CustomAppBarWidget(title: 'otp_verification'.tr),

      body: SafeArea(child: Center(child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: Center(child: SizedBox(width: 1170, child: GetBuilder<ForgotPasswordController>(builder: (forgotPasswordController) {
          return Column(children: [

            Image.asset(Images.verification, height: 150),

            Get.find<SplashController>().configModel!.demo! ? Text(
              'for_demo_purpose'.tr, style: robotoRegular,
            ) : Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeOverLarge, vertical: Dimensions.paddingSizeSmall),
              child: RichText(text: TextSpan(children: [
                TextSpan(text: 'we_have_sent_a_verification_code_to'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
                TextSpan(text: ' $_number', style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color)),
              ]), textAlign: TextAlign.center,),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 35),
              child: Column(
                children: [
                  PinCodeTextField(
                    length: 6,
                    appContext: context,
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.slide,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      fieldHeight: 60,
                      fieldWidth: 50,
                      borderWidth: 0.3,
                      activeBorderWidth: 0.5,
                      disabledBorderWidth: 0.5,
                      selectedBorderWidth: 0.5,
                      inactiveBorderWidth: 0.5,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                      selectedFillColor: Theme.of(context).cardColor,
                      inactiveFillColor: Theme.of(context).cardColor,
                      inactiveColor: Theme.of(context).disabledColor.withValues(alpha: 0.5),
                      activeColor: _isError ? Colors.red : Theme.of(context).disabledColor,
                      activeFillColor: Theme.of(context).cardColor,
                    ),
                    animationDuration: const Duration(milliseconds: 300),
                    backgroundColor: Colors.transparent,
                    enableActiveFill: true,
                    onChanged: (value) {
                      forgotPasswordController.updateVerificationCode(value);
                      setState(() {
                        _isError = false;
                      });
                    },
                    beforeTextPaste: (text) => true,
                  ),
                  if(_isError)
                    Text('incorrect_otp'.tr, style: robotoMedium.copyWith(color: Colors.red),),
                ],
              ),
            ),

            !forgotPasswordController.isLoading ? CustomButtonWidget(
              buttonText: 'verify'.tr,
              onPressed: forgotPasswordController.verificationCode.length != 6 ? null : () {
                if(widget.firebaseSession != null) {
                  forgotPasswordController.verifyFirebaseOtp(phoneNumber: _number!, session: widget.firebaseSession!, otp: forgotPasswordController.verificationCode).then((value) {
                    if(value.isSuccess) {
                      Get.toNamed(RouteHelper.getResetPasswordRoute(_number, forgotPasswordController.verificationCode, 'reset-password'));
                    }
                  });
                } else {
                  forgotPasswordController.verifyToken(_number).then((value) {
                    if(value.isSuccess) {
                      Get.toNamed(RouteHelper.getResetPasswordRoute(_number, forgotPasswordController.verificationCode, 'reset-password'));
                    }else {
                      setState(() {
                        _isError = true;
                      });
                      showCustomSnackBar(value.message);
                    }
                  });
                }
              },
            ) : const Center(child: CircularProgressIndicator()),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                Text(
                  'did_not_receive_the_code'.tr,
                  style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                ),

                !forgotPasswordController.resendOtpLoading ? TextButton(
                  onPressed: _seconds < 1 ? () async {
                    ///Firebase OTP
                    if(widget.firebaseSession != null) {
                      await forgotPasswordController.firebaseVerifyPhoneNumber(_number!, canRoute: false);
                      _startTimer();

                    } else {
                      forgotPasswordController.forgetPassword(_number).then((value) {
                        if (value.isSuccess) {
                          _startTimer();
                          showCustomSnackBar('resend_code_successful'.tr, isError: false);
                        } else {
                          showCustomSnackBar(value.message);
                        }
                      });
                    }
                  } : null,
                  child: Text('${'resend'.tr}${_seconds > 0 ? ' ($_seconds)' : ''}'),
                ) : Padding(
                  padding: const EdgeInsets.only(right: Dimensions.paddingSizeLarge),
                  child: SizedBox(
                    height: 20, width: 20,
                    child: const CircularProgressIndicator(),
                  ),
                ),

              ]),
            ),

          ]);
        }))),
      ))),
    );
  }
}
