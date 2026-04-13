import 'package:flutter/material.dart';
import 'package:sixam_mart/util/app_constants.dart';

ThemeData light({Color color = const Color(0xFF039D55)}) => ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: color,
  secondaryHeaderColor: const Color(0xFF1ED7AA),
  disabledColor: const Color(0xFF9F9F9F),
  brightness: Brightness.light,
  hintColor: const Color(0xFF9F9F9F),
  cardColor: Colors.white,
  shadowColor: Colors.black.withValues(alpha: 0.03),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: color)),
  colorScheme: ColorScheme.light(primary: color, secondary: color).copyWith(
      surface: const Color(0xFFFCFCFC)).copyWith(error: const Color(0xFFE84D4F)),
  popupMenuTheme: const PopupMenuThemeData(color: Colors.white, surfaceTintColor: Colors.white),
  dialogTheme: const DialogThemeData(surfaceTintColor: Colors.white),
  floatingActionButtonTheme: FloatingActionButtonThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500))),
  bottomAppBarTheme: const BottomAppBarThemeData(
    surfaceTintColor: Colors.white, height: 60,
    padding: EdgeInsets.symmetric(vertical: 5),
  ),
  dividerTheme: const DividerThemeData(thickness: 0.2, color: Color(0xFFA0A4A8)),
  tabBarTheme: const TabBarThemeData(dividerColor: Colors.transparent),
);

const Map<String, Color> buttonBackgroundColorMap ={
  'pending': Color(0x457bc2f6),
  'accepted': Color(0x499ad0fb),
  'ongoing': Color(0x629ac5f8),
  'completed': Color(0x5faff4c1),
  'settled': Color(0x6e93b347),
  'canceled': Color(0x51F6A9A9),
  'approved': Color(0x80356e4c),
  'expired' : Color(0x8C7C3B3B),
  'running' : Color(0x793c4fd8),
  'denied':  Color(0x666e3737),
  'paused': Color(0xff0461A5),
  'resumed' : Color(0x6f2f5e41),
  'resume' : Color(0x8e387c54),
  'subscription_purchase' : Color(0x3cecc98d),
  'subscription_renew' : Color(0x1d6bf5a2),
  'subscription_shift' : Color(0x452599ee),
  'subscription_refund' : Color(0x1dc97eee),
};

const Map<String, Color> buttonTextColorMap ={
  'pending': Color(0xff058df3),
  'accepted': Color(0xff2B95FF),
  'ongoing': Color(0xff2B95FF),
  'completed': Color(0xff03b158),
  'settled': Color(0xf57b9826),
  'canceled': Color(0xfff44747),
  'approved': Color(0xff16B559),
  'expired' : Color(0xff9ca8af),
  'running' : Color(0xff707ec6),
  'denied':  Color(0xffFF3737),
  'paused': Color(0xff0461A5),
  'resumed' : Color(0xff16B559),
  'resume' : Color(0xff16B559),
  'subscription_purchase' : Color(0xffe7680a),
  'subscription_renew' : Color(0xff16B559),
  'subscription_shift' : Color(0xff0461A5),
  'subscription_refund' : Color(0xffba4af8),
};