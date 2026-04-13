import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import '../controllers/order_controller.dart';
import '../widgets/history_order_widget.dart';
import '../widgets/selected_type_button.dart';

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({super.key});

  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Get.find<OrderController>().getCompletedOrders(1, willUpdate: false);
    Get.find<OrderController>().getOrderCount('history');
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent
          && Get.find<OrderController>().completedOrderList != null
          && !Get.find<OrderController>().paginate) {
        int pageSize = (Get.find<OrderController>().pageSize! / 10).ceil();
        if (Get.find<OrderController>().offset < pageSize) {
          Get.find<OrderController>().setOffset(Get.find<OrderController>().offset+1);
          debugPrint('end of the page');
          Get.find<OrderController>().showBottomLoader();
          Get.find<OrderController>().getCompletedOrders(Get.find<OrderController>().offset);
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
    return Stack(children: [
        GetBuilder<OrderController>(builder: (orderController) {
          return orderController.completedOrderList != null ? orderController.completedOrderList!.isNotEmpty ?
          RefreshIndicator(
            onRefresh: () async {
              await orderController.getCompletedOrders(1);
              await orderController.getOrderCount('history');
            },
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(child: SizedBox(width: 1170,
                child: Column(children: [
                  GetBuilder<OrderController>(
                    id: 'order_count',
                    builder: (controller) {
                      return (controller.historyOrderCountList != null && controller.historyOrderCountList!.isNotEmpty)
                          ? SizedBox(height: 40 + Dimensions.paddingSizeExtraSmall) : const SizedBox();
                    },
                  ),

                  ListView.builder(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    itemCount: orderController.completedOrderList!.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return HistoryOrderWidget(orderModel: orderController.completedOrderList![index], isRunning: false, index: index);
                    },
                  ),

                  orderController.paginate ? const Center(child: Padding(
                      padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: CircularProgressIndicator()
                  )) : const SizedBox(),
                ]),
              )),
            ),
          ) : Center(child: Text('no_order_found'.tr)) : const Center(child: CircularProgressIndicator());
        }),

        GetBuilder<OrderController>(
          builder: (orderController) {
            return (orderController.filteredHistoryOrderCountList.isNotEmpty)
            ? Positioned(top: 0, left: 0, right: 0, child: Container(
              height: 40,
              margin: EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
              padding: EdgeInsets.only( left: Dimensions.paddingSizeSmall),
              color: Theme.of(context).cardColor,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: orderController.filteredHistoryOrderCountList.length,
                  itemBuilder: (context, index) {
                  final status = orderController.filteredHistoryOrderCountList[index];
                  return SelectedTypeButton(
                    title: status.key ?? '',
                    count: status.count ?? 0,
                    orderController: orderController,
                    fromHistory: true,
                  );
                }
              )
            )) : const SizedBox();
          }
        ),
      ],
    );
  }
}
