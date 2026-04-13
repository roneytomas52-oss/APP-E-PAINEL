import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/checkout/domain/models/payment_model.dart';
import 'package:sixam_mart/features/checkout/widgets/payment_method_bottom_sheet.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
class PaymentIncompleteBottomSheet extends StatefulWidget {
  final PaymentModel paymentModel;
  final bool fromHome;
  const PaymentIncompleteBottomSheet({super.key, required this.paymentModel, this.fromHome = false});

  @override
  State<PaymentIncompleteBottomSheet> createState() => _PaymentIncompleteBottomSheetState();
}

class _PaymentIncompleteBottomSheetState extends State<PaymentIncompleteBottomSheet> {
  bool _dontShowAgain = false;

  @override
  Widget build(BuildContext context) {
    double orderAmount = (widget.paymentModel.orderAmount??0) - (widget.paymentModel.partiallyPaidAmount ?? 0);
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      width: 500,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusLarge),
          topRight: Radius.circular(Dimensions.radiusLarge),
          bottomRight: Radius.circular(ResponsiveHelper.isDesktop(Get.context) ? Dimensions.radiusLarge : 0),
          bottomLeft: Radius.circular(ResponsiveHelper.isDesktop(Get.context) ? Dimensions.radiusLarge : 0),
        ),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: Dimensions.paddingSizeLarge),

              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: 'your_payment_was'.tr, style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.6), fontSize: Dimensions.fontSizeLarge)),
                    TextSpan(text: ' ${'incomplete'.tr}', style: robotoBold.copyWith(color: Colors.red, fontSize: Dimensions.fontSizeLarge)),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                ),
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeLarge),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'order_id'.tr,
                          style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5)),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Text(
                          '#${widget.paymentModel.orderID}',
                          style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'amount'.tr,
                          style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5)),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Text(
                          PriceConverter.convertPrice(orderAmount),
                          style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Text(
                'your_payment_was_incomplete_Please_choose_an_option_below_to_complete_your_transaction'.tr,
                style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.6)), textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),


              if(GetPlatform.isWeb)
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _dontShowAgain,
                        onChanged: (value) {
                          setState(() {
                            _dontShowAgain = value ?? false;
                          });
                          Get.find<SplashController>().savePaymentIncompleteSheetStatus(value ?? false);
                        },
                        activeColor: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Text(
                      'dont_show_again'.tr,
                      style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color),
                    ),
                  ],
                ),
              SizedBox(height: GetPlatform.isWeb ? Dimensions.paddingSizeLarge : 0),

              GetBuilder<OrderController>(builder: (orderController) {
                return !orderController.isLoading ? Column(children: [

                  CustomButton(
                    buttonText: 'pay_now'.tr,
                    onPressed: (){
                      if(ResponsiveHelper.isDesktop(context)) {
                        Get.back();
                        Get.dialog(Dialog(backgroundColor: Colors.transparent, child: PaymentMethodBottomSheet(
                          isCashOnDeliveryActive: orderController.paymentModel?.isCashOnDeliveryActive??false, isDigitalPaymentActive: orderController.paymentModel?.isDigitalPaymentActive??false,
                          totalPrice: orderAmount, isOfflinePaymentActive: orderController.paymentModel?.isOfflinePaymentActive??false,
                          paymentModel: orderController.paymentModel, fromHome: widget.fromHome,
                        )));

                      } else {
                        Get.bottomSheet(
                          PaymentMethodBottomSheet(
                            isCashOnDeliveryActive: orderController.paymentModel?.isCashOnDeliveryActive??false, isDigitalPaymentActive: orderController.paymentModel?.isDigitalPaymentActive??false,
                            totalPrice: orderAmount, isOfflinePaymentActive: orderController.paymentModel?.isOfflinePaymentActive??false,
                            paymentModel: orderController.paymentModel, fromHome: widget.fromHome,
                          ),
                          backgroundColor: Colors.transparent, isScrollControlled: true,
                        );
                      }
                    },
                  ),
                  SizedBox(height: orderController.paymentModel?.isCashOnDeliveryActive??false ? Dimensions.paddingSizeLarge : 0),

                  orderController.paymentModel?.isCashOnDeliveryActive??false ? SizedBox(
                    width: context.width,
                    height: 50.0,
                    child: OutlinedButton(
                      onPressed: () {
                        if((((orderController.paymentModel?.maxCodOrderAmount != null && orderController.paymentModel!.orderAmount! < orderController.paymentModel!.maxCodOrderAmount!) || orderController.paymentModel!.maxCodOrderAmount == null || orderController.paymentModel!.maxCodOrderAmount == 0) && orderController.paymentModel!.orderType != 'parcel') || orderController.paymentModel!.orderType == 'parcel'){
                          orderController.switchToCOD(orderController.paymentModel!.orderID, guestId: orderController.paymentModel!.guestId).then((success){
                            if(success){
                              Get.find<SplashController>().togglePaymentIncompleteBottomSheet(false);
                              double total = ((orderController.paymentModel!.orderAmount! / 100) * Get.find<SplashController>().configModel!.loyaltyPointItemPurchasePoint!);
                              if(AuthHelper.isLoggedIn()) {
                                Get.find<AuthController>().saveEarningPoint(total.toStringAsFixed(0));
                                Get.back();
                              }
                            }
                          });
                        }else{
                          if(Get.isDialogOpen!) {
                            Get.back();
                          }
                          showCustomSnackBar('${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(orderController.paymentModel!.maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}', getXSnackBar: true);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 0.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        textStyle: robotoBold,
                        backgroundColor: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                      ),
                      child: Text('switch_to_cash_on_delivery'.tr, style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color)),
                    ),
                  ) : const SizedBox(),

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  TextButton(
                    onPressed: () {
                      Get.find<SplashController>().togglePaymentIncompleteBottomSheet(false);
                      orderController.cancelOrder(orderID: int.parse(widget.paymentModel.orderID!), reason: 'Digital payment issue', isParcel: false, guestId: null).then((success) {
                        if(success){
                          Get.offAllNamed(RouteHelper.getInitialRoute());
                        }
                      });
                    },
                    child: Text(
                      'cancel_order'.tr,
                      style: robotoBold.copyWith(color: Colors.red, decoration: TextDecoration.underline),
                    ),
                  ),
                ]) : const Center(child: CircularProgressIndicator());
              }),
            ],
          ),

          Positioned(
            top: 0,
            right: 0,
            child: InkWell(
              onTap: () {
                Get.find<SplashController>().togglePaymentIncompleteBottomSheet(false);
                Get.back();
              },
              hoverColor: Colors.transparent,
              child: Container(
                height: 30, width: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).hintColor.withValues(alpha: 0.05),
                ),
                child: const Icon(Icons.close, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
