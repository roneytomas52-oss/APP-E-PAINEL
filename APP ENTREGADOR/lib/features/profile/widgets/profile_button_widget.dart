import 'package:flutter/cupertino.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileButtonWidget extends StatelessWidget {
  final IconData? icon;
  final String? iconImage;
  final String title;
  final bool? isButtonActive;
  final Function onTap;
  const ProfileButtonWidget({
    super.key, this.icon, required this.title, required this.onTap,
    this.isButtonActive, this.iconImage,
  }) : assert (icon != null || iconImage != null, 'Either icon or iconImage must be provided');

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall,
          vertical: isButtonActive != null ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeDefault,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 850 : 200]!, spreadRadius: 1, blurRadius: 5)],
        ),
        child: Row(children: [

          iconImage != null ? Image.asset(
            iconImage!,
            height: 25, width: 25,
            color: Theme.of(context).disabledColor,
          ) : Icon(icon, size: 25, color: Theme.of(context).disabledColor),

          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(child: Text(title, style: robotoRegular)),

          isButtonActive != null ? Transform.scale(
            scale: 0.7,
            child: CupertinoSwitch(
              value: isButtonActive!,
              onChanged: (bool? value) => onTap(),
              activeTrackColor: Theme.of(context).primaryColor,
              inactiveTrackColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
            ),
          ) : const SizedBox(),

        ]),
      ),
    );
  }
}
