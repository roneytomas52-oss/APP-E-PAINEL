import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class OrderShimmerWidget extends StatelessWidget {
  final bool isEnabled;
  const OrderShimmerWidget({super.key, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      height: 150,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.1), width: 1.5),
      ),
      child: Column(children: [

        Row(children: [
          Shimmer(child: Container(height: 15, width: 100, color: Theme.of(context).shadowColor)),
          const Expanded(child: SizedBox()),
          Shimmer(child: Container(width: 7, height: 7, decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle))),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Shimmer(child: Container(height: 15, width: 70, color: Theme.of(context).shadowColor)),
        ]),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, children: [
          Image.asset(Images.house, width: 20, height: 15, color: Theme.of(context).disabledColor),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Shimmer(child: Container(height: 15, width: 200, color: Theme.of(context).shadowColor)),
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, children: [
          Icon(Icons.location_on, size: 20, color: Theme.of(context).disabledColor),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Shimmer(child: Container(height: 15, width: 200, color: Theme.of(context).shadowColor)),
        ]),
        const SizedBox(height: Dimensions.paddingSizeDefault),

      ]),
    );
  }
}
