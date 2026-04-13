import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/web_page_title_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

class WebSupportScreen extends StatelessWidget {
  const WebSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: Dimensions.webMaxWidth,
      child: SingleChildScrollView(
        child: Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              WebScreenTitleWidget(title: 'help_support'.tr),
              SizedBox(height: Dimensions.paddingSizeExtremeLarge),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                child: Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraOverLarge),
                  width: Dimensions.webMaxWidth,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.1), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraOverLarge),
                    child: Row(children: [
                        Expanded(child: Column(children: [
                          Image.asset(Images.helpAndSupport, width: 170, height: 120),
                          SizedBox(height: Dimensions.paddingSizeDefault),
                          Text('contact_for_support'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                          Text("support_description".tr, textAlign: TextAlign.center, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
                        ])),
                        Expanded(child: Container(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                          width: Dimensions.webMaxWidth,
                          decoration: BoxDecoration(
                            color: Theme.of(context).disabledColor.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          ),
                          child: Column(children: [
                            CustomCard(
                              icon: Icons.call,
                              title: 'call_customer_support'.tr,
                              subtitle: 'talk_with_our_customer_support_executive_at_any_time'.tr,
                              mainText: Get.find<SplashController>().configModel!.phone!,
                              onActionPressed: () async {
                                if (await canLaunchUrlString('tel:${Get.find<SplashController>().configModel!.phone}')) {
                                  launchUrlString('tel:${Get.find<SplashController>().configModel!.phone}', mode: LaunchMode.externalApplication);
                                } else {
                                  showCustomSnackBar('${'can_not_launch'.tr} ${Get.find<SplashController>().configModel!.phone}');
                                }
                              }
                            ),
                            const SizedBox(width: Dimensions.paddingSizeExtremeLarge),
                            CustomCard(
                              icon: Icons.email,
                              title: 'send_us_email_through'.tr,
                              subtitle: 'typically_the_support_team_send_you_any_feedback_in_2_hours'.tr,
                              mainText: Get.find<SplashController>().configModel!.email!,
                              onActionPressed: () {
                                final Uri emailLaunchUri = Uri(scheme: 'mailto',
                                  path: Get.find<SplashController>().configModel!.email,
                                );
                                launchUrlString(emailLaunchUri.toString(), mode: LaunchMode.externalApplication);
                              },
                            ),
                            const SizedBox(width: Dimensions.paddingSizeExtremeLarge),
                            CustomCard(
                              icon: Icons.location_on,
                              title: 'address'.tr,
                              mainText: Get.find<SplashController>().configModel!.address!,
                              onActionPressed:() async {}
                            ),
                          ]),
                        )),

                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String mainText;
  final VoidCallback? onActionPressed;

  const CustomCard({super.key, required this.icon, required this.title, this.subtitle, required this.mainText, this.onActionPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.1), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 35, height: 35,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Theme.of(context).primaryColor, size: Dimensions.paddingSizeLarge),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.6))),
              subtitle != null ? const SizedBox(height: 4) : SizedBox.shrink(),
              subtitle != null ? Text(subtitle!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.6))) : SizedBox.shrink(),
            ])),
            const SizedBox(width: Dimensions.paddingSizeDefault),
          ]),
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            SizedBox(width: 40),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(child: Text(mainText, style: subtitle != null ? robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)
                : robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.6)))),
            Container(width: 35, height: 35,
              decoration: BoxDecoration(color:  const Color(0xFF4CAF50), shape: BoxShape.circle,),
              child: GestureDetector(
                onTap: onActionPressed,
                child: Icon(icon, color: Colors.white, size: Dimensions.paddingSizeLarge),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
