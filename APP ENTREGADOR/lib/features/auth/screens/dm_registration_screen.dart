import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_drop_down_button.dart';
import 'package:sixam_mart_delivery/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_delivery/features/address/controllers/address_controller.dart';
import 'package:sixam_mart_delivery/features/language/controllers/language_controller.dart';
import 'package:sixam_mart_delivery/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_delivery/features/auth/domain/models/delivery_man_body_model.dart';
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
import 'package:sixam_mart_delivery/features/auth/widgets/pass_view_widget.dart';

class DmRegistrationScreen extends StatefulWidget {
  const DmRegistrationScreen({super.key});

  @override
  State<DmRegistrationScreen> createState() => _DmRegistrationScreenState();
}

class _DmRegistrationScreenState extends State<DmRegistrationScreen> {

  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _referTextController = TextEditingController();
  final TextEditingController _identityNumberController = TextEditingController();

  final FocusNode _fNameNode = FocusNode();
  final FocusNode _lNameNode = FocusNode();
  final FocusNode _emailNode = FocusNode();
  final FocusNode _phoneNode = FocusNode();
  final FocusNode _passwordNode = FocusNode();
  final FocusNode _confirmPasswordNode = FocusNode();
  final FocusNode _identityNumberNode = FocusNode();

  String? _countryDialCode;
  bool isRideActive = AppConstants.appMode == AppMode.ride;

  @override
  void initState() {
    super.initState();
    _countryDialCode = CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;
    Get.find<AuthController>().resetDmRegistrationData();
    Get.find<AddressController>().resetSelectedDeliveryZone();
    Get.find<AddressController>().getZoneList();
    Get.find<AuthController>().getVehicleList();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async{
        if(Get.find<AuthController>().dmStatus != 0.4 && !didPop) {
          Get.find<AuthController>().dmStatusChange(0.4);
        }else{
          Future.delayed(const Duration(milliseconds: 0), () {
            Get.offAllNamed(RouteHelper.getSignInRoute());
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isRideActive ? "rider_registration".tr : 'delivery_man_registration'.tr,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge!.color),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: Theme.of(context).textTheme.bodyLarge!.color,
            onPressed: () async {
              if(Get.find<AuthController>().dmStatus != 0.4){
                Get.find<AuthController>().dmStatusChange(0.4);
              }else{
                Get.back();
              }
            },
          ),
          backgroundColor: Theme.of(context).cardColor,
          surfaceTintColor: Theme.of(context).cardColor,
          shadowColor: Theme.of(context).disabledColor.withValues(alpha: 0.5),
          elevation: 2,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            child: GetBuilder<AuthController>(builder: (authController) {
              return Container(
                margin: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
                height: 4,
                child: Row(spacing: Dimensions.paddingSizeSmall, children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      color: authController.dmStatus == 0.4 ? Theme.of(context).primaryColor.withValues(alpha: 0.5) : Theme.of(context).primaryColor,
                    ),
                  ),

                  Expanded(
                    child: Container(
                      height: 4,
                      color: authController.dmStatus != 0.4 ? Theme.of(context).primaryColor.withValues(alpha: 0.5) :  authController.dmStatus != 0.4 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.5),
                    ),
                  ),
                ]),
              );
            }),
          ),
        ),

        body: GetBuilder<AuthController>(builder: (authController) {
          return GetBuilder<AddressController>(builder: (addressController) {

            var config = Get.find<SplashController>().configModel;
            bool isRiderReferralActive = config?.riderReferralData?.referalStatus ?? false;
            bool isDmReferralActive = config?.dmReferralData?.referalStatus ?? false;

            return Column(children: [
              Expanded(child: SingleChildScrollView(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Visibility(
                    visible: authController.dmStatus == 0.4,
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Text('basic_information'.tr, style: robotoBold),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      CustomCard(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        child: Column(children: [
                          CustomTextFieldWidget(
                            labelText: 'first_name'.tr,
                            hintText: 'ex_jhon'.tr,
                            isRequired: true,
                            controller: _fNameController,
                            capitalization: TextCapitalization.words,
                            inputType: TextInputType.name,
                            focusNode: _fNameNode,
                            nextFocus: _lNameNode,
                          ),
                          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                          CustomTextFieldWidget(
                            labelText: 'last_name'.tr,
                            hintText: 'ex_doe'.tr,
                            isRequired: true,
                            controller: _lNameController,
                            capitalization: TextCapitalization.words,
                            inputType: TextInputType.name,
                            focusNode: _lNameNode,
                            nextFocus: _emailNode,
                          ),
                          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                          CustomTextFieldWidget(
                            labelText: 'email'.tr,
                            hintText: 'enter_email'.tr,
                            controller: _emailController,
                            focusNode: _emailNode,
                            nextFocus: _phoneNode,
                            isRequired: true,
                            inputType: TextInputType.emailAddress,
                          ),
                        ]),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      Text('account_information'.tr, style: robotoBold),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      CustomCard(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        child: Column(children: [
                          CustomTextFieldWidget(
                            labelText: 'phone'.tr,
                            hintText: 'xxx-xxx-xxxxx'.tr,
                            isRequired: true,
                            controller: _phoneController,
                            focusNode: _phoneNode,
                            nextFocus: _passwordNode,
                            inputType: TextInputType.phone,
                            isPhone: true,
                            onCountryChanged: (CountryCode countryCode) {
                              _countryDialCode = countryCode.dialCode;
                            },
                            countryDialCode: _countryDialCode != null ? CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code
                                : Get.find<LocalizationController>().locale.countryCode,
                          ),
                          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                          CustomTextFieldWidget(
                            labelText: 'password'.tr,
                            hintText: 'eight_characters'.tr,
                            isRequired: true,
                            controller: _passwordController,
                            focusNode: _passwordNode,
                            nextFocus: _confirmPasswordNode,
                            inputType: TextInputType.visiblePassword,
                            isPassword: true,
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
                          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                          CustomTextFieldWidget(
                            labelText: 'confirm_password'.tr,
                            hintText: 're_enter_your_password'.tr,
                            isRequired: true,
                            controller: _confirmPasswordController,
                            focusNode: _confirmPasswordNode,
                            inputAction: TextInputAction.done,
                            inputType: TextInputType.visiblePassword,
                            isPassword: true,
                          ),
                        ]),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      CustomCard(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                          RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                text: 'profile_picture'.tr,
                                style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color),
                              ),
                              TextSpan(
                                text: '*',
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.red),
                              ),
                            ]),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                          Text('image_format_and_ratio_for_profile'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          Align(alignment: Alignment.center, child: Stack(children: [

                            Padding(
                              padding: const EdgeInsets.all(2),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                child: authController.pickedImage != null ? GetPlatform.isWeb ? Image.network(
                                  authController.pickedImage!.path, width: 120, height: 120, fit: BoxFit.cover,
                                ) : Image.file(
                                  File(authController.pickedImage!.path), width: 120, height: 120, fit: BoxFit.cover,
                                ) : SizedBox(
                                  width: 120, height: 120,
                                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                                    CustomAssetImageWidget(image: Images.pictureIcon, height: 30, width: 30, color: Theme.of(context).disabledColor),
                                    const SizedBox(height: Dimensions.paddingSizeSmall),

                                    Text(
                                      'click_to_add'.tr,
                                      style: robotoMedium.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall), textAlign: TextAlign.center,
                                    ),

                                  ]),
                                ),
                              ),
                            ),

                            Positioned(
                              bottom: 0, right: 0, top: 0, left: 0,
                              child: InkWell(
                                onTap: () => authController.pickDmImageForRegistration(true, false),
                                child: DottedBorder(
                                  options: RoundedRectDottedBorderOptions(
                                    color: Theme.of(context).disabledColor,
                                    strokeWidth: 1,
                                    strokeCap: StrokeCap.butt,
                                    dashPattern: const [5, 5],
                                    padding: const EdgeInsets.all(0),
                                    radius: const Radius.circular(Dimensions.radiusDefault),
                                  ),
                                  child: const SizedBox(width: 120, height: 120),
                                ),
                              ),
                            ),

                          ])),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                        ]),
                      ),

                    ]),
                  ),

                  Visibility(
                    visible: authController.dmStatus != 0.4,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Text('setup'.tr, style: robotoBold),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      CustomCard(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        child: Column(children: [

                          addressController.zoneList != null ? Stack(clipBehavior: Clip.none, children: [
                            CustomDropdownButton(
                              hintText: 'select_delivery_zone'.tr,
                              dropdownMenuItems: addressController.zoneList!.map((zone) => DropdownMenuItem<String>(
                                value: zone.id.toString(),
                                child: Text(zone.name ?? '', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeDefault)),
                              )).toList(),
                              selectedValue: addressController.selectedDeliveryZoneId,
                              onChanged: (value) {
                                addressController.setSelectedDeliveryZone(zoneId: value);
                              },
                            ),

                            Positioned(
                              left: 10, top: -10,
                              child: Container(
                                color: Theme.of(context).cardColor,
                                padding: const EdgeInsets.all(2),
                                child: Row(children: [
                                  Text('select_delivery_zone'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor)),
                                  Text(' *', style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error)),
                                ]),
                              ),
                            ),
                          ]) : ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            child: Shimmer(
                              child: Container(height: 50, color: Theme.of(context).shadowColor),
                            ),
                          ),

                          SizedBox(height: isRideActive ? 0: Dimensions.paddingSizeExtraLarge),

                          isRideActive ? SizedBox() : authController.vehicleIds != null ? Stack(clipBehavior: Clip.none, children: [
                            CustomDropdownButton(
                              hintText: 'select_vehicle_type'.tr,
                              dropdownMenuItems: authController.vehicles!.map((vehicle) => DropdownMenuItem<String>(
                                value: vehicle.id.toString(),
                                child: Text(vehicle.type ?? '', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeDefault)),
                              )).toList(),
                              selectedValue: authController.selectedVehicleId,
                              onChanged: (value) {
                                authController.setSelectedVehicleType(vehicleId: value);
                              },
                            ),

                            Positioned(
                              left: 10, top: -10,
                              child: Container(
                                color: Theme.of(context).cardColor,
                                padding: const EdgeInsets.all(2),
                                child: Row(children: [
                                  Text('select_vehicle_type'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor)),
                                  Text(' *', style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error)),
                                ]),
                              ),
                            ),
                          ]) : ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            child: Shimmer(
                              child: Container(height: 50, color: Theme.of(context).shadowColor),
                            ),
                          ),

                          if(!isRideActive) Padding(
                            padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraLarge),
                            child: Stack(clipBehavior: Clip.none, children: [
                              CustomDropdownButton(
                                hintText: 'select_delivery_type'.tr,
                                items: authController.dmTypeList,
                                selectedValue: authController.selectedDmType,
                                onChanged: (value) {
                                  authController.setSelectedDmType(value);
                                },
                              ),

                              Positioned(
                                left: 10, top: -10,
                                child: Container(
                                  color: Theme.of(context).cardColor,
                                  padding: const EdgeInsets.all(2),
                                  child: Row(children: [
                                    Text('select_delivery_type'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor)),
                                    Text(' *', style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error)),
                                  ]),
                                ),
                              ),
                            ]),
                          ),


                          ((isRideActive && isRiderReferralActive) || ( !isRideActive && isDmReferralActive && authController.selectedDmType == 'freelancer')) ? Padding(
                            padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraLarge),
                            child: CustomTextFieldWidget(
                              hintText: 'Ex: SPECIAL2025',
                              labelText: 'referral_code'.tr,
                              controller: _referTextController,
                              inputAction: TextInputAction.done,
                            ),
                          ) : const SizedBox(),

                        ]),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      Text('identity_information'.tr, style: robotoBold),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      CustomCard(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        child: Column(children: [

                          Stack(clipBehavior: Clip.none, children: [
                            CustomDropdownButton(
                              hintText: 'select_identity_type'.tr,
                              items: authController.identityTypeList,
                              selectedValue: authController.selectedIdentityType,
                              onChanged: (value) {
                                authController.setSelectedIdentityType(value);
                              },
                            ),

                            Positioned(
                              left: 10, top: -10,
                              child: Container(
                                color: Theme.of(context).cardColor,
                                padding: const EdgeInsets.all(2),
                                child: Row(children: [
                                  Text('select_identity_type'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor)),
                                  Text(' *', style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error)),
                                ]),
                              ),
                            ),
                          ]),
                          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                          CustomTextFieldWidget(
                            hintText: 'Ex: xxx-xxxx-xxxxx',
                            labelText: authController.selectedIdentityType != null ? '${authController.selectedIdentityType?.tr} ${'number'.tr}' : 'identity_number'.tr,
                            controller: _identityNumberController,
                            focusNode: _identityNumberNode,
                            inputAction: TextInputAction.done,
                            isRequired: true,
                          ),
                        ]),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      CustomCard(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                          RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                text: 'identity_image'.tr,
                                style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color),
                              ),
                              TextSpan(
                                text: '*',
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.red),
                              ),
                            ]),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                          Text('image_format_and_ratio_for_profile'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          Center(
                            child: SizedBox(
                              width: 180,
                              child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1, mainAxisExtent: 130,
                                  mainAxisSpacing: 10, crossAxisSpacing: 10,
                                ),
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: authController.pickedIdentities.length + 1,
                                itemBuilder: (context, index) {

                                  XFile? file = index == authController.pickedIdentities.length ? null : authController.pickedIdentities[index];

                                  if(index == authController.pickedIdentities.length) {
                                    return InkWell(
                                      onTap: () {
                                        if((authController.pickedIdentities.length) < 6) {
                                          authController.pickDmImageForRegistration(false, false);
                                        }else {
                                          showCustomSnackBar('maximum_image_limit_is_6'.tr);
                                        }
                                      },
                                      child: DottedBorder(
                                        options: RoundedRectDottedBorderOptions(
                                          radius: const Radius.circular(Dimensions.radiusDefault),
                                          dashPattern: const [8, 4],
                                          strokeWidth: 1,
                                          color: Get.isDarkMode ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFE5E5E5),
                                        ),
                                        child: Container(
                                          height: 130, width: 180,
                                          decoration: BoxDecoration(
                                            color: Get.isDarkMode ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFFAFAFA),
                                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                          ),
                                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                                            CustomAssetImageWidget(image: Images.pictureIcon, height: 40, width: 40, color: Get.isDarkMode ? Colors.grey : null),
                                            const SizedBox(height: Dimensions.paddingSizeDefault),

                                            RichText(
                                              textAlign: TextAlign.center,
                                              text: TextSpan(children: [
                                                TextSpan(text: 'upload_identity_image'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
                                              ]),
                                            ),

                                          ]),
                                        ),
                                      ),
                                    );
                                  }
                                  return DottedBorder(
                                    options: RoundedRectDottedBorderOptions(
                                      radius: const Radius.circular(Dimensions.radiusDefault),
                                      dashPattern: const [8, 5],
                                      strokeWidth: 1,
                                      color: const Color(0xFFE5E5E5),
                                    ),
                                    child: SizedBox(
                                      width: 180,
                                      child: Stack(children: [

                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                          child: GetPlatform.isWeb ? Image.network(
                                            file!.path, height: 130, width: 180, fit: BoxFit.cover,
                                          ) : Image.file(
                                            File(file!.path), height: 130, width: 180, fit: BoxFit.cover,
                                          ),
                                        ),

                                        Positioned(
                                          right: 0, top: 0,
                                          child: InkWell(
                                            onTap: () {
                                              authController.removeIdentityImage(index);
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                                              child: Icon(Icons.delete_forever, color: Colors.red),
                                            ),
                                          ),
                                        ),

                                      ]),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                        ]),
                      ),

                    ]),
                  ),

                ]),
              )),

              Container(
               padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
               decoration: BoxDecoration(
                 color: Theme.of(context).cardColor,
                 boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
               ),
               child: CustomButtonWidget(
                buttonText: authController.dmStatus == 0.4 ? 'next'.tr : 'submit'.tr,
                isLoading: authController.isLoading,
                onPressed: !authController.acceptTerms ? null : () async {

                  String fName = _fNameController.text.trim();
                  String lName = _lNameController.text.trim();
                  String email = _emailController.text.trim();
                  String phone = _phoneController.text.trim();
                  String password = _passwordController.text.trim();
                  String confirmPass = _confirmPasswordController.text.trim();
                  String identityNumber = _identityNumberController.text.trim();

                  String numberWithCountryCode = _countryDialCode! + phone;
                  PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
                  numberWithCountryCode = phoneValid.phone;

                  String type = AppConstants.appMode == AppMode.delivery ? AppConstants.isDelivery : AppConstants.isRide;

                  if(authController.dmStatus == 0.4){
                    if(fName.isEmpty) {
                      showCustomSnackBar('enter_delivery_man_first_name'.tr);
                    }else if(lName.isEmpty) {
                      showCustomSnackBar('enter_delivery_man_last_name'.tr);
                    }else if(email.isEmpty) {
                      showCustomSnackBar('enter_delivery_man_email_address'.tr);
                    }else if(!GetUtils.isEmail(email)) {
                      showCustomSnackBar('enter_a_valid_email_address'.tr);
                    }else if(phone.isEmpty) {
                      showCustomSnackBar('enter_delivery_man_phone_number'.tr);
                    }else if(!phoneValid.isValid) {
                      showCustomSnackBar('enter_a_valid_phone_number'.tr);
                    }else if(password.isEmpty) {
                      showCustomSnackBar('enter_password_for_delivery_man'.tr);
                    }else if(!authController.spatialCheck || !authController.lowercaseCheck || !authController.uppercaseCheck || !authController.numberCheck || !authController.lengthCheck) {
                      showCustomSnackBar('provide_valid_password'.tr);
                    }else if(password != confirmPass) {
                      showCustomSnackBar('password_does_not_matched'.tr);
                    }else if(authController.pickedImage == null) {
                      showCustomSnackBar('pick_delivery_man_profile_image'.tr);
                    }else {
                      authController.dmStatusChange(0.8);
                    }
                  }else{
                    if(authController.selectedDmTypeId == null && !isRideActive) {
                      showCustomSnackBar('select_delivery_type'.tr);
                    }else if(addressController.selectedDeliveryZoneId == null){
                      showCustomSnackBar('select_delivery_zone'.tr);
                    }else if(authController.selectedVehicleId == null && !isRideActive){
                      showCustomSnackBar('select_vehicle_type'.tr);
                    }else if(authController.selectedIdentityType == null){
                      showCustomSnackBar('select_identity_type'.tr);
                    }else if(identityNumber.isEmpty) {
                      showCustomSnackBar('enter_delivery_man_identity_number'.tr);
                    }else if(authController.pickedIdentities.isEmpty) {
                      showCustomSnackBar('please_upload_identity_image'.tr);
                    }else {
                      String earningType = isRideActive ? '1' : authController.selectedDmTypeId!;

                      authController.registerDeliveryMan(DeliveryManBodyModel(
                        fName: fName, lName: lName, password: password, phone: numberWithCountryCode, email: email,
                        identityNumber: identityNumber, identityType: authController.selectedIdentityType,
                        earning: earningType, zoneId: addressController.selectedDeliveryZoneId,
                        vehicleId: authController.selectedVehicleId, referCode: _referTextController.text,
                        type: type
                      ));
                    }
                  }
                },
               ),
              ),

            ]);
          });
        }),
      ),
    );
  }
}