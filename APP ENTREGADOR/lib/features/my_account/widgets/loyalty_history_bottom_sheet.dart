import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/my_account/domain/models/loyalty_report_model.dart';
import 'package:sixam_mart_delivery/helper/date_converter_helper.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class LoyaltyHistoryBottomSheet extends StatelessWidget {
  final LoyalityPoints? loyalityPoints;
  const LoyaltyHistoryBottomSheet({super.key, this.loyalityPoints});

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        Container(
          height: 5, width: 50,
          margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
        ),

        Text(
          'earning'.tr,
          style: robotoBold.copyWith(color: const Color(0xff313F38), fontSize: Dimensions.fontSizeExtraLarge)
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        Text(PriceConverterHelper.convertPrice(loyalityPoints?.convertedAmount??0), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge + 2, color: Theme.of(context).primaryColor)),

        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(text: 'transaction_id'.tr, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.5))),
              TextSpan(text: ': #', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.5))),
              TextSpan(text: loyalityPoints?.transactionId??'', style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color)),
            ],
          ),
        ),

        Text(DateConverterHelper.utcToDateTime(loyalityPoints!.createdAt!), style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),

        Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: const Color(0xff313F38).withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Column(children: [

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('${loyalityPoints?.point??0} ${'point'.tr}', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),

                  Icon(Icons.arrow_forward, color: Theme.of(context).hintColor),
                  Text(PriceConverterHelper.convertPrice(loyalityPoints?.convertedAmount??0), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                ]),

              ]),
            ),
          ]),
        ),

      ]),
    );
  }
}
