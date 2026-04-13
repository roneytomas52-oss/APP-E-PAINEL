import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/helper/shallow_route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
class ZoneWarningDialog extends StatelessWidget {
  final String title;
  final String? description;
  final Function()? onPressed;
  final String? buttonText;
  const ZoneWarningDialog({super.key, required this.title, this.description, this.onPressed, this.buttonText});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: PointerInterceptor(
        child: SizedBox(width: 500, child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Column(mainAxisSize: MainAxisSize.min, children: [

                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Image.asset(Images.zoneLocation, width: 50, height: 50),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                  child: Text(
                    title, textAlign: TextAlign.center,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ),
                ),

                description != null ? Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Text(description!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault), textAlign: TextAlign.center),
                ) : const SizedBox(),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                CustomButton(
                  buttonText: buttonText != null ? buttonText! : 'ok'.tr,
                  onPressed: onPressed ?? () async {
                    Get.back();
                    Get.dialog(const CustomLoaderWidget());
                    await Get.find<SplashController>().setModule(null);
                    AddressHelper.clearAddressFromSharedPref();
                    ShallowRouterHelper.updateParameter('module', '');
                    Future.delayed(const Duration(milliseconds: 500), () {
                      Get.offAllNamed(RouteHelper.getInitialRoute(moduleId: 'null'));
                    });
                  },
                  radius: Dimensions.radiusSmall, height: 50, width: 300,
                ),

              ]),
            ),

            Positioned(
              top: 5, right: 5,
              child: IconButton(
                onPressed: ()=> Get.back(),
                icon: Icon(Icons.close, color: Theme.of(context).disabledColor),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
