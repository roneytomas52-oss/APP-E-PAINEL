import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:flutter/material.dart';

final robotoRegular = TextStyle(
  fontFamily: AppConstants.fontFamily,
  fontWeight: FontWeight.w400,
  fontSize: Dimensions.fontSizeDefault,
);

final robotoMedium = TextStyle(
  fontFamily: AppConstants.fontFamily,
  fontWeight: FontWeight.w500,
  fontSize: Dimensions.fontSizeDefault,
);

final robotoSemiBold = TextStyle(
  fontFamily: AppConstants.fontFamily,
  fontWeight: FontWeight.w600,
  fontSize: Dimensions.fontSizeDefault,
);

final robotoBold = TextStyle(
  fontFamily: AppConstants.fontFamily,
  fontWeight: FontWeight.w700,
  fontSize: Dimensions.fontSizeDefault,
);

final robotoBlack = TextStyle(
  fontFamily: AppConstants.fontFamily,
  fontWeight: FontWeight.w900,
  fontSize: Dimensions.fontSizeDefault,
);

final BoxDecoration riderContainerDecoration = BoxDecoration(
  borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
  color: Theme.of(Get.context!).primaryColor.withValues(alpha: 0.1), shape: BoxShape.rectangle,
);

List<BoxShadow>? searchBoxShadow =  [const BoxShadow(
    offset: Offset(0,3),
    color: Color(0x208F94FB), blurRadius: 5, spreadRadius: 2)];

List<BoxShadow> cardShadow = [ const BoxShadow(
  offset: Offset(0,2),
  spreadRadius: 2,
  blurRadius: 2,
  color: Color(0x20A8A8EA),
)];


List<BoxShadow>? lightShadow = Get.isDarkMode? [ const BoxShadow()]:[
  const BoxShadow(
    offset: Offset(0, 1),
    blurRadius: 3,
    spreadRadius: 1,
    color: Color(0x20D6D8E6),
  )];

List<BoxShadow>? shadow = Get.find<ThemeController>().darkTheme ? [const BoxShadow()] : [BoxShadow(
    offset: const Offset(0,3),
    color: Colors.grey[100]!, blurRadius: 1, spreadRadius: 2)];

Decoration shimmerDecorationGreySoft = BoxDecoration(
  color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300],
  borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
);

Decoration shimmerDecorationGreyHard = BoxDecoration(
  color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 400],
  borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
);
