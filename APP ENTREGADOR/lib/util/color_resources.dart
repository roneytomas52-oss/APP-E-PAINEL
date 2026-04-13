import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ColorResources {

  static Color getRightBubbleColor() {
    return  Theme.of(Get.context!).primaryColor;
  }

  static Color getLeftBubbleColor() {
    return Get.isDarkMode ? const Color(0xA2B7B7BB): Theme.of(Get.context!).disabledColor.withValues(alpha: 0.2);
  }

  static const Color green = Color(0xff24A85C);
  static const Color red = Color(0xffFF5A54);
  static const Color blue = Color(0xff1D95FF);
  static const Color white = Color(0xffffffff);
  static const Color black = Color(0xff000000);
}