import 'package:flutter/cupertino.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/widgets/item_view_all_filter_bottom_sheet.dart';
import 'package:sixam_mart/features/item/widgets/item_view_all_sort_bottom_sheet.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/item_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/features/home/widgets/web/widgets/arrow_icon_button.dart';
import 'package:sixam_mart/util/styles.dart';

class PopularItemScreen extends StatefulWidget {
  final bool isPopular;
  final bool isSpecial;
  final bool isCommonCondition;
  const PopularItemScreen({super.key, required this.isPopular, required this.isSpecial, this.isCommonCondition = false});

  @override
  State<PopularItemScreen> createState() => _PopularItemScreenState();
}

class _PopularItemScreenState extends State<PopularItemScreen> {

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController conditionsScrollController = ScrollController();
  bool showBackButton = false;
  bool showForwardButton = false;

  @override
  void initState() {
    super.initState();
    ItemController itemController = Get.find<ItemController>();
    
    if(widget.isCommonCondition) {
      if(itemController.commonConditions != null && itemController.commonConditions!.isNotEmpty) {
        itemController.getConditionsWiseItem(itemController.commonConditions![0].id!, false);
      }
      conditionsScrollController.addListener(_checkScrollPosition);
    } else {
      itemController.setOffset(1);
      itemController.clearFilters(isPopular: widget.isPopular, isSpecial: widget.isSpecial);
      itemController.clearSearch(withUpdate: false);
    }
  }

  @override
  void dispose() {
    conditionsScrollController.dispose();
    super.dispose();
  }

  void _checkScrollPosition() {
    setState(() {
      if (conditionsScrollController.position.pixels <= 0) {
        showBackButton = false;
      } else {
        showBackButton = true;
      }

      if (conditionsScrollController.position.pixels >= conditionsScrollController.position.maxScrollExtent) {
        showForwardButton = false;
      } else {
        showForwardButton = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isShop = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if(!widget.isCommonCondition) {
          Get.find<ItemController>().resetFilters(isPopular: widget.isPopular, isSpecial: widget.isSpecial);
          Get.find<ItemController>().clearSearch();
        }
      },
      child: GetBuilder<ItemController>(builder: (itemController) {
        return Scaffold(
          appBar: CustomAppBar(
            key: scaffoldKey,
            title: widget.isCommonCondition ? 'common_condition'.tr : widget.isPopular ? isShop ? 'most_popular_products'.tr : 'most_popular_items'.tr : widget.isSpecial ? 'special_offer'.tr : 'best_reviewed_item'.tr,
            showCart: true,
            type: widget.isCommonCondition ? null : widget.isPopular ? itemController.popularType : widget.isSpecial ? itemController.discountedType : itemController.reviewType,
            onVegFilterTap: widget.isCommonCondition ? null : (String type) {
              if(widget.isPopular) {
                itemController.getPopularItemList(notify: true, offset: '1');
              }else if(widget.isSpecial){
                itemController.getDiscountedItemList(notify: true, offset: '1');
              }else {
                itemController.getReviewedItemList(notify: true, offset: '1');
              }
            },
          ),
          endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
          body: SingleChildScrollView(child: FooterView(child: Column(children: [

            ResponsiveHelper.isDesktop(context) ? widget.isCommonCondition ? Column(children: [
                Container(
                  height: 64,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
                  alignment: Alignment.center,
                  child: Center(child: Text('common_condition'.tr, style: robotoMedium)),
                ),
                Container(
                  width: Dimensions.webMaxWidth,
                  margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeLarge),
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge, horizontal: Dimensions.paddingSizeDefault),
                  child: Stack(
                    children: [
                      SizedBox(height: 40,
                        child: itemController.commonConditions != null && itemController.commonConditions!.isNotEmpty ? ListView.builder(
                          controller: conditionsScrollController,
                          shrinkWrap: true,
                          itemCount: itemController.commonConditions!.length,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            bool isSelected = itemController.selectedCommonCondition == index;
                            return InkWell(
                              hoverColor: Colors.transparent,
                              onTap: () => itemController.selectCommonCondition(index),
                              child: Container(
                                margin: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                                decoration: BoxDecoration(
                                  color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                ),
                                child: Center(
                                  child: Text('${itemController.commonConditions![index].name}',
                                    textAlign: TextAlign.center,
                                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color),
                                  ),
                                ),
                              ),
                            );
                          },
                        ) : const SizedBox(),
                      ),

                    if(showBackButton)
                      Positioned(top: 0, bottom: 0, left: 0,
                        child: Center(child: ArrowIconButton(
                          isRight: false,
                          onTap: () => conditionsScrollController.animateTo(
                            conditionsScrollController.offset - 200,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          ),
                        )),
                      ),

                    if(showForwardButton)
                      Positioned(top: 0, bottom: 0, right: 0,
                        child: Center(child: ArrowIconButton(
                          onTap: () => conditionsScrollController.animateTo(
                            conditionsScrollController.offset + 200,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ]) : Container(height: 64,
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
                    alignment: Alignment.center,
                    child: Center(
                      child: SizedBox(
                        width: Dimensions.webMaxWidth,
                        child: Stack(alignment: Alignment.center, children: [

                          Center(child: Text(
                            widget.isPopular ? isShop ? 'most_popular_products'.tr : 'most_popular_items'.tr : widget.isSpecial ? 'special_offer'.tr : 'best_reviewed_item'.tr,
                            style: robotoMedium,
                          )),

                          Positioned(
                            right: 10,
                            child: Row(children: [
                              InkWell(
                                onTap: () {
                                  Get.dialog(Dialog(child: ItemViewAllSortBottomSheet(isPopular: widget.isPopular, isSpecial: widget.isSpecial, fromDialog: true)));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    border: Border.all(color: Theme.of(context).hintColor),
                                  ),
                                  child: Icon(CupertinoIcons.sort_down, color: Theme.of(context).hintColor, size: 18),
                                ),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeSmall),

                              InkWell(
                                onTap: () {
                                  List<double?> prices = [];
                                  for (var product in itemController.discountedItemList!) {
                                    prices.add(product.price);
                                  }
                                  prices.sort();
                                  double? maxValue = prices.isNotEmpty ? prices.last : 99999999;
                                  Get.dialog(Dialog(child: ItemViewAllFilterBottomSheet(maxValue: maxValue, isPopular: widget.isPopular, isSpecial: widget.isSpecial, fromDialog: true)));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    border: Border.all(color: Theme.of(context).primaryColor),
                                  ),
                                  child: Icon(Icons.filter_list, color: Theme.of(context).primaryColor, size: 18),
                                ),
                              ),
                            ]),
                          ),
                        ]),
                      ),
                    ),
                  )
                : const SizedBox(),

            SizedBox(
              width: Dimensions.webMaxWidth,
              child: Column(children: [
                ItemsView(
                  isStore: false, stores: null,
                  items: widget.isCommonCondition ? itemController.conditionWiseProduct : widget.isPopular ? itemController.popularItemList : widget.isSpecial ? itemController.discountedItemList : itemController.reviewedItemList,
                ),
                if (!widget.isCommonCondition && itemController.hasMoreData(isPopular: widget.isPopular, isSpecial: widget.isSpecial))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: CustomButton(
                    buttonText: 'view_more'.tr,
                    width: 180,
                    isLoading: itemController.isLoading,
                    onPressed: () {
                      itemController.setOffset(itemController.offset + 1);

                      itemController.showBottomLoader();

                      if (widget.isPopular) {
                        itemController.getPopularItemList(dataSource: DataSourceEnum.client, offset: itemController.offset.toString());
                      } else if (widget.isSpecial) {
                        itemController.getDiscountedItemList(dataSource: DataSourceEnum.client, offset: itemController.offset.toString());
                      } else {
                        itemController.getReviewedItemList(dataSource: DataSourceEnum.client, offset: itemController.offset.toString());
                      }
                    },
                  ),
                ),
              ]),
            ),
          ]))),
        );
      }),
    );
  }
}
