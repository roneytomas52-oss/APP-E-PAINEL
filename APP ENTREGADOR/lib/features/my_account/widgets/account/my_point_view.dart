import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/paginated_list_view_widget.dart';
import 'package:sixam_mart_delivery/features/my_account/controllers/my_account_controller.dart';
import 'package:sixam_mart_delivery/features/my_account/widgets/account/point_filter_bottom_sheet_widget.dart';
import 'package:sixam_mart_delivery/features/my_account/widgets/account/point_to_wallet_money_widget.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_delivery/helper/date_converter_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/enums.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class MyPointView extends StatefulWidget {
  const MyPointView({super.key});

  @override
  State<MyPointView> createState() => _MyPointViewState();
}

class _MyPointViewState extends State<MyPointView> {
  final ScrollController scrollController = ScrollController();
  bool isRideActive = AppConstants.appMode == AppMode.ride;

  @override
  void initState() {
    super.initState();

    Get.find<MyAccountController>().resetEarningFilter();
    Get.find<MyAccountController>().getLoyaltyPointList(
      offset: 1,
      startDate: Get.find<MyAccountController>().from, endDate: Get.find<MyAccountController>().to,
      fromFilter: false,
      dateRange: Get.find<MyAccountController>().selectedDateType,
      transactionType: Get.find<MyAccountController>().selectedTransactionType ?? 'both',
    );
  }
  
  @override
  Widget build(BuildContext context) {
    var config = Get.find<SplashController>().configModel;
    bool loyaltyPointStatus = isRideActive ? (config!.riderLoyalityPointData?.loyalityPointStatus ?? false) : ((config!.dmLoyalityPointData?.loyalityPointStatus ?? false)) ;

    if(!loyaltyPointStatus) {
      return Expanded(child: emptyView('your_loyalty_points_are_safe'.tr, context));
    }
    return Expanded(
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: GetBuilder<ProfileController>(builder: (profileController){
          return GetBuilder<MyAccountController>(builder: (myAccountController){
            if(myAccountController.loyaltyPointModel == null || myAccountController.isLoading) {
              return Padding(
                padding: const EdgeInsets.only(top: 250),
                child: const Center(child: CircularProgressIndicator()),
              );
            } else if (!myAccountController.isFiltered && myAccountController.loyaltyPointModel!.loyalityPoints != null && myAccountController.loyaltyPointModel!.loyalityPoints!.isEmpty) {
              return emptyView('our_loyalty_program_is_temporary_paused'.tr, context);
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                const SizedBox(height: Dimensions.paddingSizeDefault),

                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('convert_able_point'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                    const SizedBox(height: 3),
                    Text('convert_loyalty_point_to_wallet_money_once_you_have_enough_balance'.tr,
                      style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7)
                      ),
                    ),

                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        Image.asset(Images.payMoneyImage, height: 30,),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Expanded(
                          child: Text('${profileController.profileModel?.loyaltyPoint ?? "0"}',
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        InkWell(
                          onTap: () {

                            var config = Get.find<SplashController>().configModel;
                            bool loyaltyPointStatus = isRideActive ? (config!.riderLoyalityPointData?.loyalityPointStatus ?? false) : ((config!.dmLoyalityPointData?.loyalityPointStatus ?? false)) ;

                            if(loyaltyPointStatus){
                              showDialog(barrierDismissible: false,
                                context: context, builder: (_) =>  PointToWalletMoneyWidget(isRideActive: isRideActive),
                              );
                            }else{
                              showCustomSnackBar('point_conversion_is_currently_unavailable'.tr);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            ),
                            padding: const EdgeInsets.all(7),
                            child: Icon(Icons.arrow_forward_ios_rounded, color: Theme.of(context).cardColor, size: 20,),
                          ),
                        ),

                      ]),
                    ),
                  ]),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                  child: Row(
                    children: [
                      Text("point_history".tr, style: robotoBold),
                      const Spacer(),

                      InkWell(
                        onTap: () {
                          Get.bottomSheet(PointFilterBottomSheetWidget(
                            startDate: myAccountController.from,
                            endDate: myAccountController.to,
                            type: myAccountController.selectedDateType,
                            onApply: (dateRange, startDate, endDate) async {
                              if(startDate != null && endDate != null) {
                                await myAccountController.setDateRange(from: startDate, to: endDate);
                              }
                              if(dateRange != null) {
                                myAccountController.setDateType(dateRange);
                                Get.find<MyAccountController>().setOffset(1);
                                myAccountController.getLoyaltyPointList(
                                  offset: myAccountController.offset,
                                  startDate: myAccountController.from, endDate: myAccountController.to,
                                  fromFilter: true,
                                  dateRange: myAccountController.selectedDateType,
                                  transactionType: myAccountController.selectedTransactionType ?? 'both',
                                );
                              }
                            },
                            onReset: () {
                              myAccountController.resetEarningFilter();
                              Get.back();
                              myAccountController.getLoyaltyPointList(
                                offset: myAccountController.offset,
                                startDate: myAccountController.from, endDate: myAccountController.to,
                                fromFilter: false,
                                dateRange: myAccountController.selectedDateType,
                                transactionType: 'both',
                              );
                            },
                          ));
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                border: Border.all(color: Theme.of(context).primaryColor),
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              ),
                              child: Icon(Icons.filter_list_sharp,
                                size: 20,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),

                            if(myAccountController.isFiltered)
                              Positioned(
                                top: -4, right: -4,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: Container(
                                    height: 10, width: 10,
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                myAccountController.loyaltyPointModel != null ? (myAccountController.loyaltyPointModel?.loyalityPoints?.isNotEmpty ?? false) ? PaginatedListViewWidget(
                  scrollController: scrollController,
                  totalSize: myAccountController.loyaltyPointModel?.total,
                  offset: int.tryParse(myAccountController.loyaltyPointModel?.offset??'1'),
                  onPaginate: (int? offset) async => await myAccountController.getLoyaltyPointList(
                    offset: Get.find<MyAccountController>().offset,
                    startDate: Get.find<MyAccountController>().from, endDate: Get.find<MyAccountController>().to,
                    fromFilter: Get.find<MyAccountController>().isFiltered,
                    dateRange: Get.find<MyAccountController>().selectedDateType,
                    transactionType: Get.find<MyAccountController>().selectedTransactionType ?? 'both',
                  ),
                  productView: ListView.builder(
                    itemCount:  myAccountController.loyaltyPointModel?.loyalityPoints?.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding:  EdgeInsets.zero,
                    itemBuilder: (context, index) {

                      var point = myAccountController.loyaltyPointModel?.loyalityPoints?[index];
                      bool isCredit = point?.type == 'credit';
                      bool isOrder = point?.transactionType == 'earn_on_order_completion';

                      return Column(children: [

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Flexible(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(
                                  '${isOrder ? 'order_id'.tr : "transaction_id".tr}: ${isOrder ? point?.reference : point?.transactionId}',
                                  maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                ),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                Text(DateConverterHelper.formatUtcTime(point!.createdAt!),
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                                ),
                              ]),
                            ),

                            Flexible(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                Text(
                                  '${isCredit ? '+' : '-'} ${point.point ?? 0}',
                                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: isCredit ? Colors.green : Colors.red), textDirection: TextDirection.ltr,
                                ),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                Text(point.transactionType?.tr ?? "", style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor,
                                )),
                              ]),
                            ),

                          ]),
                        ),

                        const Divider(height: 1, thickness: 0.5,),
                      ]);
                    },
                  ),
                ) : SizedBox(
                  height: Get.height * 0.3,
                  child: Center(child: Text('no_point_history_found'.tr)),
                ): SizedBox(
                  height: Get.height * 0.3,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ]),
            );
          });
        }),
      ),
    );
  }

  Widget emptyView(String text, BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      SizedBox(height: context.height * 0.2),

      Image.asset(Images.payMoneyImage, height: 70),
      const SizedBox(height: Dimensions.paddingSizeLarge),

      Text(
        'stay_tuned_to_earn_points'.tr,
        style: robotoBold.copyWith(
          fontSize: Dimensions.fontSizeDefault,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      ),
      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

      Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
        ),
      ),

    ]);
  }
}
