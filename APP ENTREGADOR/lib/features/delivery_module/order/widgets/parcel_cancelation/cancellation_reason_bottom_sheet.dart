import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_text_field_widget.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/order_model.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/widgets/parcel_cancelation/custom_check_box_widget.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/widgets/parcel_cancelation/parcel_return_date_time_bottom_sheet.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class CancellationReasonBottomSheet extends StatefulWidget {
  final bool isBeforePickup;
  final int orderId;
  const CancellationReasonBottomSheet({super.key, required this.isBeforePickup, required this.orderId});

  @override
  State<CancellationReasonBottomSheet> createState() => _CancellationReasonBottomSheetState();
}

class _CancellationReasonBottomSheetState extends State<CancellationReasonBottomSheet> {

  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Get.find<OrderController>().clearSelectedParcelCancelReason();
    Get.find<OrderController>().getParcelCancellationReasons(isBeforePickup: widget.isBeforePickup);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(builder: (orderController) {
      return Container(
        width: context.width,
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

              Center(
                child: Container(
                  height: 5, width: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).disabledColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              orderController.parcelCancellationReasons != null && orderController.parcelCancellationReasons!.isNotEmpty ? Text('please_select_cancellation_reason'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)) : SizedBox(),

              orderController.parcelCancellationReasons != null ? orderController.parcelCancellationReasons!.isNotEmpty ? Flexible(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                  shrinkWrap: true,
                  itemCount: orderController.parcelCancellationReasons?.length,
                  itemBuilder: (context, index) {
                    final reason = orderController.parcelCancellationReasons?[index];
                    return CustomCheckBoxWidget(
                      title: reason?.reason ?? '',
                      value: orderController.isReasonSelected(reason?.reason ?? ''),
                      onClick: (bool? selected) {
                        orderController.toggleParcelCancelReason(reason!.reason!, selected ?? false);
                      },
                    );
                  },
                ),
              ) : SizedBox() : const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault), child: CircularProgressIndicator())),

              Text(
                'comments'.tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              CustomTextFieldWidget(
                controller: commentController,
                hintText: 'type_here_your_cancel_reason'.tr,
                showLabelText: false,
                maxLines: 2,
                inputType: TextInputType.multiline,
                inputAction: TextInputAction.done,
                capitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              CustomButtonWidget(
                buttonText: 'submit'.tr,
                isLoading: orderController.isLoading,
                onPressed: () async {
                  if((orderController.selectedParcelCancelReason != null && orderController.selectedParcelCancelReason!.isNotEmpty) || commentController.text.isNotEmpty) {
                    await orderController.updateOrderStatus(OrderModel(id: widget.orderId), parcel: true, AppConstants.canceled, reasons: orderController.selectedParcelCancelReason,
                      comment: commentController.text.trim(), stopOtherDataCall: true).then((success) async {
                      if(success) {
                        showCustomBottomSheet(
                          child: ParcelReturnDateTimeBottomSheet(orderId: widget.orderId, canceledDateTime: orderController.orderModel!.canceled!),
                        );
                        await orderController.getOrderWithId(widget.orderId);
                      }
                    });
                  }else{
                    if(orderController.selectedParcelCancelReason != null && orderController.selectedParcelCancelReason!.isNotEmpty){
                      showCustomSnackBar('you_did_not_select_any_reason'.tr);
                    }else if(commentController.text.isNotEmpty){
                      showCustomSnackBar('you_did_not_write_any_comment'.tr);
                    }
                  }
                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                child: InkWell(
                  onTap: () => Get.back(),
                  child: Center(
                    child: Text(
                      'continue_delivery'.tr,
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, decoration: TextDecoration.underline),
                    ),
                  ),
                ),
              ),

            ]),
          ),

          Positioned(
            top: 0, right: 0,
            child: InkWell(
              onTap: () => Get.back(),
              child: Icon(Icons.clear, color: Theme.of(context).disabledColor, size: 20),
            ),
          ),
        ]),
      );
    });
  }
}
