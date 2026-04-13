import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class LocationAccessDialog extends StatelessWidget {
  final Function()? onConfirm;
  const LocationAccessDialog({super.key, this.onConfirm});

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 2.0, right: 8.0),
            child: Text(
              '•',
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'location_access_needed'.tr,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Text(
                  'to_provide_accurate_delivery_tracking_and_updates_we_need_access_to_your_location'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                ),
                const SizedBox(height: 20.0),

                Text(
                  'why_we_need_it'.tr,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                _buildBulletPoint('show_your_live_location_on_the_map'.tr),
                _buildBulletPoint('provide_accurate_delivery_ETA'.tr),
                _buildBulletPoint('ensure_seamless_tracking_even_in_background_locked_mode'.tr),
                _buildBulletPoint('improve_delivery_efficiency_and_accuracy'.tr),
                const SizedBox(height: 20.0),

                Text(
                  'note'.tr,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Text(
                  'your_location_is_only_used_for_delivery_and_never_shared_with_third_parties'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                ),
                const SizedBox(height: 24.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'cancel'.tr,
                        style: robotoBold,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    TextButton(
                      onPressed: onConfirm,
                      child: Text(
                        'next'.tr,
                        style: robotoBold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Positioned(
            top: 10, right: 10,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                ),
                padding: const EdgeInsets.all(4.0),
                child: const Icon(Icons.close, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}