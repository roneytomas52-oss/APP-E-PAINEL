import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class BottomSheetForMobile extends StatelessWidget {
  const BottomSheetForMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.paddingSizeExtraLarge),
          topRight : Radius.circular(Dimensions.paddingSizeExtraLarge),
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          height: 4, width: 35,
          margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(10)),
        ),

        const SizedBox(height: Dimensions.paddingSizeSmall),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
          child: Column(children: [
            Align(alignment: Alignment.centerLeft, child: Text('how_it_works'.tr , style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge), textAlign: TextAlign.center)),

            ListView.builder(
              shrinkWrap: true,
              padding:  EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: AppConstants.dataList.length,
              itemBuilder: (context, index){
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall) ,
                      decoration: BoxDecoration(
                        color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Text('${index+1}'),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Text(AppConstants.dataList[index].tr, style: robotoRegular),

                  ]),
                );
              })
          ]),
        ),

      ]),
    );
  }
}
