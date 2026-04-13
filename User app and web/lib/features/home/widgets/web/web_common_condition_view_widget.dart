import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/home/widgets/web/web_basic_medicine_nearby_view_widget.dart';
import 'package:sixam_mart/features/home/widgets/web/widgets/arrow_icon_button.dart';
import 'package:sixam_mart/features/home/widgets/web/widgets/medicine_item_card.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class WebCommonConditionViewWidget extends StatefulWidget {
  const WebCommonConditionViewWidget({super.key});

  @override
  State<WebCommonConditionViewWidget> createState() => _WebCommonConditionViewWidgetState();
}

class _WebCommonConditionViewWidgetState extends State<WebCommonConditionViewWidget> {

  ScrollController scrollController = ScrollController();
  ScrollController conditionsScrollController = ScrollController();
  bool showBackButton = false;
  bool showForwardButton = false;
  bool showConditionsBackButton = false;
  bool showConditionsForwardButton = false;
  bool isFirstTime = true;

  @override
  void initState() {

    if(Get.find<ItemController>().commonConditions != null && Get.find<ItemController>().commonConditions!.isNotEmpty) {
      Get.find<ItemController>().getConditionsWiseItem(Get.find<ItemController>().commonConditions![0].id!, false);
    }

    scrollController.addListener(_checkScrollPosition);
    conditionsScrollController.addListener(_checkConditionsScrollPosition);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkConditionsScrollPosition();
    });
    
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    conditionsScrollController.dispose();
    super.dispose();
  }

  void _checkScrollPosition() {
    setState(() {
      if (scrollController.position.pixels <= 0) {
        showBackButton = false;
      } else {
        showBackButton = true;
      }

      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent) {
        showForwardButton = false;
      } else {
        showForwardButton = true;
      }
    });
  }

  void _checkConditionsScrollPosition() {
    if (!conditionsScrollController.hasClients) return;
    
    setState(() {
      if (conditionsScrollController.position.maxScrollExtent <= 0) {
        // List is not scrollable
        showConditionsBackButton = false;
        showConditionsForwardButton = false;
      } else {
        // List is scrollable
        if (conditionsScrollController.position.pixels <= 0) {
          showConditionsBackButton = false;
        } else {
          showConditionsBackButton = true;
        }

        if (conditionsScrollController.position.pixels >= conditionsScrollController.position.maxScrollExtent) {
          showConditionsForwardButton = false;
        } else {
          showConditionsForwardButton = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(builder: (itemController) {

      if(itemController.conditionWiseProduct != null && itemController.conditionWiseProduct!.length > 4 && isFirstTime){
        showForwardButton = true;
        isFirstTime = false;
      }

      return (itemController.commonConditions != null && itemController.commonConditions!.isNotEmpty) ? Container(
        margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.1), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(children: [
          Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraLarge, horizontal: Dimensions.paddingSizeDefault),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('common_condition'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                const SizedBox(width: Dimensions.paddingSizeExtraOverLarge),
                const SizedBox(width: Dimensions.paddingSizeExtraOverLarge),

                Flexible(child: Stack(clipBehavior: Clip.none, children: [
                  SizedBox(
                    height: 30,
                    child: ListView.builder(
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault,
                              vertical: Dimensions.paddingSizeExtraSmall,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            ),
                            child: Center(
                              child: Text(
                                '${itemController.commonConditions![index].name}',
                                textAlign: TextAlign.center,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  if(showConditionsBackButton)
                    Positioned(
                      top: 0, bottom: 0, left: -15,
                      child: Center(
                        child: ArrowIconButton(
                          isRight: false,
                          onTap: () => conditionsScrollController.animateTo(
                            conditionsScrollController.offset - 200,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          ),
                        ),
                      ),
                    ),

                  if(showConditionsForwardButton)
                    Positioned(
                      top: 0, bottom: 0, right: -15,
                      child: Center(
                        child: ArrowIconButton(
                          onTap: () => conditionsScrollController.animateTo(
                            conditionsScrollController.offset + 200,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          ),
                        ),
                      ),
                    ),
                ])),
                const SizedBox(width: Dimensions.paddingSizeExtraOverLarge),
                const SizedBox(width: Dimensions.paddingSizeExtraOverLarge),
                InkWell(
                  onTap: () => Get.toNamed(RouteHelper.getCommonConditionsRoute()),
                  child: Text('see_all'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor, decoration: TextDecoration.underline)),
                ),
              ]),
            ),

          Stack(children: [
              SizedBox(
                height: 280, width: Get.width,
                child: itemController.conditionWiseProduct != null ? itemController.conditionWiseProduct!.isNotEmpty ? ListView.builder(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                  itemCount: itemController.conditionWiseProduct!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                      child: MedicineItemCard(item: itemController.conditionWiseProduct![index]),
                    );
                  },
                ) : Center(child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Text('no_product_available'.tr),
                )) : const MedicineCardShimmer(),
              ),

              if(showBackButton)
                Positioned(
                  top: 100, left: 0,
                  child: ArrowIconButton(
                    isRight: false,
                    onTap: () => scrollController.animateTo(scrollController.offset - (Dimensions.webMaxWidth / 3),
                        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut),
                  ),
                ),

              if(showForwardButton)
                Positioned(
                  top: 100, right: 0,
                  child: ArrowIconButton(
                    onTap: () => scrollController.animateTo(scrollController.offset + (Dimensions.webMaxWidth / 3),
                        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut),
                  ),
                ),

            ]),

        ]),
      ) : const SizedBox();
    });
  }
}

