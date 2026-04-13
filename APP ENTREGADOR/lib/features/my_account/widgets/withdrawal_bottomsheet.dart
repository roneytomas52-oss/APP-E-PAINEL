import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_dropdown_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_text_field_widget.dart';
import 'package:sixam_mart_delivery/features/disbursement/controllers/disbursement_controller.dart';
import 'package:sixam_mart_delivery/features/my_account/widgets/custom_drop_down.dart';
import 'package:sixam_mart_delivery/features/my_account/widgets/success_dialog_widget.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class WithdrawBottomSheet extends StatefulWidget {
  final double withdrawAmount;
  const WithdrawBottomSheet({super.key, required this.withdrawAmount});

  @override
  State<WithdrawBottomSheet> createState() => _WithdrawBottomSheetState();
}

class _WithdrawBottomSheetState extends State<WithdrawBottomSheet> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  List<DropdownItem<int>> payments = [];

  int selectedIndex = -1;
  final List<int> _suggestedAmount = [100, 200, 300, 400, 500];


  @override
  void initState() {
    super.initState();

    amountController.text = "${widget.withdrawAmount}";
    Get.find<DisbursementController>().updateSelectedWithdrawMethod(shouldUpdate: false);
    Get.find<DisbursementController>().setMethod(isUpdate: false);
  }

  @override
  Widget build(BuildContext context) {

    return GetBuilder<DisbursementController>(builder: (disburseController){

      var withdrawList = disburseController.disbursementMethodBody?.methods;

      payments = [];
      for(int index=0; index< (withdrawList?.length ?? 0); index++) {
        payments.add(DropdownItem<int>(value: index + 1, child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(withdrawList?[index].methodName ?? ""),
          ),
        )));
      }

      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 6, width: 30,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                CustomDropDown(
                  itemList: payments,
                  title: 'select_withdrawal_method'.tr,
                  onChange: (int? value, int index) {
                    disburseController.updateSelectedWithdrawMethod(newValue: withdrawList?[index]);
                  },
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                disburseController.selectedWithdrawMethod !=null ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                    border: Border.all(color: Theme.of(context).disabledColor, width: 0.5),
                  ),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Column(children: [

                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [

                      Expanded(
                        child: ListView.builder(
                          itemCount: disburseController.selectedWithdrawMethod?.methodFields!.length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeExtraSmall),
                              child: Row(children: [
                                Text(disburseController.selectedWithdrawMethod?.methodFields![index].userInput!.replaceAll('_', ' ').capitalizeFirst ?? "",
                                  style: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                                ),
                                Text(' : ', style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),

                                Text(
                                  '${disburseController.selectedWithdrawMethod?.methodFields![index].userData}',
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),

                              ]),
                            );
                          },
                        ),
                      ),

                    ])
                  ]),
                ) : const SizedBox(),

                const SizedBox(height: Dimensions.paddingSizeDefault),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'withdraw_amount'.tr,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                TextField(
                  controller: amountController,
                  textAlign: TextAlign.center,
                  style: robotoBold.copyWith(
                    color: widget.withdrawAmount >= _convertDouble(amountController.text) ?
                    Theme.of(context).primaryColor : Theme.of(context).colorScheme.error,
                    fontSize: Dimensions.fontSizeExtraLarge,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                  decoration: InputDecoration(
                    hintText: 'enter_amount'.tr,
                    hintStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
                    ),
                  ),
                  onChanged: (String value) {
                    selectedIndex = -1;
                    setState(() {});
                  },
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Padding(
                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall,
                    bottom: Dimensions.paddingSizeDefault,
                  ),
                  child: SizedBox(height: 60, child: ListView.builder(itemCount: _suggestedAmount.length,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemBuilder: (amountContext, index){
                      return GestureDetector(
                        onTap: (){
                          amountController.text = '${_suggestedAmount[index]}';
                          selectedIndex = index;
                          setState(() {});
                        },
                        child: Padding(
                          padding:const EdgeInsets.symmetric(
                            horizontal : Dimensions.paddingSizeExtraSmall,
                            vertical: Dimensions.paddingSizeSmall,
                          ),
                          child: Container(height: Get.height * 0.15,width: Get.width * 0.2,
                            decoration: BoxDecoration(
                              color:index == selectedIndex ? Theme.of(context).primaryColor :
                              Theme.of(context).disabledColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Text(PriceConverterHelper.convertPrice(_suggestedAmount[index].toDouble()),
                                style: robotoRegular.copyWith(color: index == selectedIndex ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'remark'.tr,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                CustomTextFieldWidget(
                  controller: noteController,
                  hintText: 'remark_text'.tr,
                  showLabelText: false,
                  maxLines: 2,
                  inputType: TextInputType.multiline,
                  inputAction: TextInputAction.done,
                  capitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                CustomButtonWidget(
                  buttonText: 'withdraw_request'.tr,
                  isLoading: disburseController.isLoading,
                  onPressed:  widget.withdrawAmount >= _convertDouble(amountController.text) ? () async {

                    if(disburseController.selectedWithdrawMethod == null){
                      showCustomSnackBar("select_withdrawal_method".tr);
                    } else if(_convertDouble(amountController.text) <= 0){
                      showCustomSnackBar("amount_should_not_be_zero".tr);
                    } else{
                      Map<String, dynamic> data = {};
                      data['id'] = disburseController.widthDrawMethods?[disburseController.selectedMethodIndex!].id.toString();
                      double amountValue = double.tryParse(amountController.text.trim()) ?? 0.0;
                      data['amount'] = amountValue.toStringAsFixed(2);
                      data['sender_note'] = noteController.text.trim();

                      for (int i = 0; i < disburseController.methodFields.length; i++) {
                        var result = disburseController.methodFields[i];

                        if (disburseController.selectedWithdrawMethod?.methodFields != null && disburseController.selectedWithdrawMethod!.methodFields!.isNotEmpty
                            && i < disburseController.selectedWithdrawMethod!.methodFields!.length) {
                          data[result.inputName!] = disburseController.selectedWithdrawMethod?.methodFields?[i].userData ?? '';
                        } else {
                          data[result.inputName!] = '';
                        }
                      }

                      await disburseController.createWithdrawRequest(data).then((success){
                        if(success){
                          Get.back();
                          Future.delayed(Duration(milliseconds: 1000),(){
                            Get.dialog(const SuccessDialogWidget());
                          });
                        }
                      });
                    }
                  } : null,
                ),

              ],
            ),
          ),
        ),
      );
    });
  }

  double _convertDouble(String text){
    try{
      return double.tryParse(text) ?? 0;
    }catch (e) {
      return 0;
    }
  }
}
