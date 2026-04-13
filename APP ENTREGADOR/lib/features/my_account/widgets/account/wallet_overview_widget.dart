import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/features/my_account/controllers/my_account_controller.dart';
import 'package:sixam_mart_delivery/features/my_account/widgets/amount_card_widget.dart';
import 'package:sixam_mart_delivery/features/my_account/widgets/empty_state_bottom_sheet.dart';
import 'package:sixam_mart_delivery/features/my_account/widgets/payment_method_bottom_sheet_widget.dart';
import 'package:sixam_mart_delivery/features/my_account/widgets/tab_section_widget.dart';
import 'package:sixam_mart_delivery/features/my_account/widgets/transaction_section_widget.dart';
import 'package:sixam_mart_delivery/features/my_account/widgets/wallet_attention_alert_widget.dart';
import 'package:sixam_mart_delivery/features/my_account/widgets/withdrawal_bottomsheet.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/enums.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
class WalletOverviewWidget extends StatelessWidget {
  const WalletOverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GetBuilder<MyAccountController>(builder: (myAccountController) {
        return GetBuilder<ProfileController>(builder: (profileController) {

          bool isPayable = profileController.profileModel != null && profileController.profileModel!.showPayNowButton == true;
          bool isAdjust = profileController.profileModel != null && profileController.profileModel!.adjustable == true;

          return (profileController.profileModel != null && myAccountController.transactions != null) ? Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(children: [

              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(children: [

                    isAdjust && !isPayable ? Container(
                      width: context.width,
                      padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                      ),
                      child: Row(children: [

                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                            Text('pay_able_balance'.tr, style: robotoSemiBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.5))),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                            Text(
                              PriceConverterHelper.convertPrice(profileController.profileModel!.payableBalance),
                              style: robotoSemiBold,
                            ),
                            const SizedBox(height: Dimensions.paddingSizeLarge),

                            Text('withdrawable_balance'.tr, style: robotoSemiBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.5))),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                            Text(
                              PriceConverterHelper.convertPrice(profileController.profileModel!.withDrawableBalance),
                              style: robotoSemiBold,
                            ),

                          ]),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        InkWell(
                          onTap: () {
                            showDialog(context: context, builder: (BuildContext context) {
                              return GetBuilder<MyAccountController>(builder: (myAccountController) {
                                return AlertDialog(
                                  title: Center(child: Text('cash_adjustment'.tr)),
                                  content: Text('cash_adjustment_description'.tr, textAlign: TextAlign.center),
                                  actions: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(children: [

                                        Expanded(
                                          child: SizedBox(
                                            height: 45,
                                            child: CustomButtonWidget(
                                              onPressed: () => Get.back(),
                                              backgroundColor: Theme.of(context).disabledColor.withValues(alpha: 0.5),
                                              buttonText: 'cancel'.tr,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: Dimensions.paddingSizeExtraLarge),

                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              myAccountController.makeWalletAdjustment();
                                            },
                                            child: Container(
                                              height: 45,
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                                color: Theme.of(context).primaryColor,
                                              ),
                                              child: !myAccountController.isLoading ? Text('ok'.tr, style: robotoBold.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeLarge),)
                                                  : const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white)),
                                            ),
                                          ),
                                        ),

                                      ]),
                                    ),
                                  ],
                                );
                              });
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                              color: Theme.of(context).primaryColor,
                            ),
                            child: Text('adjust_payments'.tr, textAlign: TextAlign.center, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor)),
                          ),
                        ),

                      ]),
                    ) : Container(
                      width: context.width,
                      padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        Text(isPayable ? 'pay_able_balance'.tr : 'withdrawable_balance'.tr, style: robotoSemiBold),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        Text(isPayable ? 'you_can_pay_the_amount_to_the_admin'.tr : 'you_can_send_withdraw_request_to_admin'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Container(
                          padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            color: Theme.of(context).cardColor,
                          ),
                          child: Row(children: [

                            CustomAssetImageWidget(
                              image: Images.balanceIcon, width: 40, height: 40,
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Expanded(
                              child: Text(
                                PriceConverterHelper.convertPrice(isPayable ? profileController.profileModel!.payableBalance : profileController.profileModel!.withDrawableBalance),
                                style: robotoSemiBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                                textDirection: TextDirection.ltr,
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            isPayable ? InkWell(
                              onTap: () {

                                bool isRideActive = AppConstants.appMode == AppMode.ride;
                                final config = Get.find<SplashController>().configModel;
                                double minimumPayableAmount = isRideActive ? (config?.minAmountToPayRider ?? 0) : (config?.minAmountToPayDm ?? 0);

                                if(Get.find<SplashController>().configModel!.activePaymentMethodList!.isEmpty || !Get.find<SplashController>().configModel!.digitalPayment!){
                                  showCustomBottomSheet(child: EmptyStateBottomSheet(noPaymentMethod: Get.find<SplashController>().configModel!.activePaymentMethodList!.isEmpty || !Get.find<SplashController>().configModel!.digitalPayment!));
                                }else if(minimumPayableAmount > profileController.profileModel!.payableBalance!){
                                  showCustomBottomSheet(child: const EmptyStateBottomSheet());
                                }else{
                                  showCustomBottomSheet(child: const PaymentMethodBottomSheetWidget());
                                }
                              },
                              child: Container(
                                width: 100,
                                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                                  color: Theme.of(context).primaryColor,
                                ),
                                child: Text('pay_now'.tr, textAlign: TextAlign.center, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor)),
                              ),
                            ) : InkWell(
                              onTap: () {
                                showCustomBottomSheet(child: WithdrawBottomSheet(withdrawAmount: profileController.profileModel?.withDrawableBalance ?? 0));
                              },
                              child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeSmall),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  child: Icon(Icons.arrow_forward_ios_rounded, color: Theme.of(context).cardColor, size: 20)
                              ),
                            ),

                          ]),
                        ),

                      ]),
                    ),

                    TabSectionWidget(
                      selectedIndex: myAccountController.selectedIndex,
                      onTabChanged: (index) {
                        if (myAccountController.selectedIndex != index) {
                          myAccountController.setIndex(index);
                        }
                      },
                    ),

                    myAccountController.selectedIndex == 0 ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Row( spacing: 10, children: [

                          AmountCardWidget(
                            title: 'pending_withdraw'.tr,
                            amount: profileController.profileModel?.pendingWithdraw ?? 0,
                            image: Images.pendingWithdrawIcon,
                            borderColor: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                          ),

                          AmountCardWidget(
                            title: 'total_withdrawn'.tr,
                            amount: profileController.profileModel?.totalWithdrawn ?? 0,
                            image: Images.alreadyWithdrawIcon,
                            borderColor: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                          ),

                          AmountCardWidget(
                            title: 'cash_in_hand'.tr,
                            amount: profileController.profileModel?.cashInHands ?? 0,
                            image: Images.pendingWithdrawIcon,
                            borderColor: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                          ),

                        ]),
                      ),
                    ) : const SizedBox(),
                    SizedBox(height: myAccountController.selectedIndex == 0 ? Dimensions.paddingSizeDefault : 0),

                    TransactionSectionWidget(myAccountController: myAccountController),
                  ]),

                ),
              ),

              (profileController.profileModel!.overFlowWarning! || profileController.profileModel!.overFlowBlockWarning!) ? WalletAttentionAlertWidget(
                isOverFlowBlockWarning: profileController.profileModel!.overFlowBlockWarning!,
              ) : const SizedBox(),

            ]),
          ) : const Center(child: CircularProgressIndicator());
        });
      }),
    );
  }
}
