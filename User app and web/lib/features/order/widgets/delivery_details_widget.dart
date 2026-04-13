import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
class DeliveryDetailsWidget extends StatefulWidget {
  final AddressModel? deliveryAddress;
  const DeliveryDetailsWidget({super.key, this.deliveryAddress});

  @override
  State<DeliveryDetailsWidget> createState() => _DeliveryDetailsWidgetState();
}

class _DeliveryDetailsWidgetState extends State<DeliveryDetailsWidget> {
  bool isExpanded = false;

  bool get hasAdditionalInfo {
    return (widget.deliveryAddress?.streetNumber != null && widget.deliveryAddress!.streetNumber!.isNotEmpty) ||
        (widget.deliveryAddress?.house != null && widget.deliveryAddress!.house!.isNotEmpty) ||
        (widget.deliveryAddress?.floor != null && widget.deliveryAddress!.floor!.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      widget.deliveryAddress?.contactPersonName != null ? _detailsItem(Icons.person_2_outlined, '${widget.deliveryAddress?.contactPersonName}', context) : SizedBox.shrink(),
      widget.deliveryAddress?.contactPersonNumber != null ?_detailsItem(Icons.phone_enabled_outlined, '${widget.deliveryAddress?.contactPersonNumber}', context) : SizedBox.shrink(),
      widget.deliveryAddress?.address != null ? _detailsItem(Icons.location_on_outlined, '${widget.deliveryAddress?.address}', context) : SizedBox.shrink(),

      const SizedBox(height: Dimensions.paddingSizeSmall),


      if (hasAdditionalInfo) ...[
        if (isExpanded) Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Wrap( alignment: WrapAlignment.start, crossAxisAlignment: WrapCrossAlignment.start, runSpacing: 6, children: [
            (widget.deliveryAddress?.streetNumber != null && widget.deliveryAddress!.streetNumber!.isNotEmpty) ? RichText(
              text: TextSpan(children: [
                TextSpan(text: '${'road'.tr} : ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color)),
                TextSpan(text: widget.deliveryAddress?.streetNumber ?? '', style: robotoSemiBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color)),
              ]),
            ) : const SizedBox(),

            (widget.deliveryAddress?.streetNumber != null && widget.deliveryAddress!.streetNumber!.isNotEmpty) ? Container(
              height: 12, width: 1, color: Theme.of(context).hintColor,
              margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
            ) : const SizedBox(),

            (widget.deliveryAddress?.house != null && widget.deliveryAddress!.house!.isNotEmpty) ? RichText(
              text: TextSpan(children: [
                TextSpan(text: '${'house'.tr} : ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color)),
                TextSpan(text: widget.deliveryAddress?.house ?? '', style: robotoSemiBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color)),
              ]),
            ) : const SizedBox(),

            (widget.deliveryAddress?.house != null && widget.deliveryAddress!.house!.isNotEmpty) ? Container(
              height: 12, width: 1, color: Theme.of(context).hintColor,
              margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
            ) : const SizedBox(),

            (widget.deliveryAddress?.floor != null && widget.deliveryAddress!.floor!.isNotEmpty) ? RichText(
              text: TextSpan(children: [
                TextSpan(text: '${'floor'.tr} : ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color)),
                TextSpan(text: widget.deliveryAddress?.floor ?? '', style: robotoSemiBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color)),
              ]),
            ) : const SizedBox(),
          ]),
        ),

        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        Center(
          child: InkWell(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(isExpanded ? 'view_less'.tr : 'view_more'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16, color: Theme.of(context).primaryColor),
            ]),
          ),
        ),
      ],
    ]);
  }

  Widget _detailsItem(IconData icon, String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 16,),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Flexible(child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeSmall))),
      ]),
    );
  }
}
