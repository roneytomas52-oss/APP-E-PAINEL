import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';

import '../../util/images.dart';

class RatingBar extends StatelessWidget {
  final double? rating;
  final double size;
  final int? ratingCount;
  const RatingBar({super.key, required this.rating, required this.ratingCount, this.size = 18});

  @override
  Widget build(BuildContext context) {

    if(rating == null || rating == 0) {
      return const SizedBox();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      // children: starList,
      children: [
        Image.asset(Images.starFill, width: size, height: size),
        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

        Padding(
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
          child: Row(
            children: [
              Text(rating?.toStringAsFixed(1)??'0', style: robotoRegular.copyWith(fontSize: size*0.8, color: Theme.of(context).textTheme.bodyLarge?.color), textDirection: TextDirection.ltr),
              Text(' ($ratingCount)', style: robotoRegular.copyWith(fontSize: size*0.8, color: Theme.of(context).disabledColor), textDirection: TextDirection.ltr),
            ],
          ),
        ),
      ],
    );
  }
}