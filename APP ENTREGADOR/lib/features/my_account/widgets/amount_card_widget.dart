import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class AmountCardWidget extends StatelessWidget {
  final String title;
  final double amount;
  final String image;
  final Color borderColor;
  const AmountCardWidget({super.key,  required this.title, required this.amount, required this.image, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).cardColor,
        border: Border.all(color: borderColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        CustomAssetImageWidget(
          image: image,
          height: 25, width: 25,
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        Text(
          PriceConverterHelper.convertPrice(amount),
          style: robotoSemiBold,
        ),

        Text(title.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),

      ]),
    );
  }
}