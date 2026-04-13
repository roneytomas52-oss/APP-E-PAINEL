import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_drop_down_button.dart';
import 'package:sixam_mart_delivery/features/my_account/controllers/my_account_controller.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class MyEarningFilterScreen extends StatefulWidget {
  const MyEarningFilterScreen({super.key});

  @override
  State<MyEarningFilterScreen> createState() => _MyEarningFilterScreenState();
}

class _MyEarningFilterScreenState extends State<MyEarningFilterScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'filter_by'.tr),

      body: GetBuilder<MyAccountController>(builder: (myAccountController) {
        return Column(children: [

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(children: [

                CustomDropdownButton(
                  hintText: 'select_earning_types'.tr,
                  dropdownMenuItems: myAccountController.earningTypes.map((type) => DropdownMenuItem<String>(
                    value: type,
                    child: Text(type.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
                  )).toList(),
                  isBorder: true,
                  backgroundColor: Theme.of(context).cardColor,
                  onChanged: (value) {
                    myAccountController.setEarningType(value);
                  },
                  selectedValue: myAccountController.selectedEarningType,
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                CustomDropdownButton(
                  hintText: 'select_date_range'.tr,
                  dropdownMenuItems: myAccountController.dateTypes.map((range) => DropdownMenuItem<String>(
                    value: range,
                    child: Text(range.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
                  )).toList(),
                  isBorder: true,
                  backgroundColor: Theme.of(context).cardColor,
                  onChanged: (value) {
                    myAccountController.setDateType(value);
                  },
                  selectedValue: myAccountController.selectedDateType,
                ),

                Visibility(
                  visible: myAccountController.selectedDateType == 'custom_date_range',
                  child: Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    margin: const EdgeInsetsDirectional.only(top: Dimensions.paddingSizeExtraLarge),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                      myAccountController.from != null && myAccountController.to != null ? Text(
                        '${myAccountController.from} - ${myAccountController.to}', style: robotoRegular,
                      ) : Text('custom_date_range'.tr, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.5))),

                      InkWell(
                        onTap: () {
                          myAccountController.showDatePicker(context);
                        },
                        child: Icon(Icons.calendar_month_rounded, color: Theme.of(context).hintColor),
                      ),

                    ]),
                  ),
                ),

              ]),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
            ),
            child: Row(children: [

              Expanded(
                child: CustomButtonWidget(
                  buttonText: 'reset'.tr,
                  backgroundColor: Theme.of(context).disabledColor.withValues(alpha: 0.25),
                  fontColor: Theme.of(context).textTheme.bodyLarge!.color,
                  onPressed: () {
                    // myAccountController.resetEarningFilter();
                    // myAccountController.getEarningReport(
                    //   offset: '1',
                    //   startDate: myAccountController.from, endDate: myAccountController.to,
                    //   type: myAccountController.selectedEarningType,
                    // ).then((value) {
                    //   Get.back(result: true);
                    // });
                  },
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Expanded(
                child: CustomButtonWidget(
                  buttonText: 'apply_filter'.tr,
                  isLoading: myAccountController.isLoading,
                  onPressed: () {
                    // myAccountController.showBottomLoader();
                    // myAccountController.getEarningReport(
                    //   offset: 1.toString(),
                    //   startDate: myAccountController.from, endDate: myAccountController.to,
                    //   type: myAccountController.selectedEarningType,
                    //   fromFilter: true,
                    // ).then((value) {
                    //   Get.back(result: true);
                    // });
                  },
                ),
              ),

            ]),
          ),

        ]);
      }),
    );
  }
}
