import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/home/widgets/web/web_basic_medicine_nearby_view_widget.dart';
import 'package:sixam_mart/features/home/widgets/web/widgets/medicine_item_card.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class CommonConditionView extends StatelessWidget {
  const CommonConditionView({super.key});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<ItemController>(
      builder: (itemController) {
        return itemController.commonConditions != null ? itemController.commonConditions!.isNotEmpty ? Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: EdgeInsets.only(
                top: Dimensions.paddingSizeDefault,
                left:  Dimensions.paddingSizeDefault,
                right: Dimensions.paddingSizeDefault,
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('common_condition'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                SizedBox(
                  height: 30,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: itemController.commonConditions!.length,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      bool isSelected = itemController.selectedCommonCondition == index;
                      return InkWell(
                        onTap: () => itemController.selectCommonCondition(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                            vertical: Dimensions.paddingSizeExtraSmall,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                          child: Text(
                            '${itemController.commonConditions![index].name}',
                            textAlign: TextAlign.center,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ]),
            ),

            itemController.conditionWiseProduct != null ? itemController.conditionWiseProduct!.isNotEmpty ? GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : 4,
                crossAxisSpacing: Dimensions.paddingSizeDefault,
                mainAxisSpacing: Dimensions.paddingSizeDefault,
                mainAxisExtent: 250,
              ),
              shrinkWrap: true,
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              itemCount: itemController.conditionWiseProduct!.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return MedicineItemCard(item: itemController.conditionWiseProduct![index]);
              },
            ) : Center(child: Padding(
              padding: const EdgeInsets.all(100),
              child: Text('no_product_available'.tr),
            )) : const MedicineCardShimmer(),

          ]),
        ) : const SizedBox() : const MedicineCardShimmer();
      }
    );
  }
}
