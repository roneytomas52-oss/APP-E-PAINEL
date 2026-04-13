import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class CustomTitle extends StatelessWidget {
  final String title;
  final Color? color;
  final String? icon;
  final String? count;
  final double? fontSize;
  const CustomTitle({super.key, required this.title, this.color, this.icon, this.count,this.fontSize});
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.fromLTRB(0,
        Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, 0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

        Row(children: [
          Text(
            title.tr,
            style: robotoBold.copyWith(
              fontSize: fontSize ?? Dimensions.fontSizeLarge,
              color: color??Theme.of(context).textTheme.bodyMedium!.color,
            ),
          ),

          if(icon!=null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Image.asset(icon!,height: 15,width: 15),
            ),
        ]),

        if(count!=null)
          Text(
            count.toString(),
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color:Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.5)),
          ),
      ],
      ),
    );
  }
}