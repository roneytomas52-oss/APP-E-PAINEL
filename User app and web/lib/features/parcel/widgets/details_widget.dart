import 'package:flutter/material.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class DetailsWidget extends StatelessWidget {
  final String title;
  final AddressModel? address;
  const DetailsWidget({super.key, required this.title, required this.address});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Text(title, style: robotoSemiBold),
      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

      Row(
        children: [
          Icon(Icons.person_2_outlined, size: 16, color: Theme.of(context).primaryColor),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Expanded(
            child: Text(
              address?.contactPersonName ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
              style: robotoSemiBold.copyWith(color: Theme.of(context).hintColor),
            ),
          ),
        ],
      ),
      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

      Row(
        children: [
          Icon(Icons.phone_enabled_outlined, size: 14, color: Theme.of(context).primaryColor),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Expanded(
            child: Text(
              address!.contactPersonNumber ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
            ),
          ),
        ],
      ),

      AuthHelper.isGuestLoggedIn() && address!.email != null && address!.email!.isNotEmpty ? Padding(
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
        child: Row(
          children: [
            Icon(Icons.email_outlined, size: 14, color: Theme.of(context).primaryColor),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Expanded(
              child: Text(
                address?.email ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
              ),
            ),
          ],
        ),
      ) : const SizedBox(),

    ]);
  }
}
