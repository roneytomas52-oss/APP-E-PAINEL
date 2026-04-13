import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/ride_share_module/ride_home/domain/models/ride_coupon_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
class RideCouponBottomSheet extends StatelessWidget {
  final Coupon coupon;
  const RideCouponBottomSheet({super.key, required this.coupon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            Container(
              height: 5, width: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              ),
              margin: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            CustomImage(image: coupon.imageUrl??'', height: 50,),
            const SizedBox(height: 16.0),

            // Coupon Code / Title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  coupon.couponCode??'',
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                ),
                // IconButton(
                //   icon: const Icon(Icons.copy, size: 16.0, color: Colors.blueGrey),
                //   onPressed: () {
                //     Clipboard.setData(ClipboardData(text: coupon.couponCode??''));
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       SnackBar(content: Text('Copied "${coupon.couponCode??''}" to clipboard!')),
                //     );
                //   },
                // ),
              ],
            ),
            const SizedBox(height: 4.0),

            // Validity
            Text(
              '${'valid_until'.tr}' ': ${coupon.endDate??''}',
              style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
            ),
            const SizedBox(height: 24.0),
            Text(
              coupon.description??'',
              textAlign: TextAlign.center,
              style: robotoRegular,
            ),
            const SizedBox(height: 24.0),
            // Discount Amount
            Text(
              '${'to_apply_coupon_need_minimum_trip_cost'.tr} ${PriceConverter.convertPrice(double.tryParse(coupon.minTripAmount??'')??0)} ${'and_get'.tr} ${PriceConverter.convertPrice(double.tryParse(coupon.maxCouponAmount??'')??0)} ${'maximum_discount'.tr}',
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge), textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),

            const SizedBox(height: 24.0),

            // Terms and Conditions Section
            // Container(
            //   decoration: BoxDecoration(
            //     color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
            //     borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            //   ),
            //   margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
            //   padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            //   alignment: Alignment.centerLeft,
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: <Widget>[
            //       _buildBulletPoint('This offer available only in Dhaka'),
            //       _buildBulletPoint('One user can use it maximum 5 times'),
            //       _buildBulletPoint('You Need to spend minimum \$200'),
            //     ],
            //   ),
            // ),

          ]),
        ),
      ),
    );
  }

}
