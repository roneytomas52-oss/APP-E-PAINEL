import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/dimensions.dart';

class CardWidget extends StatelessWidget {
  final Widget child;
  final bool showCard;
  const CardWidget({super.key, required this.child, this.showCard = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      padding: showCard ? const EdgeInsets.all(Dimensions.paddingSizeSmall) : null,
      decoration: showCard ? BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, spreadRadius: 1, offset: Offset(0, 3))],
      ) : null,
      child: child,
    );
  }
}
