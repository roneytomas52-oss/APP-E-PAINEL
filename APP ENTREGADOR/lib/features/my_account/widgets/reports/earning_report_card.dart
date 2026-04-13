import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:sixam_mart_delivery/features/my_account/controllers/my_account_controller.dart';
import 'package:sixam_mart_delivery/features/my_account/domain/models/earning_report_model.dart';
import 'package:sixam_mart_delivery/features/my_account/domain/models/loyalty_report_model.dart';
import 'package:sixam_mart_delivery/features/my_account/domain/models/referral_report_model.dart';
import 'package:sixam_mart_delivery/features/my_account/widgets/earning_history_bottom_sheet.dart';
import 'package:sixam_mart_delivery/features/my_account/widgets/loyalty_history_bottom_sheet.dart';
import 'package:sixam_mart_delivery/features/my_account/widgets/referral_history_bottom_sheet.dart';
import 'package:sixam_mart_delivery/helper/date_converter_helper.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class EarningReportCard extends StatelessWidget {
  final int index;
  final MyAccountController myAccountController;
  final Data? earning;
  final String createdAt;
  final bool showDivider;
  final RefrealEarnings? refrealEarnings;
  final LoyalityPoints? loyalityPoints;
  const EarningReportCard({
    super.key, required this.index, required this.myAccountController, required this.earning,
    required this.createdAt, required this.showDivider, required this.refrealEarnings, required this.loyalityPoints,
  });

  @override
  Widget build(BuildContext context) {
    double amount = 0;
    if(earning != null) {
      amount = (earning!.dmTips ?? 0) + (earning!.originalDeliveryCharge ?? 0);
    } else if(refrealEarnings != null) {
      amount = refrealEarnings!.amount ?? 0;
    } else if(loyalityPoints != null) {
      amount = loyalityPoints!.convertedAmount??0;
    }
    return InkWell(
      onTap: () {
        if(earning != null) {
          showCustomBottomSheet(child: EarningHistoryBottomSheet(data: earning));
        } else if(refrealEarnings != null) {
          showCustomBottomSheet(child: ReferralHistoryBottomSheet(refrealEarnings: refrealEarnings));
        } else if(loyalityPoints != null) {
          showCustomBottomSheet(child: LoyaltyHistoryBottomSheet(loyalityPoints: loyalityPoints));
        }
      },
      child: Column(children: [
        Container(
          margin: EdgeInsets.only(bottom: index == myAccountController.earningList!.length - 1 ? 0 : Dimensions.paddingSizeSmall),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
                Text(
                  PriceConverterHelper.convertPrice(amount),
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),

                if (earning != null && earning!.order?.id != null)...[
                  Text('${'order'.tr} #${earning!.order?.id}', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.6), fontSize: Dimensions.fontSizeSmall)),
                ] else if(refrealEarnings != null)...[
                  Text(
                    '${'transaction_id'.tr} #${refrealEarnings!.transactionId}', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.6), fontSize: Dimensions.fontSizeSmall),
                  ),
                ] else if(loyalityPoints != null)...[
                  Text(
                    '${'transaction_id'.tr} #${loyalityPoints!.transactionId}', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.6), fontSize: Dimensions.fontSizeSmall),
                  ),
                  Text(
                    loyalityPoints!.transactionType!.tr, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.6), fontSize: Dimensions.fontSizeSmall),
                  ),

                ],

                if (earning != null)
                  Row(
                    children: [
                      if (earning?.originalDeliveryCharge != 0)
                        Text(
                          'delivery_fee'.tr,
                          style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                        ),

                      if (earning?.originalDeliveryCharge != 0 && earning?.dmTips != 0)
                        Text(', ', style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),

                      if (earning?.dmTips != 0)
                        Text(
                          'delivery_tips'.tr,
                          style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                        ),
                    ],
                  ),
              ]),
            ),
            // const Spacer(),

            Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(DateConverterHelper.utcToDateTime(createdAt), style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: Icon(Icons.arrow_forward_ios, size: 12,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ]),
          ]),
        ),

        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeDefault),
            child: DottedBorder(
              options: RoundedRectDottedBorderOptions(
                color: Theme.of(context).hintColor.withValues(alpha: 0.2), strokeWidth: 1, dashPattern: const [4, 8],
                padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                radius: Radius.zero,
              ),
              child: Container(),
            ),
          ),
      ]),
    );
  }
}
