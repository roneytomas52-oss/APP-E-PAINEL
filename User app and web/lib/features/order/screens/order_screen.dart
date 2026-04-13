import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_order/controllers/taxi_order_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_order/widgets/trip_order_view_widget.dart';
import 'package:sixam_mart/features/ride_share_module/ride_order/controllers/ride_controller.dart';
import 'package:sixam_mart/features/ride_share_module/ride_order/widgets/ride_order_view_widget.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/taxi_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/features/order/widgets/guest_track_order_input_view_widget.dart';
import 'package:sixam_mart/features/order/widgets/order_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderScreen extends StatefulWidget {
  final String? index;
  const OrderScreen({super.key, this.index = 'orders'});

  @override
  OrderScreenState createState() => OrderScreenState();
}

class OrderScreenState extends State<OrderScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  bool _isLoggedIn = AuthHelper.isLoggedIn();
  List<String> type = [];
  String selectType = 'orders';
  bool haveTaxiModule = false;
  ScrollController? scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    initSetup();
  }

  void initSetup() {
    _isLoggedIn = AuthHelper.isLoggedIn();

    if(_isLoggedIn) {
      type = ['orders', 'trips', 'rides'];
      if(!TaxiHelper.haveTaxiModule()) {
        type.remove('trips');
      }
      if(!TaxiHelper.haveRideModule()) {
        type.remove('rides');
      }
    }else {
      type = ['orders', 'trips'];
    }

    if(!TaxiHelper.haveTaxiServiceRideModules()) {
      type = ['orders',];
    } else if (!TaxiHelper.haveTaxiServiceRideModules() && !AuthHelper.isLoggedIn()) {
      type = ['orders'];
    } else if (!TaxiHelper.haveTaxiServiceRideModules() && AuthHelper.isLoggedIn()) {
      type = ['orders',];
    }

    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    selectType = widget.index!;
    haveTaxiModule = TaxiHelper.haveTaxiServiceRideModules();

    initCall();
  }

  void initCall(){
    if(AuthHelper.isLoggedIn()) {
      if(selectType == "orders") {
        Get.find<OrderController>().getRunningOrders(1);
        Get.find<OrderController>().getHistoryOrders(1);
      } else if(selectType == 'trips') {
        Get.find<TaxiOrderController>().getTripList(1, isRunning: true);
        Get.find<TaxiOrderController>().getTripList(1, isRunning: false);
      }
      else if(selectType == 'rides') {
        Get.find<RideController>().getRideList(1, isRunning: true);
        Get.find<RideController>().getRideList(1, isRunning: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _isLoggedIn = AuthHelper.isLoggedIn();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: haveTaxiModule && !ResponsiveHelper.isDesktop(context) ? null : CustomAppBar(title: 'my_orders'.tr, backButton: ResponsiveHelper.isDesktop(context)),
      endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
      body: SafeArea(
        child: GetBuilder<OrderController>(
          builder: (orderController) {
            return Column(
              children: [

                haveTaxiModule && !ResponsiveHelper.isDesktop(context) ? Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.1), blurRadius: 5, offset: const Offset(0, 10))],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Text('my_orders'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    SizedBox(
                      height: 30,
                      child: ListView.builder(
                          itemCount: type.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            bool selected = type[index] == selectType;
                            return Container(
                              decoration: BoxDecoration(
                                color: selected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                border: Border.all(color: Theme.of(context).disabledColor, width: 0.3),
                              ),
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                              child: CustomInkWell(
                                onTap: () {
                                  setState(() {
                                    selectType = type[index];
                                  });
                                  initCall();
                                },
                                radius: Dimensions.radiusLarge,
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                child: Text(type[index].tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: selected ? Colors.white : Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.7))),
                              ),
                            );
                          }),
                    ),

                  ]),
                ) : const SizedBox(),

                _isLoggedIn ? Expanded(
                  child: Column(children: [

                    ResponsiveHelper.isDesktop(context) ? Container(
                      color: ResponsiveHelper.isDesktop(context) ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.transparent,
                      child: Column(children: [
                        ResponsiveHelper.isDesktop(context) ? Center(child: Padding(
                          padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                          child: Text('my_orders'.tr, style: robotoMedium),
                        )) : const SizedBox(),

                        Center(
                          child: SizedBox(
                            width: Dimensions.webMaxWidth,
                            child: Align(
                              alignment: ResponsiveHelper.isDesktop(context) ? Alignment.centerLeft : Alignment.center,
                              child: Container(
                                width: ResponsiveHelper.isDesktop(context) ? 300 : Dimensions.webMaxWidth,
                                color: ResponsiveHelper.isDesktop(context) ? Colors.transparent : Theme.of(context).cardColor,
                                child: TabBar(
                                  controller: _tabController,
                                  indicatorColor: Theme.of(context).primaryColor,
                                  indicatorWeight: 3,
                                  labelColor: Theme.of(context).primaryColor,
                                  unselectedLabelColor: Theme.of(context).disabledColor,
                                  unselectedLabelStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                                  labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                                  tabs: [
                                    Tab(text: 'running'.tr),
                                    Tab(text: 'history'.tr),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ) : Column(children: [

                      Align(
                        alignment: Alignment.centerLeft,
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: haveTaxiModule ? true : false,
                          padding: EdgeInsets.zero,
                          tabAlignment: haveTaxiModule ? TabAlignment.start : null,
                          indicatorColor: Theme.of(context).primaryColor,
                          indicatorWeight: 3,
                          labelColor: Theme.of(context).primaryColor,
                          unselectedLabelColor: Theme.of(context).disabledColor,
                          unselectedLabelStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                          labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                          tabs: [
                            Tab(text: 'running'.tr),
                            Tab(text: 'history'.tr),
                          ],
                        ),
                      ),
                    ]),

                    selectType == 'orders' ? Expanded(child: TabBarView(
                      controller: _tabController,
                      children: const [
                        OrderViewWidget(isRunning: true),
                        OrderViewWidget(isRunning: false),
                      ],
                    )) : selectType == 'trips' ? Expanded(child: TabBarView(
                     controller: _tabController,
                     children: const [
                       TripOrderViewWidget(isRunning: true),
                       TripOrderViewWidget(isRunning: false),
                     ],
                   )) : Expanded(child: TabBarView(
                      controller: _tabController,
                      children: const [
                        RideOrderViewWidget(isRunning: true),
                        RideOrderViewWidget(isRunning: false),
                      ],
                    )),

                  ]),
                ) : GuestTrackOrderInputViewWidget(selectType: selectType,  callBack: (success) {
                  if(success) {
                    initSetup();
                    setState(() {});
                  }
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
