import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/discount_tag.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/util/styles.dart';

class ItemImageViewWidget extends StatelessWidget {
  final Item? item;
  final bool isCampaign;
  ItemImageViewWidget({super.key, required this.item, this.isCampaign = false});

  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {

    List<String?> imageList = [];
    List<String?> imageListForCampaign = [];

    if(isCampaign){
      imageListForCampaign.add(item!.imageFullUrl);
    }else{
      imageList.add(item!.imageFullUrl);
      imageList.addAll(item!.imagesFullUrl!);
    }

    double? discount = Get.find<ItemController>().item!.discount;
    String? discountType = Get.find<ItemController>().item!.discountType;

    return GetBuilder<ItemController>(builder: (itemController) {

      return InkWell(
        onTap: isCampaign ? null : () {
          if(!isCampaign) {
            Navigator.of(context).pushNamed(RouteHelper.getItemImagesRoute(item!), arguments: ItemImageViewWidget(item: item));
          }
        },
        child: Stack(children: [
          SizedBox(
            height: ResponsiveHelper.isDesktop(context)? 350 : MediaQuery.of(context).size.width * 0.7,
            child: PageView.builder(
              controller: _controller,
              itemCount: isCampaign ? imageListForCampaign.length : imageList.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CustomImage(
                    image: '${isCampaign ? imageListForCampaign[index] : imageList[index]}',
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                  ),
                );
              },
              onPageChanged: (index) {
                itemController.setImageSliderIndex(index);
              },
            ),
          ),

          DiscountTag(discount: discount, discountType: discountType, fromTop: 20),

          Positioned(
            right: 10, top: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(50),
              ),
              child: GetBuilder<FavouriteController>(builder: (favouriteController) {
                return InkWell(
                  onTap: () {
                    if(AuthHelper.isLoggedIn()){
                      if(favouriteController.wishItemIdList.contains(item!.id)) {
                        favouriteController.removeFromFavouriteList(item!.id, false);
                      }else {
                        favouriteController.addToFavouriteList(item, null, false);
                      }
                    }else {
                      showCustomSnackBar('you_are_not_logged_in'.tr);
                    }
                  },
                  child: Icon(
                    favouriteController.wishItemIdList.contains(item!.id) ? Icons.favorite : Icons.favorite_border, size: 25,
                    color: favouriteController.wishItemIdList.contains(item!.id) ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                  ),
                );
              }),
            ),
          ),

          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Padding(
              padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              child: _indicators(context, itemController, isCampaign ? imageListForCampaign : imageList),
            ),
          ),

        ]),
      );
    });
  }

  Widget _indicators(BuildContext context, ItemController itemController, List<String?> imageList) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          ),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: 2),
          child: Text('${itemController.imageSliderIndex + 1}/${imageList.length}', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),),
        ),
      ),
    );
  }

}
