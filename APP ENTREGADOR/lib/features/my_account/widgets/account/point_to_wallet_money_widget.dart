import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_delivery/features/my_account/controllers/my_account_controller.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/enums.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class PointToWalletMoneyWidget extends StatefulWidget {
  final bool isRideActive;
  const PointToWalletMoneyWidget({super.key, required this.isRideActive});

  @override
  State<PointToWalletMoneyWidget> createState() =>
      _PointToWalletMoneyWidgetState();
}

class _PointToWalletMoneyWidgetState extends State<PointToWalletMoneyWidget> {
  int selectedIndex = -1;

  final List<int> _suggestedAmount = [100, 200, 300, 400, 500];
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    amountController.text = Get.find<ProfileController>().profileModel?.loyaltyPoint.toString() ?? '0';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      surfaceTintColor: Theme.of(context).cardColor,
      insetPadding:
      const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
      ),
      child: GetBuilder<MyAccountController>(builder: (myAccountController) {
        bool isRideActive = AppConstants.appMode == AppMode.ride;
        final config = Get.find<SplashController>().configModel;
        final int enteredPoint = int.tryParse(amountController.text) ?? 0;
        final int minPoint = isRideActive ? (config?.riderLoyalityPointData?.minLoyalityPointToConvert ?? 0) : (config?.dmLoyalityPointData?.minLoyalityPointToConvert ?? 0);
        final int availablePoint = Get.find<ProfileController>().profileModel?.loyaltyPoint ?? 0;
        final int conversionRate = isRideActive ? (config?.riderLoyalityPointData?.loyalityPointConversionRate ?? 1) : (config?.dmLoyalityPointData?.loyalityPointConversionRate ?? 1);
        final bool isValid = enteredPoint >= minPoint && enteredPoint <= availablePoint && enteredPoint > 0;

        return Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            /// Close Button
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: Get.back,
                child: Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    Images.crossIcon,
                    height: Dimensions.paddingSizeSmall,
                    width: Dimensions.paddingSizeSmall,
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                ),
              ),
            ),

            /// Title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              child: Text(
                'convert_point_to_wallet_money'.tr,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
              ),
            ),

            /// Conversion Rate
            Text(
              '${'conversion_rate_is'.tr}: ''${conversionRate}pt = ''${Get.find<SplashController>().configModel?.currencySymbol}1',
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
            ),

            /// Input Field
            IntrinsicWidth(
              child: TextFormField(
                controller: amountController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'enter_point'.tr,
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
                ),
                style: robotoBold.copyWith(
                  color: enteredPoint <= availablePoint ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.error,
                ),
                onChanged: (_) {
                  selectedIndex = -1;
                  setState(() {});
                },
              ),
            ),

            Divider(color: Theme.of(context).hintColor, thickness: 0.5),

            /// Converted Amount
            Text(
              '${'convertible_amount'.tr}: ''${PriceConverterHelper.convertPrice(enteredPoint / conversionRate)}',
              style: robotoRegular,
            ),

            /// Suggested Amounts
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _suggestedAmount.length,
                itemBuilder: (_, index) {
                  final bool selected = index == selectedIndex;
                  return GestureDetector(
                    onTap: () {
                      amountController.text = _suggestedAmount[index].toString();
                      selectedIndex = index;
                      setState(() {});
                    },
                    child: Container(
                      width: Get.width * 0.2,
                      margin: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeExtraSmall,
                        vertical: Dimensions.paddingSizeSmall,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withValues(alpha: .35),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _suggestedAmount[index].toString(),
                          style: robotoRegular.copyWith(
                            color: selected ? Colors.white : Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            /// Validation Messages
            if (enteredPoint < minPoint)
              _errorText('${'conversion_point_must_be_at_least'.tr} $minPoint')
            else if (enteredPoint > availablePoint)
              _errorText('${'you_can_convert_up_to'.tr} $availablePoint ${'points'.tr}'),

            /// Convert Button
            Padding(
              padding: const EdgeInsets.only(
                top: Dimensions.paddingSizeExtraLarge,
                bottom: Dimensions.paddingSizeDefault,
              ),
              child: CustomButtonWidget(
                buttonText: 'convert_point'.tr,
                isLoading: myAccountController.isLoading,
                backgroundColor: Theme.of(context).primaryColor,
                disabledColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                disabledFontColor: Colors.white,
                radius: 10,
                onPressed: isValid ? () {
                  myAccountController.convertPoint(enteredPoint.toString(), isRideActive: isRideActive).then((value) {
                    if (value.statusCode == 200) {
                      Get.back();
                      showCustomSnackBar('successfully_converted_to_wallet_money'.tr, isError: false);
                    }
                  });
                } : null,
              ),
            ),
          ]),
        );
      }),
    );
  }

  Widget _errorText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        textAlign: TextAlign.center, style: robotoRegular.copyWith(color: Colors.red, fontSize: Dimensions.fontSizeSmall),
      ),
    );
  }
}
