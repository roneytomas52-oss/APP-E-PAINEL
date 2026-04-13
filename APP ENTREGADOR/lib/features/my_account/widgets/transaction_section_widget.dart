import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/my_account/controllers/my_account_controller.dart';
import 'package:sixam_mart_delivery/helper/date_converter_helper.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/helper/string_extension.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class TransactionSectionWidget extends StatelessWidget {
  final MyAccountController myAccountController;

  const TransactionSectionWidget({super.key, required this.myAccountController});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        myAccountController.selectedIndex == 0 ? 'withdraw_request'.tr : myAccountController.selectedIndex == 1 ? 'transaction_history'.tr : 'wallet_history'.tr,
        style: robotoSemiBold,
      ),
      const SizedBox(height: Dimensions.paddingSizeDefault),

      _buildTransactionContent(context),
    ]);
  }

  Widget _buildTransactionContent(BuildContext context) {
    switch (myAccountController.selectedIndex) {
      case 0:
        return EarningListWidget(
          transactions: myAccountController.withdrawRequestList,
          selectedIndex: myAccountController.selectedIndex,
        );
      case 1:
        return EarningListWidget(
          transactions: myAccountController.transactions,
          selectedIndex: myAccountController.selectedIndex,
        );
      case 2:
        return EarningListWidget(
          transactions: myAccountController.walletProvidedTransactions,
          selectedIndex: myAccountController.selectedIndex,
        );
      default:
        return const SizedBox();
    }
  }
}


class EarningListWidget extends StatelessWidget {
  final List<dynamic>? transactions;
  final int selectedIndex;
  const EarningListWidget({super.key, required this.transactions, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    if (transactions == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 250),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (transactions!.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: selectedIndex == 0 ? 115 : 250),
          child: Column(
            children: [
              Image.asset(Images.emptyTransaction, width: 50, height: 50,),
              SizedBox(height: Dimensions.paddingSizeSmall,),

              Text(selectedIndex == 0 ? 'no_withdraw_found'.tr : selectedIndex == 1 ? 'no_transaction_found'.tr : 'no_wallet_history'.tr),
            ],
          )
        ),
      );
    }

    return ListView.builder(
      itemCount: transactions!.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = transactions![index];
        return TransactionItemWidget(
          amount: item.amount,
          method: selectedIndex == 0 ? '${'withdraw_via'.tr} ${item.bankName}' : '${selectedIndex == 1 ? 'paid_via'.tr : 'wallet'.tr} ${item.method}',
          date: selectedIndex == 0 ? DateConverterHelper.utcToDateTime(item.requestedAt) : item.paymentTime.toString(),
          status: item.status,
          statusColor: _getStatusColor(context, item.status),
          fromWalletEarning: selectedIndex == 2,
        );
      },
    );
  }

  Color _getStatusColor(BuildContext context, String? status) {
    switch (status) {
      case 'approved' || 'Approved':
        return Theme.of(context).primaryColor;
      case 'denied':
        return Theme.of(context).colorScheme.error;
      default:
        return Colors.blue;
    }
  }
}

class TransactionItemWidget extends StatelessWidget {
  final double amount;
  final String method;
  final String date;
  final String status;
  final Color statusColor;
  final bool fromWalletEarning;
  const TransactionItemWidget({super.key, required this.amount, required this.method, required this.date, required this.status, required this.statusColor, required this.fromWalletEarning});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  Text(
                    PriceConverterHelper.convertPrice(amount),
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                    textDirection: TextDirection.ltr,
                  ),

                  if(fromWalletEarning)
                    Container(
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeExtraSmall,
                        vertical: 2,
                      ),
                      margin: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
                      child: Text(
                        status.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: statusColor,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Text(
                method.toTitleCase(),
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: Theme.of(context).disabledColor,
                ),
              ),
            ]),
          ),

          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              date,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).disabledColor,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            if(!fromWalletEarning)
            Text(
              status.tr,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: statusColor,
              ),
            ),
          ]),
        ]),
      ),

      const Divider(height: 1),
    ]);
  }
}