import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';

void showCustomBottomSheet({required Widget child, double? maxHeight, bool useGetX = true}) {
  useGetX ? Get.bottomSheet(
    ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight ?? MediaQuery.of(Get.context!).size.height * 0.8),
      child: child,
    ),
    isScrollControlled: true, useRootNavigator: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
    ),
  ) : showModalBottomSheet(
    isScrollControlled: true, useRootNavigator: true, context: Get.context!,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
    ),
    builder: (context) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.8),
        child: child,
      );
    },
  );
}