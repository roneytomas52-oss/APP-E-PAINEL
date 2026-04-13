import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/common/widgets/filter_bottom_sheet_widget.dart';
import 'package:sixam_mart_delivery/features/language/controllers/language_controller.dart';
import 'package:sixam_mart_delivery/features/my_account/controllers/my_account_controller.dart';
import 'package:sixam_mart_delivery/features/my_account/widgets/reports/loyalty_view_widget.dart';
import 'package:sixam_mart_delivery/features/my_account/widgets/reports/order_view_widget.dart';
import 'package:sixam_mart_delivery/features/my_account/widgets/reports/refer_view_widget.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class MyEarningScreen extends StatefulWidget {
  const MyEarningScreen({super.key});

  @override
  State<MyEarningScreen> createState() => _MyEarningScreenState();
}

class _MyEarningScreenState extends State<MyEarningScreen> {

  final ScrollController scrollController = ScrollController();
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();

    Get.find<MyAccountController>().resetEarningFilter(isUpdate: false);
    Get.find<MyAccountController>().setOffset(1);
    Get.find<MyAccountController>().setEarningType('all_types_earning');
    _getFilteredEarnings();

    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent
          && Get.find<MyAccountController>().earningList != null
          && !Get.find<MyAccountController>().isLoading) {
        int pageSize = (Get.find<MyAccountController>().pageSize! / 10).ceil();
        if (Get.find<MyAccountController>().offset < pageSize) {
          Get.find<MyAccountController>().setOffset(Get.find<MyAccountController>().offset+1);
          debugPrint('end of the page');
          Get.find<MyAccountController>().showBottomLoader();
          _getFilteredEarnings();
        }
      }
    });
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    Get.find<MyAccountController>().resetEarningFilter();
    Get.find<MyAccountController>().setOffset(1);
    Get.find<MyAccountController>().setEarningType('all_types_earning');
    _getFilteredEarnings();
  }

  void _getFilteredEarnings({bool fromFilter = false}) {
    if (_selectedTabIndex == 0) {
      // Order
      Get.find<MyAccountController>().getEarningReport(
        offset: Get.find<MyAccountController>().offset.toString(),
        startDate: Get.find<MyAccountController>().from, endDate: Get.find<MyAccountController>().to,
        type: Get.find<MyAccountController>().selectedEarningType,
        dateRange: Get.find<MyAccountController>().selectedDateType,
        fromFilter: fromFilter,
      );
    } else if (_selectedTabIndex == 1) {
      // Referral
      Get.find<MyAccountController>().getReferralReport(
        offset: Get.find<MyAccountController>().offset.toString(),
        startDate: Get.find<MyAccountController>().from, endDate: Get.find<MyAccountController>().to,
        type: Get.find<MyAccountController>().selectedEarningType,
        fromFilter: fromFilter, //Get.find<MyAccountController>().isFiltered,
        dateRange: Get.find<MyAccountController>().selectedDateType,
      );
    } else {
      // Loyalty Point
      Get.find<MyAccountController>().getLoyaltyReport(
        offset: Get.find<MyAccountController>().offset.toString(),
        startDate: Get.find<MyAccountController>().from, endDate: Get.find<MyAccountController>().to,
        type: Get.find<MyAccountController>().selectedEarningType,
        fromFilter: fromFilter,//Get.find<MyAccountController>().isFiltered,
        dateRange: Get.find<MyAccountController>().selectedDateType,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyAccountController>(builder: (myAccountController) {
      return Scaffold(
        appBar: CustomAppBarWidget(
          title: 'my_earning'.tr,
          actionWidget: Row(children: [

            InkWell(
              onTap: () {
                myAccountController.downloadEarningInvoice(
                  dmId: Get.find<ProfileController>().profileModel!.id!,
                  earningType: _selectedTabIndex == 0 ? null : _selectedTabIndex == 1 ? 'referral_earning' : 'loyalty_earning',
                );
              },
              child: Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: !myAccountController.downloadLoading! ? Icon(Icons.download, size: 20,
                  color: Theme.of(context).cardColor,
                ) : const SizedBox(
                  width: 20, height: 20,
                  child: Padding(
                    padding: EdgeInsets.all(3),
                    child: Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall + 2),

            InkWell(
              onTap: () {
                // Get.toNamed(RouteHelper.getMyEarningFilterRoute());
                Get.bottomSheet(FilterBottomSheetWidget(
                  startDate: myAccountController.from,
                  endDate: myAccountController.to,
                  type: myAccountController.selectedDateType,
                  onApply: (dateRange, startDate, endDate) async {
                    if(startDate != null && endDate != null) {
                      await myAccountController.setDateRange(from: startDate, to: endDate);
                    }
                    if(dateRange != null) {
                      myAccountController.setDateType(dateRange);
                      _getFilteredEarnings(fromFilter: true);
                    }
                  },
                  onReset: () {
                    myAccountController.resetEarningFilter();
                    _getFilteredEarnings();
                  },
                ));
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    child: Icon(Icons.filter_list_sharp, size: 20,
                      color: Theme.of(context).cardColor,
                    ),
                  ),

                  if(myAccountController.isFiltered)
                    Positioned(
                      top: -4, right: -4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          height: 10, width: 10,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: Get.find<LocalizationController>().isLtr ? 0 : Dimensions.paddingSizeSmall + 2),
          ]),
        ),

        body: GetBuilder<MyAccountController>(builder: (myAccountController) {
          double totalEarning = (myAccountController.earningReportModel?.totalDeliveryCharge ?? 0) + (myAccountController.earningReportModel?.totalDmTips ?? 0) + (myAccountController.earningReportModel?.totalReferal ?? 0) + (myAccountController.earningReportModel?.totalLoyaltyPointEarning ?? 0);
          
          return CustomScrollView(
            controller: scrollController,
            slivers: [
              // Earning Cards Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: SizedBox(
                    height: 120,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        _earningCard(context: context, image: Images.totalEarning, price: totalEarning, title: 'total_earning'.tr),
                        _earningCard(context: context, image: Images.deliveryFeeEarned, price: myAccountController.earningReportModel?.totalDeliveryCharge??0, title: 'delivery_fee_earned'.tr),
                        _earningCard(context: context, image: Images.deliveryTipsEarned, price: myAccountController.earningReportModel?.totalDmTips??0, title: 'delivery_tips_earned'.tr),
                        _earningCard(context: context, image: Images.refferalIcon, price: myAccountController.earningReportModel?.totalReferal??0, title: 'referral'.tr),
                        _earningCard(context: context, image: Images.loyaltyPoint2, price: myAccountController.earningReportModel?.totalLoyaltyPointEarning??0, title: 'loyalty_point'.tr),
                      ]),
                    ),
                  ),
                ),
              ),

              // Earning Statement Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('earning_statement'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).hintColor)),
                    Text('${myAccountController.pageSize ?? 0} ${'result_found'.tr}', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).hintColor)),
                  ]),
                ),
              ),
              
              const SliverToBoxAdapter(
                child: SizedBox(height: Dimensions.paddingSizeSmall),
              ),

              // Sticky Tab Bar
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyTabBarDelegate(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                    child: Row(children: [
                      _buildTab(
                        context: context,
                        title: 'order'.tr,
                        index: 0,
                      ),
                      _buildTab(
                        context: context,
                        title: 'referral'.tr,
                        index: 1,
                      ),
                      _buildTab(
                        context: context,
                        title: 'loyalty_point'.tr,
                        index: 2,
                      ),
                    ]),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: Dimensions.paddingSizeSmall),
              ),

              // Earnings List
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                sliver: SliverToBoxAdapter(
                  child: CustomCard(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: _selectedTabIndex == 0 ? OrderViewWidget(myAccountController: myAccountController)
                        : _selectedTabIndex == 1 ? ReferViewWidget(myAccountController: myAccountController)
                        : LoyaltyViewWidget(myAccountController: myAccountController),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: Dimensions.paddingSizeDefault),
              ),
            ],
          );
        }),
      );
    });
  }

  Widget _buildTab({required BuildContext context, required String title, required int index}) {
    return InkWell(
      onTap: () {
        if(index != _selectedTabIndex) {
          _onTabChanged(index);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
          color: _selectedTabIndex == index ? Theme.of(context).primaryColor : null,
          border: Border.all(color: _selectedTabIndex == index ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),
        ),
        margin: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall, bottom: Dimensions.paddingSizeExtraSmall, right: Dimensions.paddingSizeSmall),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        alignment: Alignment.center,
        child: Text(
          title,
          style: robotoMedium.copyWith(
            color: _selectedTabIndex == index ? Theme.of(context).cardColor : Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.6),
            fontSize: Dimensions.fontSizeLarge,
          ),
        ),
      ),
    );
  }

  Widget _earningCard({required BuildContext context, required String image, required double price, required String title}) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Image.asset(image, height: 30, width: 30),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        Text(
          PriceConverterHelper.convertPrice(price),
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall - 2),

        Text(title, style: robotoMedium.copyWith(color: Theme.of(context).hintColor)),
      ]),
    );
  }
}

// Sticky Tab Bar Delegate
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 50;

  @override
  double get maxExtent => 50;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return oldDelegate.maxExtent != 50 || oldDelegate.minExtent != 50 || child != oldDelegate.child;
  }
}
