import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:sixam_mart/features/auth/screens/sign_in_screen.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
class LoginWarningDialog extends StatelessWidget {
  const LoginWarningDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
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
                  child: Image.asset(Images.warning, width: 60, height: 60,),
                ),
                // const SizedBox(height: Dimensions.paddingSizeDefault),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                  child: Text(
                    'login_or_signup'.tr,
                    textAlign: TextAlign.center,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                  child: Text(
                    'to_explore_this_feature_please_login_to_your_account'.tr,
                    textAlign: TextAlign.center,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.7)),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            // await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
                            await Get.to(()=> const SignInScreen(exitFromApp: false, backFromThis: true, fromRideDialog: true,));
                            if(AuthHelper.isLoggedIn()) {
                              Get.back(result: true);
                              Get.find<ProfileController>().getUserInfo();
                            } else {
                              Get.back(result: false);
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor, minimumSize: const Size(80, 40), padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                          ),
                          child: Text('login'.tr, textAlign: TextAlign.center,
                            style: robotoBold.copyWith(color: Theme.of(context).cardColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeLarge),

                      Expanded(
                        child: TextButton(
                          onPressed: () => Get.back(result: false),
                          style: TextButton.styleFrom(
                            backgroundColor: Theme.of(context).disabledColor.withValues(alpha: 0.3), minimumSize: const Size(80, 40), padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                          ),
                          child: Text('cancel'.tr, textAlign: TextAlign.center,
                            style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color),
                          ),
                        ),
                      ),

                    ])

              ]),
            ),

            Positioned(top: 0, right: 0, child: IconButton(onPressed: ()=> Get.back(), icon: const Icon(Icons.clear))),

          ],
        )),
      ),
    );
  }
}
