import 'package:flutter/material.dart';
import 'package:sixam_mart/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart/util/dimensions.dart';

class CustomIconLayout extends StatelessWidget {
  final double height;
  final double width;
  final double? paddingSize;
  final IconData? icon;
  final String? iconImage;
  final Color? color;

  const CustomIconLayout({super.key, this.height = 10, this.width = 10, this.icon, this.iconImage, this.paddingSize, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).disabledColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      padding: EdgeInsets.all(paddingSize ?? Dimensions.paddingSizeExtraSmall),
      child: iconImage != null ? CustomAssetImageWidget(iconImage!, height: height, width: width, color: color) : Icon(icon, size: 20, color: color),
    );
  }
}
