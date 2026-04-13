import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/enums.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';

class DmRegistrationSuccessScreen extends StatelessWidget {
  const DmRegistrationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {

    bool isRideActive = AppConstants.appMode == AppMode.ride;

    return Scaffold(
      appBar: AppBar(
        title: Text( isRideActive ? "rider_registration".tr : 'delivery_man_registration'.tr,
          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge!.color),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).cardColor,
        surfaceTintColor: Theme.of(context).cardColor,
        shadowColor: Theme.of(context).disabledColor.withValues(alpha: 0.5),
        elevation: 2,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Container(
            margin: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
            height: 4,
            child: Row(spacing: Dimensions.paddingSizeSmall, children: [
              Expanded(
                child: Container(height: 4, color: Theme.of(context).primaryColor),
              ),

              Expanded(
                child: Container(height: 4, color: Theme.of(context).primaryColor),
              ),
            ]),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [

          const CustomAssetImageWidget(
            image: Images.successIcon, height: 60, width: 60,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Text(
            'registration_successful'.tr,
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Text(
            'registration_successful_message'.tr,
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 50),

          CustomButtonWidget(
            buttonText: 'back_to_login_page'.tr,
            onPressed: () {
              Get.offAllNamed(RouteHelper.getSignInRoute());
            },
          ),

        ]),
      ),

    );
  }
}
