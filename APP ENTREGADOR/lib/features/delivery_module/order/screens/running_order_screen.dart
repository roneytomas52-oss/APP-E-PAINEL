import 'package:sixam_mart_delivery/common/widgets/order_shimmer_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/sliver_delegate.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/widgets/selected_type_button.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/widgets/history_order_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class RunningOrderScreen extends StatefulWidget {
  const RunningOrderScreen({super.key});


  @override
  State<RunningOrderScreen> createState() => _RunningOrderScreenState();
}

class _RunningOrderScreenState extends State<RunningOrderScreen> {
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Get.find<OrderController>().getRunningOrders(1, willUpdate: false, status: 'all');
    Get.find<OrderController>().getOrderCount('current');
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent
          && Get.find<OrderController>().currentOrderList != null
          && !Get.find<OrderController>().paginate) {
        int pageSize = (Get.find<OrderController>().pageSize! / 10).ceil();
        if (Get.find<OrderController>().offset < pageSize) {
          Get.find<OrderController>().setOffset(Get.find<OrderController>().offset+1);
          debugPrint('end of the page - running orders');
          Get.find<OrderController>().showBottomLoader();
          Get.find<OrderController>().getRunningOrders(Get.find<OrderController>().offset);
        }
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  GetBuilder<OrderController>(builder: (orderController) {
      return orderController.currentOrderList != null ? orderController.currentOrderList!.isNotEmpty ? RefreshIndicator(
        onRefresh: () async {
          await orderController.getRunningOrders(1);
          await orderController.getOrderCount('current');
        },
        child: Container(
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          child:  CustomScrollView(
            controller: scrollController,
            slivers: [
                SliverPersistentHeader(pinned: true, delegate: SliverDelegate(height: 50,
                  child: Container(
                    margin: EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                    color: Theme.of(context).cardColor,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: orderController.filteredOrderCountList.length,
                      itemBuilder: (context, index) {
                        final status = orderController.filteredOrderCountList[index];
                        return SelectedTypeButton(
                          title: status.key ?? '',
                          count: status.count ?? 0,
                          orderController: orderController,
                          fromHistory: false,
                        );
                      }
                    )
                  )
                )),

              if (orderController.currentOrderList != null) orderController.currentOrderList!.isNotEmpty ? SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {return HistoryOrderWidget(orderModel: orderController.currentOrderList![index], isRunning: true, index: index);},
                  childCount: orderController.currentOrderList!.length
                )
              ) : SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50, bottom: 100),
                  child: Center(child: Text('no_order_found'.tr)),
                )
              )
              else SliverList(delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return OrderShimmerWidget(isEnabled: orderController.currentOrderList == null);
               },
               childCount: 10,
              )),

              if (orderController.paginate)
                SliverToBoxAdapter(child: Center(child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: CircularProgressIndicator(),
                ))),
            ],
          ),
        ),
                // itemCount: orderController.currentOrderList!.length,
      ) : Center(child: Text('no_order_found'.tr)) : const Center(child: CircularProgressIndicator());
    });
  }
}
