import 'package:sixam_mart/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:sixam_mart/util/images.dart';

class QuantityButton extends StatelessWidget {
  final bool isIncrement;
  final Function? onTap;
  final bool fromSheet;
  final bool showRemoveIcon;
  final Color? color;
  const QuantityButton({super.key, required this.isIncrement, required this.onTap, this.fromSheet = false, this.showRemoveIcon = false, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: Container(
        height: fromSheet ? 30 : 25, width: fromSheet ? 30 : 25,
        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // border: Border.all(width: 1, color: showRemoveIcon ? Theme.of(context).colorScheme.error.withValues(alpha: 0.1) : isIncrement ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),
          color: showRemoveIcon ? Theme.of(context).colorScheme.error.withValues(alpha: 0.1) : isIncrement ? color ?? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.2),
        ),
        alignment: Alignment.center,
        child: showRemoveIcon ? Image.asset(Images.delete, height: 15, color: Theme.of(context).colorScheme.error) : Icon(
          isIncrement ? Icons.add : Icons.remove,
          size: 15,
          color: showRemoveIcon ? Theme.of(context).colorScheme.error : isIncrement ? Theme.of(context).cardColor : Theme.of(context).disabledColor,
        ),
      ),
    );
  }
}