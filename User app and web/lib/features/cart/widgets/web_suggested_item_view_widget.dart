import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/home/widgets/web/widgets/arrow_icon_button.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/item_widget.dart';

class WebSuggestedItemViewWidget extends StatefulWidget {
  final List<CartModel> cartList;
  const WebSuggestedItemViewWidget({super.key, required this.cartList});

  @override
  State<WebSuggestedItemViewWidget> createState() => _WebSuggestedItemViewWidgetState();
}

class _WebSuggestedItemViewWidgetState extends State<WebSuggestedItemViewWidget> {
  ScrollController scrollController = ScrollController();
  bool showBackButton = false;
  bool showForwardButton = false;
  bool isFirstTime = true;

  @override
  void initState() {
    scrollController.addListener(_checkScrollPosition);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GetBuilder<StoreController>(builder: (storeController) {
        List<Item>? suggestedItems;
        if(storeController.cartSuggestItemModel != null){
          suggestedItems = [];
          List<int> cartIds = [];
          for (CartModel cartItem in widget.cartList) {
            cartIds.add(cartItem.item!.id!);
          }
          for (Item item in storeController.cartSuggestItemModel!.items!) {
            if(!cartIds.contains(item.id)){
              suggestedItems.add(item);
            }
          }
        }

        if(suggestedItems != null && suggestedItems.length > 4 && isFirstTime){
          showForwardButton = true;
          isFirstTime = false;
        }

        return storeController.cartSuggestItemModel != null && suggestedItems!.isNotEmpty ? GetBuilder<CartController>(
            builder: (cartController) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: const  BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
                  color: Theme.of(context).cardColor,
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                ),
                margin: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge) : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                      child: Text('you_may_also_like'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
                    ),

                    Stack(children: [
                      SizedBox(
                        height: 120, width: Get.width,
                        child: ListView.builder(
                            controller: scrollController,
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: suggestedItems!.length,
                            padding: EdgeInsets.only(
                              left: Dimensions.paddingSizeDefault,
                              right: Get.find<LocalizationController>().isLtr ? 0 : Dimensions.paddingSizeDefault,
                            ),
                            itemBuilder: (context, index){
                              return SizedBox(
                                width: 290,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    bottom: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeDefault,
                                    left: Get.find<LocalizationController>().isLtr ? 0 : Dimensions.paddingSizeDefault,
                                    right: Get.find<LocalizationController>().isLtr ? Dimensions.paddingSizeDefault : 0,
                                  ),
                                  child: ItemWidget(
                                    imageHeight: 90, imageWidth: 90, isCornerTag: true,
                                    isStore: false, item: suggestedItems![index], fromCartSuggestion: true,
                                    store: null, index: index, length: null, isCampaign: false, inStore: true,
                                  ),
                                ),
                              );
                            }),
                      ),

                      if(showBackButton)
                        Positioned(
                          top: 40, left: 0,
                          child: ArrowIconButton(
                            isRight: false,
                            onTap: () => scrollController.animateTo(scrollController.offset - (Dimensions.webMaxWidth / 3),
                                duration: const Duration(milliseconds: 500), curve: Curves.easeInOut),
                          ),
                        ),

                      if(showForwardButton)
                        Positioned(
                          top: 40, right: 0,
                          child: ArrowIconButton(
                            onTap: () => scrollController.animateTo(scrollController.offset + (Dimensions.webMaxWidth / 3),
                                duration: const Duration(milliseconds: 500), curve: Curves.easeInOut),
                          ),
                        ),

                    ]),
                  ],
                ),
              );
            }
        ) : const SizedBox();
      }),
    );
  }
}
