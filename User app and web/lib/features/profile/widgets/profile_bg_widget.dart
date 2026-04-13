import 'package:sixam_mart/common/widgets/confirmation_dialog.dart';
import 'package:sixam_mart/common/widgets/custom_popup_menu_button.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileBgWidget extends StatelessWidget {
  final Widget circularImage;
  final Widget mainWidget;
  final bool backButton;
  const ProfileBgWidget({super.key, required this.mainWidget, required this.circularImage, required this.backButton});

  @override
  Widget build(BuildContext context) {
    final List<MenuItem> items = [
      MenuItem('delete_account'.tr, Icons.delete_forever_rounded, 1, Colors.red),
    ];
    return Column(children: [

      Stack(clipBehavior: Clip.none, children: [

        Container(
          width: 1170, height: 260,
          color: Theme.of(context).primaryColor,
        ),

        SizedBox(
          width: context.width, height: 260,
          child: Center(child: Image.asset(Images.profileBg, height: 260, width: 1170, fit: BoxFit.fill)),
        ),

        Positioned(
          top: 200, left: 0, right: 0, bottom: 0,
          child: Center(
            child: Container(
              width: 1170,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
                color: Theme.of(context).cardColor,
              ),
            ),
          ),
        ),

        Positioned(
          top: MediaQuery.of(context).padding.top+10, left: 0, right: 0,
          child: Text(
            'update_profile'.tr, textAlign: TextAlign.center,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600, color: Theme.of(context).cardColor),
          ),
        ),

        backButton ? Positioned(
          top: MediaQuery.of(context).padding.top, left: 10,
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).cardColor, size: 20),
            onPressed: () => Get.back(),
          ),
        ) : const SizedBox(),

        Positioned(
          top: MediaQuery.of(context).padding.top, right: 10,
          child: AuthHelper.isLoggedIn() ? CustomPopupMenuButton(
            items: items,
            onSelected: (int value) {
              if(value == 1) {
                Get.dialog(ConfirmationDialog(icon: Images.support,
                  title: 'are_you_sure_to_delete_account'.tr,
                  description: 'it_will_remove_your_all_information'.tr, isLogOut: true,
                  onYesPressed: () => Get.find<ProfileController>().deleteUser(),
                ), useSafeArea: false);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 2),
              child: Icon(Icons.more_vert_sharp, color: Theme.of(context).cardColor),
            ),
          ) : const SizedBox(),
        ),

        Positioned(
          top: 150, left: 0, right: 0,
          child: circularImage,
        ),

      ]),

      Expanded(
        child: mainWidget,
      ),

    ]);
  }
}
