import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/order_shimmer_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/order_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/title_widget.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';

class ActiveOrderWidget extends StatelessWidget {
  final Function()? onNavigateToOrders;
  const ActiveOrderWidget({super.key, this.onNavigateToOrders});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(builder: (orderController) {

      bool hasActiveOrder = orderController.currentOrderList == null || orderController.currentOrderList!.isNotEmpty;
      bool hasMoreOrder = orderController.currentOrderList != null && orderController.currentOrderList!.length > 1;

      return Container(
        decoration: BoxDecoration(
          color: hasActiveOrder? Theme.of(context).primaryColor.withValues(alpha: 0.1) : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        child: Column(children: [
          const SizedBox(height: Dimensions.paddingSizeSmall),

          hasActiveOrder ? TitleWidget(
            title: 'active_order'.tr, showOrderCount: true, orderCount: orderController.currentOrderList?.length ?? 0,
            onTap: hasMoreOrder ? () {
              onNavigateToOrders?.call();
            } : null,
          ) : const SizedBox(),
          SizedBox(height: hasActiveOrder ? Dimensions.paddingSizeExtraSmall : 0),

          orderController.currentOrderList == null ? OrderShimmerWidget(
            isEnabled: orderController.currentOrderList == null,
          ) : orderController.currentOrderList!.isNotEmpty ? OrderWidget(
            orderModel: orderController.currentOrderList![0], isRunningOrder: true, orderIndex: 0, cardWidth: context.width * 0.9,
          ) : const SizedBox(),
          SizedBox(height: hasActiveOrder ? Dimensions.paddingSizeDefault : 0),

        ]),
      );
    });
  }
}
