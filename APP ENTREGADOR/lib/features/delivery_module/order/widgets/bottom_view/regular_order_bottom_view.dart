import 'dart:async';
import 'package:sixam_mart_delivery/common/widgets/slider_button_widget.dart';
import 'package:sixam_mart_delivery/features/language/controllers/language_controller.dart';
import 'package:sixam_mart_delivery/features/notification/controllers/notification_controller.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/widgets/bottom_view/delivery_confirmation_section.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/order_model.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/confirmation_dialog_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/widgets/cancellation_dialogue_widget.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/widgets/collect_money_delivery_sheet_widget.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/widgets/verify_delivery_sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum RegularOrderState {waitingToProcess, readyToConfirm, readyToPickup, readyToDeliver, completeDelivery, completed}

class RegularOrderBottomView extends StatelessWidget {
  final OrderController orderController;
  final double total;
  final OrderModel controllerOrderModel;
  final bool fromLocationScreen;
  final int orderId;
  final bool showDeliveryConfirmImage;
  const RegularOrderBottomView({super.key, required this.orderController, required this.controllerOrderModel, required this.fromLocationScreen, required this.orderId, required this.showDeliveryConfirmImage, required this.total});

  @override
  Widget build(BuildContext context) {
    final orderState = _getRegularOrderState(controllerOrderModel);

    switch (orderState) {
      case RegularOrderState.waitingToProcess:
        return _buildOrderWaitingStatus();

      case RegularOrderState.readyToConfirm:
        return _buildOrderConfirmationActions(orderController, controllerOrderModel);

      case RegularOrderState.readyToPickup:
        return _buildOrderPickupSlider(orderController, controllerOrderModel, total);

      case RegularOrderState.readyToDeliver:
        return _buildOrderDeliverySlider(orderController, controllerOrderModel);

      case RegularOrderState.completeDelivery:
        return _buildCompleteDeliveryButton(orderController, controllerOrderModel);

      default:
        return const SizedBox();
    }
  }

  RegularOrderState _getRegularOrderState(OrderModel order) {
    final status = order.orderStatus;
    final cod = order.paymentMethod == 'cash_on_delivery';
    final restConfModel = Get.find<SplashController>().configModel!.orderConfirmationModel != 'deliveryman';
    final selfDelivery = Get.find<ProfileController>().profileModel!.type != 'zone_wise';

    switch (status) {
      case AppConstants.processing:
      case AppConstants.confirmed:
        return RegularOrderState.waitingToProcess;

      case AppConstants.accepted:
        if (!cod || restConfModel || selfDelivery) {
          return RegularOrderState.waitingToProcess;
        }
        return RegularOrderState.readyToConfirm;

      case AppConstants.handover:
        return RegularOrderState.readyToPickup;

      case AppConstants.pickedUp:
        if (showDeliveryConfirmImage) {
          return RegularOrderState.completeDelivery;
        }
        return RegularOrderState.readyToDeliver;

      default:
        return RegularOrderState.completed;
    }
  }

  // Regular order waiting status
  Widget _buildOrderWaitingStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardColor,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
      ),
      child: Text('order_waiting_for_process'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge), textAlign: TextAlign.center),
    );
  }

  // Regular order confirmation actions
  Widget _buildOrderConfirmationActions(OrderController orderController, OrderModel controllerOrderModel) {

    final deliverymanConfModel = Get.find<SplashController>().configModel!.orderConfirmationModel == 'deliveryman';
    final cancelPermission = Get.find<SplashController>().configModel!.canceledByDeliveryman ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardColor,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
      ),
      child: Row(children: [
        cancelPermission ? Expanded(
          child: _buildOrderCancelButton(orderController),
        ) : SizedBox(),
        SizedBox(width: cancelPermission ? Dimensions.paddingSizeSmall : 0),

        deliverymanConfModel ? Expanded(
          child: _buildOrderConfirmButton(orderController, controllerOrderModel),
        ) : SizedBox(),
      ]),
    );
  }

  Widget _buildOrderCancelButton(OrderController orderController) {
    return TextButton(
      onPressed: () {
        orderController.setOrderCancelReason('');
        Get.dialog(CancellationDialogueWidget(orderId: orderId));
      },
      style: TextButton.styleFrom(
        minimumSize: const Size(1170, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          side: BorderSide(color: Theme.of(Get.context!).textTheme.bodyLarge!.color!),
        ),
      ),
      child: Text('cancel'.tr, style: robotoRegular.copyWith(
        color: Theme.of(Get.context!).textTheme.bodyLarge!.color,
        fontSize: Dimensions.fontSizeLarge,
      )),
    );
  }

  Widget _buildOrderConfirmButton(OrderController orderController, OrderModel order) {
    return CustomButtonWidget(
      buttonText: 'confirm'.tr,
      onPressed: () => _handleOrderConfirmation(orderController, order),
    );
  }

  // Regular order pickup slider
  Widget _buildOrderPickupSlider(OrderController orderController, OrderModel controllerOrderModel, double total) {

    bool partialPay = controllerOrderModel.paymentMethod == 'partial_payment' && (controllerOrderModel.payments?.isNotEmpty ?? false) && controllerOrderModel.payments![1].paymentMethod == 'cash_on_delivery';
    double partialAmount = partialPay ? (controllerOrderModel.payments?[1].amount ?? 0) : 0;
    bool showCollectCashAmount = controllerOrderModel.paymentMethod == "cash_on_delivery" || partialPay ;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardColor,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
      ),
      child: Column(
        children: [
          showCollectCashAmount ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
            child: Row(children: [
              Image.asset(Images.referCoin, width: 18,),
              SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Text('amount_collect_from_customer'.tr),
              const Spacer(),
              Text(PriceConverterHelper.convertPrice(partialPay ? partialAmount : total), style: robotoBold),
            ]),
          ) : SizedBox(),

          SizedBox(height: Dimensions.paddingSizeSmall),
          SliderButton(
            action: () => _handleOrderPickup(orderController, controllerOrderModel),
            label: Text(
              'swipe_to_pick_up_order'.tr,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Theme.of(Get.context!).primaryColor,
              ),
            ),
            dismissThresholds: 0.5,
            dismissible: false,
            shimmer: true,
            width: 1170,
            height: 60,
            buttonSize: 50,
            radius: 10,
            icon: _buildSliderIcon(),
            isLtr: Get.find<LocalizationController>().isLtr,
            boxShadow: const BoxShadow(blurRadius: 0),
            buttonColor: Theme.of(Get.context!).primaryColor,
            backgroundColor: const Color(0xffF4F7FC),
            baseColor: Theme.of(Get.context!).primaryColor,
          ),
        ],
      ),
    );
  }

  // Regular order delivery slider
  Widget _buildOrderDeliverySlider(OrderController orderController, OrderModel controllerOrderModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardColor,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
      ),
      child: SliderButton(
        action: () => _handleOrderDelivery(orderController, controllerOrderModel),
        label: Text(
          'swipe_to_deliver_order'.tr,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Theme.of(Get.context!).primaryColor,
          ),
        ),
        dismissThresholds: 0.5,
        dismissible: false,
        shimmer: true,
        width: 1170,
        height: 60,
        buttonSize: 50,
        radius: 10,
        icon: _buildSliderIcon(),
        isLtr: Get.find<LocalizationController>().isLtr,
        boxShadow: const BoxShadow(blurRadius: 0),
        buttonColor: Theme.of(Get.context!).primaryColor,
        backgroundColor: const Color(0xffF4F7FC),
        baseColor: Theme.of(Get.context!).primaryColor,
      ),
    );
  }

  // Complete delivery button (when image confirmation is required)
  Widget _buildCompleteDeliveryButton(OrderController orderController, OrderModel controllerOrderModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardColor,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
      ),
      child: Column(
        children: [
          if (showDeliveryConfirmImage)
            DeliveryConfirmationSection(),
          SizedBox(height: showDeliveryConfirmImage ? Dimensions.paddingSizeSmall : 0),

          CustomButtonWidget(
            buttonText: 'complete_delivery'.tr,
            onPressed: () => _handleCompleteDelivery(orderController, controllerOrderModel),
          ),
        ],
      ),
    );
  }

  // Regular order action handlers
  void _handleOrderConfirmation(OrderController orderController, OrderModel order) {
    Get.dialog(
      ConfirmationDialogWidget(
        icon: Images.warning,
        title: 'are_you_sure_to_confirm'.tr,
        description: 'you_want_to_confirm_this_order'.tr,
        onYesPressed: () => _processOrderConfirmation(orderController, order),
      ),
      barrierDismissible: false,
    );
  }

  void _processOrderConfirmation(OrderController orderController, OrderModel order) {
    final orderVerificationActive = Get.find<SplashController>().configModel?.orderDeliveryVerification ?? false;
    final cod = order.paymentMethod == 'cash_on_delivery';

    if (orderVerificationActive || cod) {
      orderController.updateOrderStatus(
        order,
        AppConstants.confirmed,
        back: fromLocationScreen ? false : true,
        gotoDashboard: fromLocationScreen ? true : false,
      );
    }
  }

  void _handleOrderPickup(OrderController orderController, OrderModel order) {
    if (Get.find<ProfileController>().profileModel!.active == 1) {
      orderController.updateOrderStatus(
        order,
        AppConstants.pickedUp,
        back: fromLocationScreen ? false : true,
        gotoDashboard: fromLocationScreen ? true : false,
      );
    } else {
      showCustomSnackBar('make_yourself_online_first'.tr);
    }
  }

  void _handleOrderDelivery(OrderController orderController, OrderModel order) {
    final orderVerificationActive = Get.find<SplashController>().configModel?.orderDeliveryVerification ?? false;
    final cod = order.paymentMethod == 'cash_on_delivery';

    if (orderVerificationActive || cod) {
      Get.bottomSheet(
        VerifyDeliverySheetWidget(
          currentOrderModel: order,
          verify: orderVerificationActive,
          orderAmount: order.orderAmount,
          cod: cod,
        ),
        isScrollControlled: true,
      );
    } else {
      orderController.updateOrderStatus(
        order,
        AppConstants.delivered,
        back: fromLocationScreen ? false : true,
        gotoDashboard: fromLocationScreen ? true : false,
      );
    }
  }

  void _handleCompleteDelivery(OrderController orderController, OrderModel order) {
    final orderVerificationActive = Get.find<SplashController>().configModel?.orderDeliveryVerification ?? false;
    final cod = order.paymentMethod == 'cash_on_delivery';
    final partialPay = order.paymentMethod == 'partial_payment';

    if (orderVerificationActive) {
      Get.find<NotificationController>().sendDeliveredNotification(order.id);

      Get.bottomSheet(
        VerifyDeliverySheetWidget(
          currentOrderModel: order,
          verify: orderVerificationActive,
          orderAmount: partialPay ? order.payments![1].amount!.toDouble() : order.orderAmount,
          cod: cod || (partialPay && order.payments![1].paymentMethod == 'cash_on_delivery'),
        ),
        isScrollControlled: true,
      ).then((isSuccess) {
        if (isSuccess && (cod || (partialPay && order.payments![1].paymentMethod == 'cash_on_delivery'))) {
          Future.delayed(const Duration(milliseconds: 500), () {
            Get.bottomSheet(
              CollectMoneyDeliverySheetWidget(
                currentOrderModel: order,
                verify: orderVerificationActive,
                orderAmount: partialPay ? order.payments![1].amount!.toDouble() : order.orderAmount,
                cod: cod || (partialPay && order.payments![1].paymentMethod == 'cash_on_delivery'),
              ),
              isScrollControlled: true,
              isDismissible: false,
            );
          });
        }
      });
    } else {
      Get.bottomSheet(
        CollectMoneyDeliverySheetWidget(
          currentOrderModel: order,
          verify: orderVerificationActive,
          orderAmount: partialPay ? order.payments![1].amount!.toDouble() : order.orderAmount,
          cod: cod || (partialPay && order.payments![1].paymentMethod == 'cash_on_delivery'),
        ),
        isScrollControlled: true,
      );
    }
  }

  Widget _buildSliderIcon() {
    return Center(
      child: Icon(
        Get.find<LocalizationController>().isLtr ? Icons.double_arrow_sharp : Icons.keyboard_arrow_left,
        color: Colors.white,
        size: 20.0,
      ),
    );
  }

}
