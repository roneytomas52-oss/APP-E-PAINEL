import 'package:sixam_mart/features/auth/widgets/auth_dialog_widget.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/profile/domain/models/userinfo_model.dart';
import 'package:sixam_mart/features/verification/controllers/verification_controller.dart';
import 'package:sixam_mart/helper/validate_check.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/styles.dart';

class NewPassScreen extends StatefulWidget {
  final String? resetToken;
  final String? number;
  final String? email;
  final bool fromPasswordChange;
  final bool fromDialog;
  const NewPassScreen({super.key, required this.resetToken, this.number, required this.fromPasswordChange, this.fromDialog = false, this.email});

  @override
  State<NewPassScreen> createState() => _NewPassScreenState();
}

class _NewPassScreenState extends State<NewPassScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FocusNode _newPasswordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ResponsiveHelper.isDesktop(context) ? Colors.transparent : Theme.of(context).cardColor,
      appBar:  widget.fromDialog ? null : CustomAppBar(title: widget.fromPasswordChange ? 'change_password'.tr : 'reset_password'.tr),
      body:  SafeArea(child: Center(child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: Center(child: Container(
          height: widget.fromDialog ? 516 : null,
          width: widget.fromDialog ? 475 : context.width > 700 ? 700 : context.width,
          //padding: widget.fromDialog ? const EdgeInsets.all(Dimensions.paddingSizeExtremeLarge) : context.width > 700 ? const EdgeInsets.all(Dimensions.paddingSizeDefault) : null,
          margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: context.width > 700 ? BoxDecoration(
            color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            boxShadow: widget.fromDialog ? null : [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, blurRadius: 5, spreadRadius: 1)],
          ) : null,
          child: Column(
            children: [
              SizedBox(height: Dimensions.paddingSizeExtraSmall),
              ResponsiveHelper.isDesktop(context) ? Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.clear),
                ),
              ) : const SizedBox(),

              Padding(
                padding: widget.fromDialog ? const EdgeInsets.all(Dimensions.paddingSizeExtremeLarge) : context.width > 700 ? const EdgeInsets.all(Dimensions.paddingSizeDefault) : const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: Column(children: [
                  Image.asset(Images.changePass, height: 170, width: 170),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Text('enter_new_password'.tr, style: robotoRegular.copyWith(), textAlign: TextAlign.center),

                  const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),

                  CustomTextField(
                    titleText: '8+characters'.tr,
                    controller: _newPasswordController,
                    focusNode: _newPasswordFocus,
                    nextFocus: _confirmPasswordFocus,
                    inputType: TextInputType.visiblePassword,
                    prefixIcon: Icons.lock,
                    isPassword: true,
                    divider: false,
                    labelText: 'new_password'.tr,
                    validator: (value) => ValidateCheck.validateEmptyText(value, 'please_enter_new_password'.tr),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  CustomTextField(
                    titleText: '8+characters'.tr,
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocus,
                    inputAction: TextInputAction.done,
                    inputType: TextInputType.visiblePassword,
                    prefixIcon: Icons.lock,
                    isPassword: true,
                    onSubmit: (text) => GetPlatform.isWeb ? _onPressedPasswordChange() : null,
                    labelText: 'confirm_password'.tr,
                    validator: (value) => ValidateCheck.validateEmptyText(value, 'please_enter_confirm_password'.tr),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),

                  GetBuilder<ProfileController>(builder: (profileController) {
                    return GetBuilder<VerificationController>(builder: (verificationController) {
                      return CustomButton(
                        radius: Dimensions.radiusDefault,
                        buttonText: 'change_password'.tr,
                        isLoading: widget.fromPasswordChange ? profileController.isLoading : verificationController.isLoading,
                        onPressed: () => _onPressedPasswordChange(),
                      );
                    });
                  }),

                ]),
              )
            ],
          ),
        )),
      ))),
    );
  }

  void _onPressedPasswordChange() {
    String password = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    if (password.isEmpty) {
      showCustomSnackBar('enter_password'.tr);
    }else if (password.length < 6) {
      showCustomSnackBar('password_should_be'.tr);
    }else if(password != confirmPassword) {
      showCustomSnackBar('confirm_password_does_not_matched'.tr);
    }else {
      if(widget.fromPasswordChange) {
        _changeUserPassword(password);
      }else {
        _resetUserPassword(password, confirmPassword);
      }
    }
  }

  void _changeUserPassword(String password) {
    UserInfoModel user = Get.find<ProfileController>().userInfoModel!;
    user.password = password;
    Get.find<ProfileController>().changePassword(user).then((response) {
      if(response.isSuccess) {
        Get.back();
        showCustomSnackBar('password_updated_successfully'.tr, isError: false);
      }else {
        showCustomSnackBar(response.message);
      }
    });
  }

  void _resetUserPassword(String password, String confirmPassword) {
    String? number = '';
    if(widget.number != null && widget.number != 'null' && widget.number!.isNotEmpty) {
      number = widget.number!.startsWith('+') ? widget.number : '+${widget.number!.substring(1, widget.number!.length)}';
    }
    Get.find<VerificationController>().resetPassword(resetToken: widget.resetToken, phone: number, email: widget.email, password: password, confirmPassword: confirmPassword).then((value) {
      if (value.isSuccess) {
        if(!ResponsiveHelper.isDesktop(Get.context)) {
          Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.resetPassword));
        }else{
          Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: false))?.then((value) {
            Get.dialog(const Center(child: AuthDialogWidget(exitFromApp: true, backFromThis: false)));
          });
        }
        showCustomSnackBar('password_reset_successfully'.tr, isError: false);
      } else {
        showCustomSnackBar(value.message);
      }
    });
  }
}