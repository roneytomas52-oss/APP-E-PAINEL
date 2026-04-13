import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:sixam_mart_delivery/features/my_account/controllers/my_account_controller.dart';
import 'package:sixam_mart_delivery/features/my_account/widgets/reports/earning_report_card.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
class OrderViewWidget extends StatelessWidget {
  final MyAccountController myAccountController;
  const OrderViewWidget({super.key, required this.myAccountController});

  @override
  Widget build(BuildContext context) {
    return myAccountController.earningList != null ? myAccountController.earningList!.isNotEmpty ? ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: myAccountController.earningList!.length,
      itemBuilder: (context, index) {
        return EarningReportCard(
          index: index,
          myAccountController: myAccountController,
          earning: myAccountController.earningList![index],
          refrealEarnings: null,
          loyalityPoints: null,
          createdAt: myAccountController.earningList![index].createAt!,
          showDivider: index != myAccountController.earningList!.length - 1,
        );
      },
    ) : Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Text(
          'no_earning_found'.tr,
          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
        ),
      ),
    ) : Center(child: CircularProgressIndicator());
  }
}
