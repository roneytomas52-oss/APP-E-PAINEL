import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/banner/controllers/banner_controller.dart';
import 'package:sixam_mart/features/flash_sale/controllers/flash_sale_controller.dart';
import 'package:sixam_mart/features/home/widgets/web/web_flash_sale_view_widget.dart';
import 'package:sixam_mart/features/home/widgets/web/web_new_banner_view_widget.dart';
import 'package:sixam_mart/features/home/widgets/web/web_recomanded_store_view_widget.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
class WebBannerSectionWidget extends StatelessWidget {
  const WebBannerSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BannerController>(builder: (bannerController) {
      return GetBuilder<StoreController>(builder: (storeController) {
        return GetBuilder<FlashSaleController>(builder: (flashController) {
          bool isFlashSaleActive = (flashController.flashSaleModel?.activeProducts != null && flashController.flashSaleModel!.activeProducts!.isNotEmpty);
          bool showBanner = bannerController.bannerImageList == null || bannerController.bannerImageList!.isNotEmpty;
          bool showRightSide = isFlashSaleActive || storeController.recommendedStoreList == null || storeController.recommendedStoreList!.isNotEmpty;

          return (showBanner || showRightSide) ? Row(crossAxisAlignment : CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
            if(showBanner) Expanded(
              flex: 3,
              child: bannerController.bannerImageList == null ?  const WebNewBannerViewWidget(isFeatured: false)
                  : WebNewBannerViewWidget(isFeatured: false, bannerHeight: showRightSide ? 350 : 400),
            ),

            if(showBanner && showRightSide) const SizedBox(width: Dimensions.paddingSizeDefault),

            if(showRightSide) Expanded(
              flex: 1,
              child: isFlashSaleActive ? WebFlashSaleViewWidget(showBanner: showBanner) : WebRecommendedStoreView(showingBanner: showBanner),
            ),
          ]) : const SizedBox();
        });
      });
    });
  }
}
