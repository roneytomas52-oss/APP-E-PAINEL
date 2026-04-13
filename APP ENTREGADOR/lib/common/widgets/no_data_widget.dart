import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';



class NoDataWidget extends StatelessWidget {
  final String? title;
  const NoDataWidget({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset( title == "no_review_found" ? Images.noReview
                  : title == "no_review_saved_yet" ? Images.noReview
                  : Images.noDataFound, width:   70, height:  70, ),
          Text(title != null? title!.tr : 'no_data_found'.tr,
            style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeDefault),
            textAlign: TextAlign.center,
          ),

              SizedBox(height: Get.height * 0.1)

        ]),
      ),
    );
  }
}
