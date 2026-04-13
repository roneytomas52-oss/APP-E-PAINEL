import 'package:sixam_mart_delivery/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart_delivery/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_delivery/features/auth/widgets/pass_view_widget.dart';
import 'package:sixam_mart_delivery/features/forgot_password/controllers/forgot_password_controller.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/profile/domain/models/profile_model.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/enums.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewPassScreen extends StatefulWidget {
  final String? resetToken;
  final String? number;
  final bool fromPasswordChange;
  const NewPassScreen({super.key, required this.resetToken, required this.number, required this.fromPasswordChange});

  @override
  State<NewPassScreen> createState() => _NewPassScreenState();
}

class _NewPassScreenState extends State<NewPassScreen> {

  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FocusNode _newPasswordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    if(Get.find<AuthController>().showPassView){
      Get.find<AuthController>().showHidePass();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: CustomAppBarWidget(title: widget.fromPasswordChange ? 'change_password'.tr : 'reset_password'.tr),

      body: GetBuilder<AuthController>(builder: (authController) {
        return Column(children: [

          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                padding: const EdgeInsets.only(
                  left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
                  top: Dimensions.paddingSizeDefault, bottom: 45,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 0, blurRadius: 5)],
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [

                  const CustomAssetImageWidget(
                    image: Images.changePasswordBgImage,
                    height: 145, width: 160,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  widget.fromPasswordChange ? SizedBox(
                    width: context.width * 0.6,
                    child: Text('please_enter_your_new_password_and_confirm_password'.tr, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.5)), textAlign: TextAlign.center),
                  ) : Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Text('number_verification_is_successful'.tr, style: robotoBold.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 5),

                    Text('please_set_your_new_password'.tr, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.5))),
                  ]),
                  const SizedBox(height: 35),

                  CustomTextFieldWidget(
                    hintText: 'new_password'.tr,
                    controller: _newPasswordController,
                    focusNode: _newPasswordFocus,
                    nextFocus: _confirmPasswordFocus,
                    inputAction: TextInputAction.done,
                    inputType: TextInputType.visiblePassword,
                    isPassword: true,
                    prefixIcon: Icons.lock,
                    showLabelText: false,
                    onChanged: (value){
                      if(value != null && value.isNotEmpty){
                        if(!authController.showPassView){
                          authController.showHidePass();
                        }
                        authController.validPassCheck(value);
                      }else{
                        if(authController.showPassView){
                          authController.showHidePass();
                        }
                      }
                    },
                  ),

                  authController.showPassView ? const Align(alignment: Alignment.centerLeft, child: PassViewWidget()) : const SizedBox(),
                  const SizedBox(height: 35),

                  CustomTextFieldWidget(
                    hintText: 'confirm_password'.tr,
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocus,
                    inputAction: TextInputAction.done,
                    inputType: TextInputType.visiblePassword,
                    prefixIcon: Icons.lock,
                    isPassword: true,
                    showLabelText: false,
                    onChanged: (String text) => setState(() {}),
                  ),

                ]),
              ),
            ),
          ),

          GetBuilder<ForgotPasswordController>(builder: (forgotPasswordController) {
            return SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeExtraLarge),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 0, blurRadius: 5)],
                ),
                child: !forgotPasswordController.isLoading ? CustomButtonWidget(
                  buttonText: 'done'.tr,
                  backgroundColor: _newPasswordController.text.trim().isEmpty || _confirmPasswordController.text.trim().isEmpty ? const Color(0xff9DA7BC).withValues(alpha: 0.7) : Theme.of(context).primaryColor,
                  onPressed: () => _newPasswordController.text.trim().isNotEmpty && _confirmPasswordController.text.trim().isNotEmpty ? _resetPassword(authController) : null,
                ) : const Center(child: CircularProgressIndicator()),

              ),
            );
          }),

        ]);
      }),
    );
  }

  void _resetPassword(AuthController authController) {
    String password = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    String type = AppConstants.appMode == AppMode.delivery ? AppConstants.isDelivery : AppConstants.isRide;

    if (password.isEmpty) {
      showCustomSnackBar('enter_password'.tr);
    }else if (password.length < 8) {
      showCustomSnackBar('password_should_be'.tr);
    }else if(password != confirmPassword) {
      showCustomSnackBar('password_does_not_matched'.tr);
    }else if(!authController.spatialCheck || !authController.lowercaseCheck || !authController.uppercaseCheck || !authController.numberCheck || !authController.lengthCheck){
      showCustomSnackBar('provide_valid_password'.tr);
    }else {
      if(widget.fromPasswordChange) {
        ProfileModel user = Get.find<ProfileController>().profileModel!;
        Get.find<ForgotPasswordController>().changePassword(user, password);
      }else {
        Get.find<ForgotPasswordController>().resetPassword(widget.resetToken, '+${widget.number!.trim()}', password, confirmPassword).then((value) {
          if (value.isSuccess) {
            Get.find<AuthController>().login('+${widget.number!.trim()}', password, type).then((value) async {
              Get.offAllNamed(RouteHelper.getInitialRoute());
            });
          } else {
            showCustomSnackBar(value.message);
          }
        });
      }
    }
  }
}
