import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/common/widgets/hover/text_hover.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';

class WebRecommendedStoreView extends StatelessWidget {
  final bool showingBanner;
  const WebRecommendedStoreView({super.key, required this.showingBanner});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(builder: (storeController) {
      bool isFood = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.food;

      return storeController.recommendedStoreList != null ? Container(
        margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
        width: Get.width, height: !showingBanner ? 150 : 302,
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color:  Theme.of(context).disabledColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(children: [
          Text(isFood ? 'recommended_restaurants'.tr : 'recommended_stores'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          !showingBanner ? SizedBox(
            height: 80,
            child: storeController.recommendedStoreList!.isNotEmpty ?
            ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: storeController.recommendedStoreList!.length > 9 ? 9 : storeController.recommendedStoreList!.length,
              separatorBuilder: (context, index) => const SizedBox(width: Dimensions.paddingSizeDefault),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: (){
                    Get.toNamed(RouteHelper.getStoreRoute(id: storeController.recommendedStoreList![index].id, page: 'store', slug: storeController.recommendedStoreList![index].slug??''),
                      arguments: StoreScreen(store: storeController.recommendedStoreList![index], fromModule: false),
                    );
                  },
                  child: TextHover(
                      builder: (hovered) {
                        return Container(
                          width: 108,
                          height: 108,
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            child: CustomImage(
                              isHovered: hovered,
                              image: '${storeController.recommendedStoreList![index].logoFullUrl}',
                              fit: BoxFit.cover, height: 50, width: 70,
                            ),
                          ),
                        );
                      }
                  ),
                );
              },
            ) : Center(child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Text(isFood ? 'currently_no_recommended_restaurant_available'.tr : 'currently_no_recommended_store_available'.tr),
            )),
          ) : Container(
            decoration: BoxDecoration(
              // color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: storeController.recommendedStoreList!.isNotEmpty ?
            storeController.recommendedStoreList!.length == 1 ? Center(
              child: InkWell(
                onTap: (){
                  Get.toNamed(RouteHelper.getStoreRoute(id: storeController.recommendedStoreList!.first.id, page: 'store', slug: storeController.recommendedStoreList!.first.slug??''),
                    arguments: StoreScreen(store: storeController.recommendedStoreList!.first, fromModule: false),
                  );
                },
                child: TextHover(
                    builder: (hovered) {
                      return Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          child: CustomImage(
                            isHovered: hovered,
                            image: '${storeController.recommendedStoreList!.first.logoFullUrl}',
                            fit: BoxFit.cover, height: 60, width: 60,
                          ),
                        ),
                      );
                    }
                ),
              ),
            )
                : GridView.builder(
              itemCount: storeController.recommendedStoreList!.length > 9 ? 9 : storeController.recommendedStoreList!.length,
              shrinkWrap: true,
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: Dimensions.paddingSizeDefault,
                mainAxisSpacing: Dimensions.paddingSizeDefault,
                mainAxisExtent: 60,
              ),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: (){
                    Get.toNamed(RouteHelper.getStoreRoute(id: storeController.recommendedStoreList![index].id, page: 'store', slug: storeController.recommendedStoreList![index].slug??''),
                      arguments: StoreScreen(store: storeController.recommendedStoreList![index], fromModule: false),
                    );
                  },
                  child: TextHover(
                    builder: (hovered) {
                      return Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          child: CustomImage(
                            isHovered: hovered,
                            image: '${storeController.recommendedStoreList![index].logoFullUrl}',
                            fit: BoxFit.cover, height: 60, width: double.infinity,
                          ),
                        ),
                      );
                    }
                  ),
                );
              },
            ) : Center(child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Text(isFood ? 'currently_no_recommended_restaurant_available'.tr : 'currently_no_recommended_store_available'.tr),
            )),
          ),
        ]),
      ) : const WebRecommendedStoreShimmerView();
    });
  }
}

class WebRecommendedStoreShimmerView extends StatelessWidget {
  const WebRecommendedStoreShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      enabled: true,
      child: Container(
        margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
        padding:  const EdgeInsets.all(Dimensions.paddingSizeSmall),
        width: Get.width, height: 302,
        decoration: BoxDecoration(
          color: Theme.of(context).shadowColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Column(children: [
          Container(
            height: 20, width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: GridView.builder(
              itemCount: 9,
              shrinkWrap: true,
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: Dimensions.paddingSizeDefault,
                mainAxisSpacing: Dimensions.paddingSizeDefault,
                mainAxisExtent: 60,
              ),
              itemBuilder: (context, index) {
                return Shimmer(
                  duration: const Duration(seconds: 2),
                  enabled: true,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).shadowColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
