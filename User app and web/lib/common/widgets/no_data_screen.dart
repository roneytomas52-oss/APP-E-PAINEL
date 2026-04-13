import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';


class NoDataScreen extends StatelessWidget {
  final bool isCart;
  final bool showFooter;
  final String? text;
  final bool fromAddress;
  final bool isNotScrollable;
  final bool? fromInterestPage;
  const NoDataScreen({super.key, required this.text, this.isCart = false, this.showFooter = false, this.fromAddress = false,  this.isNotScrollable = false, this.fromInterestPage = false});

  @override
  Widget build(BuildContext context) {
    return isNotScrollable ? _NoDataView(fromAddress: fromAddress, isCart: isCart, text: text, fromInterestPage: fromInterestPage!) : SingleChildScrollView(
      child: FooterView(
        visibility: showFooter,
        child: _NoDataView(fromAddress: fromAddress, isCart: isCart, text: text, fromInterestPage: fromInterestPage!),
      ),
    );
  }
}

class _NoDataView extends StatelessWidget {
  const _NoDataView({
    required this.fromAddress,
    required this.isCart,
    required this.text,
    required this.fromInterestPage,
  });

  final bool fromAddress;
  final bool isCart;
  final String? text;
  final bool fromInterestPage;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [

      if(fromInterestPage)...[
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
          child: Text('choose_your_interests'.tr, style: robotoMedium.copyWith(fontSize: 22)),
        ),
        const SizedBox(height: 100),
      ],

      Center(
        child: Image.asset(
          fromAddress ? Images.address : isCart ? Images.emptyCart : Images.noDataFound,
          width: MediaQuery.of(context).size.height*0.15, height: MediaQuery.of(context).size.height*0.15,
        ),
      ),
      SizedBox(height: MediaQuery.of(context).size.height*0.03),

      Text(
        isCart ? 'cart_is_empty'.tr : text!,
        style: robotoMedium.copyWith(fontSize: MediaQuery.of(context).size.height*0.0175, color: fromAddress ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).disabledColor),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: MediaQuery.of(context).size.height*0.03),

      fromAddress ? Text(
        'please_add_your_address_for_your_better_experience'.tr,
        style: robotoMedium.copyWith(fontSize: MediaQuery.of(context).size.height*0.0175, color: Theme.of(context).disabledColor),
        textAlign: TextAlign.center,
      ) : const SizedBox(),
      SizedBox(height: MediaQuery.of(context).size.height*0.05),

      fromAddress ? InkWell(
        onTap: () => Get.toNamed(RouteHelper.getAddAddressRoute(false, false, 0)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: Theme.of(context).primaryColor,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_circle_outline_sharp, size: 18.0, color: Theme.of(context).cardColor),
              Text('add_address'.tr, style: robotoMedium.copyWith(color: Theme.of(context).cardColor)),
            ],
          ),
        ),
      ) : const SizedBox(),

      fromInterestPage ? CustomButton(
        buttonText: 'continue'.tr,
        width: 300,
        onPressed: () {
          if(ResponsiveHelper.isDesktop(Get.context)) {
            Get.offAllNamed(RouteHelper.getInitialRoute());
          } else {
            Get.back();
          }
        },
      ) : const SizedBox(),

    ]);
  }
}
