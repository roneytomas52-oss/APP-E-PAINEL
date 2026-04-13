import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/parcel/controllers/parcel_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/payment/widgets/offline_payment_button.dart';

class ParcelPaymentMethodBottomSheet extends StatefulWidget {
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isOfflinePaymentActive;
  final double totalPrice;
  final bool canPayWallet;
  const ParcelPaymentMethodBottomSheet({super.key, required this.isCashOnDeliveryActive, required this.isDigitalPaymentActive,
    required this.totalPrice, required this.isOfflinePaymentActive, this.canPayWallet = true});

  @override
  State<ParcelPaymentMethodBottomSheet> createState() => _ParcelPaymentMethodBottomSheetState();
}

class _ParcelPaymentMethodBottomSheetState extends State<ParcelPaymentMethodBottomSheet> {
  final JustTheController tooltipController = JustTheController();
  bool showChangeAmount = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 550,
      child: GetBuilder<ParcelController>(builder: (parcelController) {

        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.vertical(top: const Radius.circular(Dimensions.radiusLarge), bottom: Radius.circular(ResponsiveHelper.isDesktop(context) ? Dimensions.radiusLarge : 0)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            ResponsiveHelper.isDesktop(context) ? Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () => Get.back(),
                child: Container(
                  height: 30, width: 30,
                  margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(50)),
                  child: const Icon(Icons.clear),
                ),
              ),
            ) : Align(
              alignment: Alignment.center,
              child: Container(
                height: 5, width: 40,
                margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(color: Theme.of(context).disabledColor.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Text('choose_payment_method'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                child: Column(
                  children: [

                    Text('total_bill'.tr, style: robotoMedium.copyWith(fontSize: 14, color: Colors.grey.shade700)),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Text(PriceConverter.convertPrice(widget.totalPrice), style: robotoMedium.copyWith(fontSize: 20, color: Theme.of(context).primaryColor)),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    walletView(parcelController),

                    widget.isCashOnDeliveryActive ? paymentButtonView(
                      padding: EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                      title: 'cash_on_delivery'.tr,
                      isSelected: parcelController.paymentIndex == 0,
                      disablePayments: false,
                      onTap: (){
                        parcelController.setPaymentIndex(0, true);
                      },
                    ) : const SizedBox(),

                    widget.isDigitalPaymentActive && Get.find<SplashController>().configModel!.activePaymentMethodList!.isNotEmpty ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        border: Border.all(color: Theme.of(context).disabledColor, width: 0.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                            child: Text('pay_via_online'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color)),
                          ),

                          ListView.builder(
                            itemCount: Get.find<SplashController>().configModel!.activePaymentMethodList!.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index){
                              bool isSelected = parcelController.paymentIndex == 2 && Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay! == parcelController.digitalPaymentName;

                              return paymentButtonView(
                                padding: EdgeInsets.only(bottom: index == Get.find<SplashController>().configModel!.activePaymentMethodList!.length - 1 ? 0 : Dimensions.paddingSizeSmall),
                                disablePayments: false,
                                onTap: () {
                                  parcelController.setPaymentIndex(2, true);
                                  parcelController.changeDigitalPaymentName(Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay!);
                                },
                                title: Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWayTitle!,
                                isSelected: isSelected,
                                image: Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWayImageFullUrl,
                              );
                            },
                          ),
                        ],
                      ),
                    ) : const SizedBox(),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    widget.isOfflinePaymentActive ? OfflinePaymentButton(
                      isSelected: parcelController.paymentIndex == 3,
                      offlineMethodList: parcelController.offlineMethodList,
                      isOfflinePaymentActive: widget.isOfflinePaymentActive,
                      onTap: () {
                        parcelController.setPaymentIndex(3, true);
                      },
                      checkoutController: Get.find<CheckoutController>(), tooltipController: tooltipController,
                      disablePayment: false, forParcel: true,
                    ) : const SizedBox(),
                  ],
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeLarge),
                child: GetBuilder<OrderController>(
                  builder: (orderController) {
                    return CustomButton(
                      buttonText: 'proceed'.tr,
                      onPressed: () {
                        Get.back();
                      },
                    );
                  }
                ),
              ),
            ),

          ]),
        );
      }),
    );
  }

  Widget paymentButtonView({required String title, String? image, required bool isSelected, required Function? onTap, bool disablePayments = false, bool isDigitalPayment = false, required EdgeInsetsGeometry padding}) {
    return Padding(
      padding: padding,
      child: InkWell(
        onTap: onTap as void Function()?,
        child: Container(
          decoration: image != null ? null : BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            border: Border.all(color: isSelected && isDigitalPayment ? Theme.of(context).primaryColor.withValues(alpha: 0.2) : Theme.of(context).disabledColor.withValues(alpha: 0.2)),
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Row(children: [

            image != null ? CustomImage(
              height: 15, fit: BoxFit.contain,
              image: image, color: disablePayments ? Theme.of(context).disabledColor : null,
            ) : const SizedBox(),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            Expanded(
              child: Text(
                title,
                style: isDigitalPayment ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: disablePayments ? Theme.of(context).disabledColor : Theme.of(context).textTheme.bodyLarge!.color) :
                robotoSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: disablePayments ? Theme.of(context).disabledColor : Theme.of(context).textTheme.bodyLarge!.color),
              ),
            ),

            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              size: 24,
              color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.5),
            ),

          ]),
        ),
      ),
    );
  }

  Widget walletView(ParcelController parcelController) {
    double walletBalance = Get.find<ProfileController>().userInfoModel?.walletBalance??0;
    double balance = 0;
    if(!widget.canPayWallet || (walletBalance <= 0 || walletBalance < widget.totalPrice)) {
      return const SizedBox();
    }
    if(walletBalance > widget.totalPrice && parcelController.paymentIndex == 1) {
      balance = walletBalance - widget.totalPrice;
    }
    bool isWalletSelected = parcelController.paymentIndex == 1;

    return Get.find<SplashController>().configModel!.customerWalletStatus == 1
        && Get.find<ProfileController>().userInfoModel != null && (parcelController.distance != -1)
        && Get.find<ProfileController>().userInfoModel!.walletBalance! > 0 ? Column(children: [
      Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: Theme.of(context).disabledColor, width: 0.3),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text(isWalletSelected ? 'wallet_remaining_balance'.tr : 'wallet_balance'.tr, style: robotoMedium.copyWith(fontSize: 12, color: Colors.grey.shade700)),

            Row(children: [
              Text(
                PriceConverter.convertPrice(isWalletSelected ? balance : walletBalance),
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
              ),

              Text(
                isWalletSelected ? ' (${'applied'.tr})' : '',
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor),
              ),
            ])
          ]),

          CustomInkWell(
            onTap: () {
              parcelController.setPaymentIndex(1, true);
            },
            radius: 5,
            child: isWalletSelected ? const Icon(Icons.clear, color: Colors.red) : Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(color: Theme.of(context).primaryColor, width: 1)),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
              child: Text('apply'.tr, style: robotoMedium.copyWith(fontSize: 12, color: Theme.of(context).primaryColor)),
            ),
          ),
        ]),
      ),

      if(isWalletSelected)
        Container(
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

            Text('paid_by_wallet'.tr, style: robotoBold.copyWith(fontSize: 14)),
            Text(PriceConverter.convertPrice(widget.totalPrice), style: robotoMedium.copyWith(fontSize: 18))

          ]),
        ),

    ]) : const SizedBox();
  }

}
