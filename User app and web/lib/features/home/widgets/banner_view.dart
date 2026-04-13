import 'package:carousel_slider/carousel_slider.dart';
import 'package:sixam_mart/features/banner/controllers/banner_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/item/domain/models/basic_campaign_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:url_launcher/url_launcher_string.dart';

class BannerView extends StatelessWidget {
  final bool isFeatured;
  const BannerView({super.key, required this.isFeatured});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<BannerController>(builder: (bannerController) {
      List<String?>? bannerList = isFeatured ? bannerController.featuredBannerList : bannerController.bannerImageList;
      List<dynamic>? bannerDataList = isFeatured ? bannerController.featuredBannerDataList : bannerController.bannerDataList;

      return (bannerList != null && bannerList.isEmpty) ? const SizedBox() : Container(
        width: MediaQuery.of(context).size.width,
        height: GetPlatform.isDesktop ? 500 : MediaQuery.of(context).size.width * 0.45,
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
        child: bannerList != null ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: CarouselSlider.builder(
                options: CarouselOptions(
                  autoPlay: bannerList.length > 1,
                  enableInfiniteScroll: bannerList.length > 1,
                  enlargeCenterPage: true,
                  disableCenter: true,
                  viewportFraction: 1,
                  autoPlayInterval: const Duration(seconds: 7),
                  onPageChanged: (index, reason) {
                    bannerController.setCurrentIndex(index, true);
                  },
                ),
                itemCount: bannerList.isEmpty ? 1 : bannerList.length,
                itemBuilder: (context, index, _) {

                  return InkWell(
                    onTap: () async {
                      if(bannerDataList![index] is Item) {
                        Item? item = bannerDataList[index];
                        Get.find<ItemController>().navigateToItemPage(item, context);
                      }else if(bannerDataList[index] is Store) {
                        Store? store = bannerDataList[index];
                        if(isFeatured && (AddressHelper.getUserAddressFromSharedPref()!.zoneData != null && AddressHelper.getUserAddressFromSharedPref()!.zoneData!.isNotEmpty)) {
                          for(ModuleModel module in Get.find<SplashController>().moduleList!) {
                            if(module.id == store!.moduleId) {
                              Get.find<SplashController>().setModule(module);
                              break;
                            }
                          }
                          ZoneData zoneData = AddressHelper.getUserAddressFromSharedPref()!.zoneData!.firstWhere((data) => data.id == store!.zoneId);

                          Modules module = zoneData.modules!.firstWhere((module) => module.id == store!.moduleId);
                          Get.find<SplashController>().setModule(ModuleModel(id: module.id, moduleName: module.moduleName, moduleType: module.moduleType, themeId: module.themeId, storesCount: module.storesCount));
                        }
                        Get.toNamed(
                          RouteHelper.getStoreRoute(id: store!.id, page: isFeatured ? 'module' : 'banner', slug: store.slug??''),
                          arguments: StoreScreen(store: store, fromModule: isFeatured),
                        );
                      }else if(bannerDataList[index] is BasicCampaignModel) {
                        BasicCampaignModel campaign = bannerDataList[index];
                        Get.toNamed(RouteHelper.getBasicCampaignRoute(campaign));
                      }else {
                        String url = bannerDataList[index];
                        if (await canLaunchUrlString(url)) {
                          await launchUrlString(url, mode: LaunchMode.externalApplication);
                        }else {
                          showCustomSnackBar('unable_to_found_url'.tr);
                        }
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        boxShadow: [BoxShadow(offset : Offset(0, 2), color: Theme.of(context).disabledColor.withValues(alpha: 0.2), blurRadius: 8, spreadRadius: 2),],
                      ),
                      margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        child: GetBuilder<SplashController>(builder: (splashController) {
                          return CustomImage(
                            image: '${bannerList[index]}',
                            fit: BoxFit.cover,
                          );
                        }),
                      ),
                    ),
                  );
                },
              ),
            ),

            if(bannerList.length > 1) ... [
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 1),
                  child: Text('${(bannerController.currentIndex) + 1}/${bannerList.length}',
                      style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 12),
                  ),
                ),
              ),
            ],

          ],
        ) : Shimmer(
          duration: const Duration(seconds: 2),
          enabled: bannerList == null,
          child: Container(margin: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            color: Colors.grey[300],
          )),
        ),
      );
    });
  }

}
