import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/parcel/widgets/custom_icon_layout.dart';
import 'package:sixam_mart/features/parcel/widgets/custom_vertical_dotted_line.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class TripFromToCard extends StatelessWidget {
  final AddressModel? pickUpAddress;
  final AddressModel? destinationAddress;
  const TripFromToCard({super.key, this.pickUpAddress, this.destinationAddress,});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Text('address_information'.tr, style: robotoSemiBold),
      const SizedBox(height: Dimensions.paddingSizeDefault),

      Row(children: [
        Padding(
          padding: EdgeInsets.only(right: Get.find<LocalizationController>().isLtr ? Dimensions.paddingSizeSmall : 0 , left: Get.find<LocalizationController>().isLtr ? 0 : Dimensions.paddingSizeSmall),
          child: const CustomIconLayout(height: 20, width: 20, iconImage: Images.gpsIcon),
        ),

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text(
              pickUpAddress?.address??'', maxLines: 2, overflow: TextOverflow.ellipsis,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault-1),
            ),
            Wrap(children: [
              (pickUpAddress!.streetNumber != null && pickUpAddress!.streetNumber!.isNotEmpty) ? Text('${'street_number'.tr}: ${pickUpAddress!.streetNumber!}, ',
                maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
              ) : const SizedBox(),

              (pickUpAddress!.house != null && pickUpAddress?.house != 'null' && pickUpAddress!.house!.isNotEmpty) ? Text('${'house'.tr}: ${pickUpAddress!.house!}, ',
                maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
              ) : const SizedBox(),

              (pickUpAddress!.floor != null && pickUpAddress!.floor!.isNotEmpty) ? Text('${'floor'.tr}: ${pickUpAddress!.floor!}',
                maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
              ) : const SizedBox(),
            ]),
          ]),
        ),
      ]),

      Padding(
        padding: EdgeInsets.only(left: Get.find<LocalizationController>().isLtr ? Dimensions.paddingSizeDefault : 0, right: Get.find<LocalizationController>().isLtr ? 0 : Dimensions.paddingSizeDefault),
        child: const CustomVerticalDottedLine(),
      ),

      Row(children: [

        Padding(
          padding: EdgeInsets.only(right: Get.find<LocalizationController>().isLtr ? Dimensions.paddingSizeSmall : 0 , left: Get.find<LocalizationController>().isLtr ? 0 : Dimensions.paddingSizeSmall),
          child: const CustomIconLayout(height: 20, width: 20, iconImage: Images.directUpIcon, paddingSize: 5),
        ),

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text(
              destinationAddress?.address??'', maxLines: 2, overflow: TextOverflow.ellipsis,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault - 1),
            ),
            Wrap(children: [
              (destinationAddress!.streetNumber != null && destinationAddress!.streetNumber!.isNotEmpty) ? Text('${'street_number'.tr}: ${destinationAddress!.streetNumber!}, ',
                maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
              ) : const SizedBox(),

              (destinationAddress!.house != null && destinationAddress?.house != 'null' && destinationAddress!.house!.isNotEmpty) ? Text('${'house'.tr}: ${destinationAddress!.house!}, ',
                maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
              ) : const SizedBox(),

              (destinationAddress!.floor != null && destinationAddress!.floor!.isNotEmpty) ? Text('${'floor'.tr}: ${destinationAddress!.floor!}',
                maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
              ) : const SizedBox(),
            ]),

          ]),
        ),

        // Expanded(
        //     child: Text(toAddress.address??'', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
        // ),
      ]),

    ]);
  }
}
