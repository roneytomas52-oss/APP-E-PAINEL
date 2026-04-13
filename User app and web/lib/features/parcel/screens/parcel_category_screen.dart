import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/features/banner/controllers/banner_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/home/widgets/web/module_widget.dart';
import 'package:sixam_mart/features/parcel/controllers/parcel_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/features/parcel/widgets/parcel_app_bar_widget.dart';
import 'package:sixam_mart/features/parcel/widgets/deliver_item_card_widget.dart';
import 'package:sixam_mart/features/parcel/widgets/get_service_video_widget.dart';
import 'package:sixam_mart/features/parcel/widgets/sevice_info_list_widget.dart';

class ParcelCategoryScreen extends StatefulWidget {
  const ParcelCategoryScreen({super.key});

  @override
  State<ParcelCategoryScreen> createState() => _ParcelCategoryScreenState();
}

class _ParcelCategoryScreenState extends State<ParcelCategoryScreen> {

  @override
  void initState() {
    super.initState();
    if(AuthHelper.isLoggedIn() && Get.find<ProfileController>().userInfoModel == null) {
      Get.find<ProfileController>().getUserInfo();
    }
    Get.find<BannerController>().getParcelOtherBannerList(true);
    Get.find<ParcelController>().getWhyChooseDetails();
    Get.find<ParcelController>().getVideoContentDetails();
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return Scaffold(
      appBar: isDesktop ? null : const ParcelAppBarWidget(),
      body: GetBuilder<ParcelController>(builder: (parcelController) {
        return GetBuilder<BannerController>(builder: (bannerController) {

          bool showVideoAndServices = parcelController.videoContentDetails != null && (parcelController.videoContentDetails!.bannerVideo != null || parcelController.videoContentDetails!.bannerImageFullUrl != null);
          return Stack(clipBehavior: Clip.none, children: [

            RefreshIndicator(
              onRefresh: () async {
                await Get.find<ParcelController>().getParcelCategoryList();
                await Get.find<BannerController>().getParcelOtherBannerList(true);
                await Get.find<ParcelController>().getWhyChooseDetails();
                await Get.find<ParcelController>().getVideoContentDetails();
              },
              child: SingleChildScrollView(
                child: FooterView(child: SizedBox(width: Dimensions.webMaxWidth,
                    child: Column(crossAxisAlignment: isDesktop ? CrossAxisAlignment.center : CrossAxisAlignment.start, children: [

                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : Dimensions.paddingSizeLarge),
                        child: Text('what_would_you_like_to_send'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      parcelController.parcelCategoryList != null ? parcelController.parcelCategoryList!.isNotEmpty ? GridView.builder(
                        controller: ScrollController(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isDesktop ? 3 : 2,
                          crossAxisSpacing: isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall,
                          mainAxisSpacing: isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall,
                          mainAxisExtent: isDesktop ? 100 : 110,
                        ),
                        itemCount: parcelController.parcelCategoryList!.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : Dimensions.paddingSizeLarge),
                        itemBuilder: (context, index) {
                          return DeliverItemCardWidget(
                            isDeliverItem: true,
                            image: '${parcelController.parcelCategoryList![index].imageFullUrl}',
                            itemName: parcelController.parcelCategoryList![index].name!,
                            description: parcelController.parcelCategoryList![index].description!,
                            onTap: () {
                              print('=====tappppp========> ${AddressHelper.getUserAddressFromSharedPref()}');
                              if(AddressHelper.getUserAddressFromSharedPref() == null) {
                                Get.find<LocationController>().navigateToLocationScreen('home', canRoute: true);
                                return;
                              } else {
                                Get.toNamed(RouteHelper.getParcelLocationRoute(parcelController.parcelCategoryList![index]));
                              }
                            },
                          );
                        },
                      ) : Center(child: Text('no_parcel_category_found'.tr)) : ParcelShimmer(isEnabled: parcelController.parcelCategoryList == null, isDeliveryItem: true),
                      const SizedBox(height: Dimensions.paddingSizeLarge),


                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : Dimensions.paddingSizeLarge),
                        child: bannerController.parcelOtherBannerModel != null && bannerController.parcelOtherBannerModel!.banners != null ? bannerController.parcelOtherBannerModel!.banners!.isNotEmpty ? CarouselSlider.builder(
                          itemCount: bannerController.parcelOtherBannerModel!.banners!.length,
                          options: CarouselOptions(
                            autoPlay: true,
                            height: isDesktop ? 395 : 120,
                            enlargeCenterPage: true,
                            disableCenter: true,
                            viewportFraction: 1,
                            autoPlayInterval: const Duration(seconds: 5),
                            onPageChanged: (index, reason) {
                              bannerController.setCurrentIndex(index, false);
                            },
                          ),
                          itemBuilder: (context, index, realIndex) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              child: CustomImage(
                                image: '${bannerController.parcelOtherBannerModel!.banners![index].imageFullUrl}',
                              ),
                            );
                          },
                        ) : const SizedBox() : Shimmer(
                          duration: const Duration(seconds: 2),
                          enabled: true,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: isDesktop ? 395 : 150,
                            padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),

                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isDesktop ? Dimensions.paddingSizeExtraLarge : Dimensions.paddingSizeLarge),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : Dimensions.paddingSizeLarge),
                        child: Text('experience_the_best_with_us'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      parcelController.whyChooseDetails != null
                          ? isDesktop ? webExperienceView(isDesktop, parcelController) : mobileExperienceView(isDesktop, parcelController)
                        : ParcelShimmer(isEnabled: parcelController.parcelCategoryList == null, isDeliveryItem: false),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      Align(
                        alignment: Get.find<LocalizationController>().isLtr ? Alignment.centerLeft : Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : Dimensions.paddingSizeLarge),
                          child: Text('easiest_way_to_get_services'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal:isDesktop ? 0 : Dimensions.paddingSizeLarge),
                        child: parcelController.videoContentDetails != null ? isDesktop ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

                          showVideoAndServices ? Expanded(
                            child: parcelController.videoContentDetails!.bannerType == 'image' ? ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child: CustomImage(
                                image: '${parcelController.videoContentDetails!.bannerImageFullUrl}',
                              ),
                            ) : parcelController.videoContentDetails!.bannerType == 'video' ? GetServiceVideoWidget(youtubeVideoUrl: parcelController.videoContentDetails!.bannerVideo ?? '', fileVideoUrl: '',) : GetServiceVideoWidget(
                              youtubeVideoUrl: '',
                              fileVideoUrl: '${parcelController.videoContentDetails!.bannerVideoContentFullUrl}',
                            ),
                          ) : const SizedBox(),
                          const SizedBox(width: 125),

                          Expanded(
                            child: ServiceInfoListWidget(
                              parcelController: parcelController,
                            ),
                          ),
                        ]) : Column(children: [

                          parcelController.videoContentDetails!.bannerType == 'image' ? ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            child: CustomImage(
                              image: '${parcelController.videoContentDetails!.bannerImageFullUrl}',
                            ),
                          ) : parcelController.videoContentDetails!.bannerType == 'video' ? GetServiceVideoWidget(youtubeVideoUrl: parcelController.videoContentDetails!.bannerVideo ?? '', fileVideoUrl: '',) : GetServiceVideoWidget(
                            youtubeVideoUrl: '',
                            fileVideoUrl: '${parcelController.videoContentDetails!.bannerVideoContentFullUrl}',
                          ),

                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          ServiceInfoListWidget(parcelController: parcelController),
                        ]) : const VideoContentDetailsShimmer(),
                      ),

                      SizedBox(height: isDesktop ? 0 : 100),
                    ]))),
                  ),
            ),

            isDesktop ? const Positioned(right: 0, top: 0, bottom: 0, child: Center(child: ModuleWidget())) : const SizedBox(),

          ]);
        });
      }),
    );
  }

  Widget webExperienceView(bool isDesktop, ParcelController parcelController) {
    return GridView.builder(
      controller: ScrollController(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : ResponsiveHelper.isTab(context) ? 2 : 1,
        crossAxisSpacing: isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall,
        mainAxisSpacing: isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall,
        mainAxisExtent: isDesktop ? 95 : 80,
      ),
      itemCount: parcelController.whyChooseDetails!.banners!.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        return DeliverItemCardWidget(
          image: '${parcelController.whyChooseDetails!.banners![index].imageFullUrl}',
          itemName: parcelController.whyChooseDetails!.banners![index].title!,
          description: parcelController.whyChooseDetails!.banners![index].shortDescription!,
        );
      },
    );
  }

  Widget mobileExperienceView(bool isDesktop, ParcelController parcelController) {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: ListView.builder(
          itemCount: parcelController.whyChooseDetails!.banners!.length,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(
            left: Get.find<LocalizationController>().isLtr ? Dimensions.paddingSizeLarge : 0,
            right: Get.find<LocalizationController>().isLtr ? 0 : Dimensions.paddingSizeLarge,
          ),
          itemBuilder: (context, index) {
        return Container(
          width: context.width * 0.75,
          margin: EdgeInsets.only(
            right: Get.find<LocalizationController>().isLtr ? Dimensions.paddingSizeSmall : 0,
            left: Get.find<LocalizationController>().isLtr ? 0 : Dimensions.paddingSizeSmall,
          ),
          child: DeliverItemCardWidget(
            image: '${parcelController.whyChooseDetails!.banners![index].imageFullUrl}',
            itemName: parcelController.whyChooseDetails!.banners![index].title!,
            description: parcelController.whyChooseDetails!.banners![index].shortDescription!,
          ),
        );
      }),
    );
  }
}


class ParcelShimmer extends StatelessWidget {
  final bool isEnabled;
  final bool isDeliveryItem;
  const ParcelShimmer({super.key, required this.isEnabled, required this.isDeliveryItem});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return GridView.builder(
      gridDelegate: isDeliveryItem ? SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 2,
        crossAxisSpacing: isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall,
        mainAxisSpacing: isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall,
        mainAxisExtent: isDesktop ? 100 : 75,
      ) : SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : ResponsiveHelper.isTab(context) ? 2 : 1,
        crossAxisSpacing: isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall,
        mainAxisSpacing: isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall,
        mainAxisExtent: isDesktop ? 100 : 80,
      ),
      itemCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : Dimensions.paddingSizeLarge),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: isEnabled,
            child: Row(children: [

              Container(
                height: 50, width: 50, alignment: Alignment.center,
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(height: 15, width: 200, color: Colors.grey[300]),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Container(height: 15, width: 100, color: Colors.grey[300]),
              ])),
              const SizedBox(width: Dimensions.paddingSizeSmall),
            ]),
          ),
        );
      },
    );
  }
}

class VideoContentDetailsShimmer extends StatelessWidget {
  const VideoContentDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.isDesktop(context) ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

      Expanded(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 350,
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
        ),
      ),
      const SizedBox(width: 125),

      Expanded(
        child: ListView.builder(
          physics: const ScrollPhysics(),
          shrinkWrap: true,
          itemCount: 6,
          itemBuilder: (context, index) {
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Row(children: [
                Container(
                  height: 14, width: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),

                Container(height: 15, width: 200, color: Colors.grey[300]),
              ]),

              Container(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: 22.5),
                margin: const EdgeInsets.only(left: 7),
                decoration: BoxDecoration(
                    border: index == 6 - 1 ? null : Border(left: BorderSide(width: 1, color: Theme.of(context).disabledColor))),
                child: Container(height: 15, width: 100, color: Colors.grey[300]),
              ),
            ]);
          },
        ),
      ),
    ]) : Column(children: [

      Container(
        width: MediaQuery.of(context).size.width,
        height: 185,
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
      ),
      const SizedBox(height: Dimensions.paddingSizeLarge),

      ListView.builder(
        physics: const ScrollPhysics(),
        shrinkWrap: true,
        itemCount: 6,
        itemBuilder: (context, index) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(children: [
              Container(
                height: 14, width: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),

              Container(height: 15, width: 200, color: Colors.grey[300]),
            ]),

            Container(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: 22.5),
              margin: const EdgeInsets.only(left: 7),
              decoration: BoxDecoration(
                  border: index == 6 - 1 ? null : Border(left: BorderSide(width: 1, color: Theme.of(context).disabledColor))),
              child: Container(height: 15, width: 100, color: Colors.grey[300]),
            ),
          ]);
        },
      ),
    ]);
  }
}

