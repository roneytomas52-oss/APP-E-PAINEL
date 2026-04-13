import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_ink_well_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/paginated_list_view_widget.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/refer_and_earn/controllers/refer_and_earn_controller.dart';
import 'package:sixam_mart_delivery/features/refer_and_earn/widgets/earning_card_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/filter_bottom_sheet_widget.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class ReferralEarningScreen extends StatelessWidget {
  const ReferralEarningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: ()async {
          await Get.find<ReferAndEarnController>().getEarningHistoryList(1);
          await Get.find<ProfileController>().getProfile();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall,horizontal: Dimensions.paddingSizeDefault),
          child: GetBuilder<ReferAndEarnController>(builder: (referAndEarnController){
            return Column(children: [

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
                  boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.3), blurRadius: 10)],
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('your_earning'.tr),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Text(PriceConverterHelper.convertPrice(Get.find<ProfileController>().profileModel?.referalEarning ?? 0),style: robotoBold.copyWith(fontSize: 20))
                  ]),

                  Image.asset(Images.referCoin,height: 40,width: 40)
                ]),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                child: Row(children: [
                  Expanded(
                    child: Text('earning_history'.tr, style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    )),
                  ),

                  CustomInkWellWidget(
                    onTap: () {
                      Get.bottomSheet(FilterBottomSheetWidget(
                        startDate: referAndEarnController.startDate,
                        endDate: referAndEarnController.endDate,
                        type: referAndEarnController.dateRange,
                        onApply: (dateRange, startDate, endDate) {
                          referAndEarnController.setDateRange(dateRange!, startDate: startDate, endDate: endDate);
                          referAndEarnController.getEarningHistoryList(1);
                        },
                        onReset: () {
                          Get.back();
                          referAndEarnController.setDateRange('this_year', startDate: null, endDate: null);
                          referAndEarnController.getEarningHistoryList(1);
                        },
                      ));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      padding: EdgeInsets.all(3),
                      child: Icon(Icons.filter_list, color: Theme.of(context).primaryColor),
                    ),
                  ),

                ]),
              ),
              Divider(thickness: .25,color: Theme.of(context).primaryColor.withValues(alpha: 0.25)),

              (referAndEarnController.referralModel?.refrealEarnings != null && !referAndEarnController.isLoading) ? (referAndEarnController.referralModel!.refrealEarnings!.isNotEmpty) ? Expanded(
                child: SingleChildScrollView(
                  controller: referAndEarnController.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: PaginatedListViewWidget(
                    scrollController: referAndEarnController.scrollController,
                    totalSize: referAndEarnController.referralModel!.total,
                    offset: (referAndEarnController.referralModel?.offset != null) ? int.parse(referAndEarnController.referralModel!.offset.toString()) : null,
                    onPaginate: (int? offset) async {
                      await referAndEarnController.getEarningHistoryList(offset!);
                    },
                    productView: ListView.separated(
                      itemCount: referAndEarnController.referralModel!.refrealEarnings!.length,
                      padding: const EdgeInsets.all(0),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return EarningCartWidget(transaction: referAndEarnController.referralModel!.refrealEarnings![index]);
                      },
                      separatorBuilder: (context, index){
                        return Divider(height: 25, thickness: 0.5,color: Theme.of(context).hintColor.withValues(alpha: 0.75));
                      },
                    ),
                  ),
                ),
              ) : Center(child: Padding(
                padding:  EdgeInsets.only(top: Get.height * 0.15),
                child: Text('no_transaction_found'.tr),
              )) : const Center(child: CircularProgressIndicator()),

            ]);
          }),
        ),
      ),
    );
  }
}