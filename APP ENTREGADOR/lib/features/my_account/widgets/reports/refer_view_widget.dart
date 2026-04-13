import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:sixam_mart_delivery/features/my_account/controllers/my_account_controller.dart';
import 'package:sixam_mart_delivery/features/my_account/widgets/reports/earning_report_card.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
class ReferViewWidget extends StatelessWidget {
  final MyAccountController myAccountController;
  const ReferViewWidget({super.key, required this.myAccountController});

  @override
  Widget build(BuildContext context) {
    return myAccountController.referralEarningsList != null ? myAccountController.referralEarningsList!.isNotEmpty ? ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: myAccountController.referralEarningsList!.length,
      itemBuilder: (context, index) {
        return EarningReportCard(
          index: index,
          myAccountController: myAccountController,
          earning: null,
          refrealEarnings: myAccountController.referralEarningsList![index],
          loyalityPoints: null,
          createdAt: myAccountController.referralEarningsList![index].createdAt!,
          showDivider: index != myAccountController.referralEarningsList!.length - 1,
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
