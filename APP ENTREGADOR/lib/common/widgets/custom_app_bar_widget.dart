import 'package:get/get.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:flutter/material.dart';

class CustomAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isBackButtonExist;
  final Function? onBackPressed;
  final Widget? actionWidget;
  final TabBar? bottom;
  final String? subtitle;
  const CustomAppBarWidget({super.key, required this.title, this.isBackButtonExist = true, this.onBackPressed, this.actionWidget, this.bottom, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color)),
      centerTitle: true,
      leading: isBackButtonExist ? IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        color: Theme.of(context).textTheme.bodyLarge!.color,
        onPressed: (){
          if(onBackPressed != null){
            onBackPressed!();
          }else if(Get.previousRoute.isNotEmpty){
            Get.back();
          }else{
            Get.offAllNamed(RouteHelper.getInitialRoute());
          }
        } ,
      ) : const SizedBox(),
      backgroundColor: Theme.of(context).cardColor,
      surfaceTintColor: Theme.of(context).cardColor,
      shadowColor: Theme.of(context).disabledColor.withValues(alpha: 0.5),
      elevation: 2,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
          child: actionWidget ?? const SizedBox(),
        ),
      ],
      bottom: bottom ?? (subtitle != null ? PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Text(subtitle!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),),
        ),
      ) : null),
    );
  }

  @override
  Size get preferredSize => Size(1170, GetPlatform.isDesktop ? (bottom != null ? 120 : 70) : (bottom != null ? 100 : 60));
}
