import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/screens/my_order_screen.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'running_order_screen.dart';

class OrderScreen extends StatefulWidget {
  final int? index;
  const OrderScreen({super.key, this.index});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> with SingleTickerProviderStateMixin {


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 2, child: Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: CustomAppBarWidget(title: 'my_orders'.tr, isBackButtonExist: false, bottom: _orderTabBar(context),),
      body: TabBarView(children: [RunningOrderScreen(), MyOrderScreen()])
    ));
  }
}

TabBar _orderTabBar(BuildContext context) {
  return TabBar(
    isScrollable: true,
    tabAlignment: TabAlignment.start,

    overlayColor: WidgetStateProperty.all(Colors.transparent),
    splashFactory: NoSplash.splashFactory,

    indicator: BoxDecoration(
      color: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(30),
    ),
    indicatorSize: TabBarIndicatorSize.tab,
    labelColor: Theme.of(context).cardColor,
    unselectedLabelColor: Theme.of(context).hintColor,
    labelStyle: robotoMedium.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: robotoMedium.copyWith(fontSize: 14),
    dividerColor: Colors.transparent,
    padding: const EdgeInsets.only(
      left: Dimensions.paddingSizeDefault,
      top: Dimensions.paddingSizeSmall,
      bottom: Dimensions.paddingSizeDefault,
      right: 40,
    ),
    tabs: [
      Tab(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('running_orders'.tr),
        ),
      ),
      Tab(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('my_orders'.tr),
        ),
      ),
    ],
  );
}

