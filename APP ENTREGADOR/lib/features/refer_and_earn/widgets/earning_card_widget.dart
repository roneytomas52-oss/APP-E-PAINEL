import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/refer_and_earn/domain/models/refer_and_earn_model.dart';
import 'package:sixam_mart_delivery/helper/date_converter_helper.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class EarningCartWidget extends StatelessWidget {
  final RefrealEarnings transaction;
  const EarningCartWidget({super.key,required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        child: Row(children: [

          Expanded(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 4, children: [
              Text(
                PriceConverterHelper.convertPrice(transaction.amount ?? 0), style: robotoBold,
              ),

              Text(
                '${'trnx'.tr} : ${transaction.transactionId}', maxLines: 1, overflow: TextOverflow.ellipsis,
                style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7)),
              ),

            ])),
          ])),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
            child: Text(DateConverterHelper.isoStringToDateTimeString(transaction.createdAt ?? '2024-07-13T04:59:40.000000Z'),
                style: robotoRegular.copyWith(color: Theme.of(context).hintColor,fontSize: Dimensions.fontSizeSmall)),
          )

        ]),
      ),

    ]);
  }
}