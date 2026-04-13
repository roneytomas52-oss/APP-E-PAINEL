import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/language/widgets/language_bottom_sheet_widget.dart';
import 'package:sixam_mart/features/profile/widgets/notification_status_change_bottom_sheet.dart';
import 'package:sixam_mart/features/profile/widgets/profile_button_widget.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return Scaffold(
      appBar: CustomAppBar(title: 'settings'.tr),
      endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
      key: UniqueKey(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(children: [

          ProfileButtonWidget(icon: Icons.language, title: 'language'.tr, languageName: AppConstants.languages[Get.find<LocalizationController>().selectedLanguageIndex].languageName, onTap: () {
            _manageLanguageFunctionality();
          }),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          GetBuilder<ThemeController>(
            builder: (themeController) {
              return ProfileButtonWidget(icon: Icons.tonality_outlined, title: 'dark_mode'.tr, isButtonActive: themeController.darkTheme, onTap: () {
                themeController.toggleTheme();
              });
            }
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          isLoggedIn ? GetBuilder<AuthController>(builder: (authController) {
            return ProfileButtonWidget(
              icon: Icons.notifications, title: 'notification'.tr,
              isButtonActive: authController.notification,
              onTap: () {
                Get.bottomSheet(const NotificationStatusChangeBottomSheet());
              },
            );
          }) : const SizedBox(),
          SizedBox(height: isLoggedIn ? Dimensions.paddingSizeSmall : 0),

          SizedBox(height: isLoggedIn ? Dimensions.paddingSizeLarge : 0),

          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('${'version'.tr}:', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Text(AppConstants.appVersion.toStringAsFixed(1), style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
          ]),

        ]),
      ),
    );
  }

  void _manageLanguageFunctionality() {
    Get.find<LocalizationController>().saveCacheLanguage(null);
    Get.find<LocalizationController>().searchSelectedLanguage();

    showModalBottomSheet(
      isScrollControlled: true, useRootNavigator: true, context: Get.context!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: const LanguageBottomSheetWidget(),
        );
      },
    ).then((value) => Get.find<LocalizationController>().setLanguage(Get.find<LocalizationController>().getCacheLocaleFromSharedPref()));
  }
}
