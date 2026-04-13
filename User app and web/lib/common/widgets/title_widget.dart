import 'package:get/get.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';

class TitleWidget extends StatelessWidget {
  final String title;
  final Function? onTap;
  final String? image;
  final double? titleFontSize;
  final double? seeAllFontSize;
  final bool seeAllUnderline;
  const TitleWidget({super.key, required this.title, this.onTap, this.image, this.titleFontSize, this.seeAllFontSize, this.seeAllUnderline=true});

  @override
  Widget build(BuildContext context) {

    final bool ltr = Get.find<LocalizationController>().isLtr;

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [
        Text(title, style: robotoBold.copyWith(fontSize: ResponsiveHelper.isDesktop(context) ? (titleFontSize ?? Dimensions.fontSizeLarge) : (titleFontSize ?? Dimensions.fontSizeLarge))),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        image != null ? Image.asset(image!, height: 20, width: 20) : const SizedBox(),
      ],
      ),
      (onTap != null) ? InkWell(
        onTap: onTap as void Function()?,
        child: Padding(
          padding: EdgeInsets.fromLTRB(ltr ? 10 : 0, 5, ltr ? 0 : 10, 5),
          child: Text(
            'see_all'.tr,
            style: robotoMedium.copyWith(fontSize: (seeAllFontSize ?? Dimensions.fontSizeSmall), color: Theme.of(context).primaryColor, decoration: seeAllUnderline ? TextDecoration.underline : TextDecoration.none),
          ),
        ),
      ) : const SizedBox(),
    ]);
  }
}
