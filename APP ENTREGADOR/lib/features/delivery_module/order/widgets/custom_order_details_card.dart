import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class CustomOrderDetailsCard extends StatelessWidget {
  final String title;
  final String metaValue;

  const CustomOrderDetailsCard({super.key, required this.title, required this.metaValue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        boxShadow: Get.isDarkMode ? null : [BoxShadow(color: Colors.grey[200]!, spreadRadius: 1, blurRadius: 5)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: robotoBold.copyWith(
          fontSize: Dimensions.fontSizeDefault,
        )),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.05) ,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(metaValue, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault))),

      ])
    );
  }
}
