import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/auth/widgets/auth_dialog_widget.dart';
import 'package:sixam_mart/features/checkout/widgets/payment_method_bottom_sheet.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class DigitalPaymentFailedScreen extends StatefulWidget {
  final String orderId;
  final bool? fromDialog;
  final bool? createAccount;
  const DigitalPaymentFailedScreen({super.key, required this.orderId, this.fromDialog = false, this.createAccount = false});

  @override
  State<DigitalPaymentFailedScreen> createState() => _DigitalPaymentFailedScreenState();
}

class _DigitalPaymentFailedScreenState extends State<DigitalPaymentFailedScreen> {

  @override
  void initState() {
    super.initState();

    Get.find<OrderController>().getPaymentFailedDetails(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    if(widget.fromDialog!) {
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
        child: Stack(children: [
          PaymentIncompleteView(),

          Positioned(
            top: 0,
            right: 0,
            child: InkWell(
              onTap: () => Get.back(),
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
        ]),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: PaymentIncompleteView(createAccount: widget.createAccount!),
      ),
    );
  }
}

class PaymentIncompleteView extends StatelessWidget {
  final bool createAccount;
  const PaymentIncompleteView({super.key, this.createAccount = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(
        builder: (orderController) {
          double totalAmount = (orderController.paymentModel?.orderAmount??0) - (orderController.paymentModel?.partiallyPaidAmount??0);
          return orderController.paymentModel != null ? SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: context.height * 0.1),

                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Image.asset(Images.warning, width: 70, height: 70),
                ),

                const SizedBox(height: Dimensions.paddingSizeDefault),

                SelectableText(
                  '${'order'.tr} #${orderController.paymentModel?.orderID}',
                  style: robotoBold.copyWith(color: Theme.of(context).primaryColor),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Text(
                  'your_order_is_placed_but'.tr,
                  style: robotoMedium,
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    '${'payment_failed'.tr} !!',
                    style: robotoBold.copyWith(color: Colors.red),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                Text(
                  'due_amount'.tr,
                  style: robotoRegular,
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Text(
                  PriceConverter.convertPrice(totalAmount),
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                if(!createAccount)...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
                    child: Text(
                      'please_choose_an_option_from_below_to_continue_with_this_order'.tr,
                      textAlign: TextAlign.center,
                      style: robotoRegular,
                    ),
                  ),
                  const SizedBox(height: 40.0),
                ],

                createAccount ? Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(
                          'and_create_account_successfully'.tr,
                          style: robotoMedium,
                        ),
                        InkWell(
                          onTap: () {
                            if(ResponsiveHelper.isDesktop(context)){
                              Get.dialog(const Center(child: AuthDialogWidget(exitFromApp: false, backFromThis: false)));
                            }else{
                              Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                            child: Text('sign_in'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                          ),
                        ),
                      ]),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      Padding(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        child: CustomButton(
                          width: ResponsiveHelper.isDesktop(context) ? 300 : double.infinity,
                          buttonText: 'back_to_home'.tr, onPressed: () {
                            Get.offAllNamed(RouteHelper.getInitialRoute());
                          },
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ) : GetBuilder<OrderController>(builder: (orderController) {
                  return !orderController.isLoading ? Column(children: [

                    if(!AuthHelper.isGuestLoggedIn())
                      CustomButton(
                        width: ResponsiveHelper.isDesktop(context) ? 250 : context.width * 0.6,
                        buttonText: 'pay_now'.tr,
                        onPressed: (){
                          if(ResponsiveHelper.isDesktop(context)) {
                            Get.dialog(Dialog(backgroundColor: Colors.transparent, child: PaymentMethodBottomSheet(
                              isCashOnDeliveryActive: orderController.paymentModel?.isCashOnDeliveryActive??false, isDigitalPaymentActive: orderController.paymentModel?.isDigitalPaymentActive??false,
                              totalPrice: totalAmount, isOfflinePaymentActive: orderController.paymentModel?.isOfflinePaymentActive??false,
                              paymentModel: orderController.paymentModel,
                            )));

                          } else {
                            Get.bottomSheet(
                              PaymentMethodBottomSheet(
                                isCashOnDeliveryActive: orderController.paymentModel?.isCashOnDeliveryActive??false, isDigitalPaymentActive: orderController.paymentModel?.isDigitalPaymentActive??false,
                                totalPrice: totalAmount, isOfflinePaymentActive: orderController.paymentModel?.isOfflinePaymentActive??false,
                                paymentModel: orderController.paymentModel,
                              ),
                              backgroundColor: Colors.transparent, isScrollControlled: true,
                            );
                          }
                        },
                      ),
                    SizedBox(height: orderController.paymentModel?.isCashOnDeliveryActive??false ? Dimensions.paddingSizeDefault : 0),

                    orderController.paymentModel?.isCashOnDeliveryActive??false ? SizedBox(
                      width: ResponsiveHelper.isDesktop(context) ? 250 : context.width * 0.6,
                      height: 50.0,
                      child: OutlinedButton(
                        onPressed: () {
                          if((((orderController.paymentModel?.maxCodOrderAmount != null && orderController.paymentModel!.orderAmount! < orderController.paymentModel!.maxCodOrderAmount!) || orderController.paymentModel!.maxCodOrderAmount == null || orderController.paymentModel!.maxCodOrderAmount == 0) && orderController.paymentModel!.orderType != 'parcel') || orderController.paymentModel!.orderType == 'parcel'){
                            orderController.switchToCOD(orderController.paymentModel!.orderID, guestId: orderController.paymentModel!.guestId).then((success){
                              if(success){
                                Get.offAllNamed(RouteHelper.getInitialRoute());
                                double total = ((orderController.paymentModel!.orderAmount! / 100) * Get.find<SplashController>().configModel!.loyaltyPointItemPurchasePoint!);
                                if(AuthHelper.isLoggedIn()) {
                                  Get.find<AuthController>().saveEarningPoint(total.toStringAsFixed(0));
                                }
                              }
                            });
                          }else{
                            if(Get.isDialogOpen!) {
                              Get.back();
                            }
                            showCustomSnackBar('${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(orderController.paymentModel!.maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}');
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          ),
                          textStyle: robotoBold,
                          backgroundColor: AuthHelper.isGuestLoggedIn() ? Theme.of(context).primaryColor : null,
                        ),
                        child: Text('switch_to_cash_on_delivery'.tr, style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: AuthHelper.isGuestLoggedIn() ? Theme.of(context).cardColor : Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                        ),
                      ),
                    ) : const SizedBox(),

                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    TextButton(
                      onPressed: () {
                        orderController.cancelOrder(orderID: int.parse(orderController.paymentModel!.orderID!), reason: 'Digital payment issue', isParcel: false, guestId: orderController.paymentModel!.guestId).then((success) {
                          if(success){
                            Get.offAllNamed(RouteHelper.getInitialRoute());
                          }
                        });
                      },
                      child: Text(
                        'cancel_order'.tr,
                        style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color),
                      ),
                    ),
                  ]) : const Center(child: CircularProgressIndicator());
                }),

                const SizedBox(height: 50),
              ],
            ),
          ) : const Center(child: CircularProgressIndicator());
        }
    );
  }
}

