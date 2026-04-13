import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_text_field_widget.dart';
import 'package:sixam_mart_delivery/features/disbursement/controllers/disbursement_controller.dart';
import 'package:sixam_mart_delivery/features/disbursement/domain/models/disbursement_method_model.dart';
import 'package:sixam_mart_delivery/helper/date_converter_helper.dart';
import 'package:sixam_mart_delivery/helper/string_extension.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_dropdown_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';

class EditWithdrawMethodScreen extends StatefulWidget {
  final Methods method;
  const EditWithdrawMethodScreen({super.key, required this.method});

  @override
  State<EditWithdrawMethodScreen> createState() => _EditWithdrawMethodScreenState();
}

class _EditWithdrawMethodScreenState extends State<EditWithdrawMethodScreen> {

  @override
  void initState() {
    super.initState();
    DisbursementController disbursementController = Get.find<DisbursementController>();

    disbursementController.setMethodForEdit(widget.method);
  }

  @override
  Widget build(BuildContext context) {
    return  GetBuilder<DisbursementController>(builder: (disbursementController) {

      return Scaffold(
        appBar: CustomAppBarWidget(title: 'edit_withdraw_method'.tr),

        body: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

          Flexible(
            child: CustomCard(
              margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                  Stack(clipBehavior: Clip.none, children: [
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        color: Theme.of(context).cardColor,
                        border: Border.all(color: Theme.of(context).disabledColor, width: 0.3),
                      ),
                      child: CustomDropdown<int>(
                        onChange: (int? value, int index) {
                          disbursementController.setMethodId(index);
                          disbursementController.setMethod();
                        },
                        dropdownButtonStyle: DropdownButtonStyle(
                          padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeExtraSmall,
                            horizontal: Dimensions.paddingSizeExtraSmall,
                          ),
                          primaryColor: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                        dropdownStyle: DropdownStyle(
                          elevation: 10,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                        ),
                        items: disbursementController.methodList,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            disbursementController.widthDrawMethods != null && disbursementController.widthDrawMethods!.isNotEmpty
                                ? disbursementController.widthDrawMethods![disbursementController.selectedMethodIndex!].methodName! : 'select_payment_method'.tr,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      left: 10, top: -10,
                      child: Container(
                        color: Theme.of(context).cardColor,
                        padding: const EdgeInsets.all(2),
                        child: Row(children: [
                          Text('select_method'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor)),
                          Text(' *', style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeExtraSmall)),
                        ]),
                      ),
                    ),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: disbursementController.methodFields.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Column(children: [

                        Row(children: [

                          Expanded(
                            child: CustomTextFieldWidget(
                              labelText: disbursementController.methodFields[index].inputName.toString().replaceAll('_', ' ').toTitleCase(),
                              hintText: disbursementController.methodFields[index].placeholder!,
                              controller: disbursementController.textControllerList[index],
                              capitalization: TextCapitalization.words,
                              inputType: disbursementController.methodFields[index].inputType == 'phone' ? TextInputType.phone : disbursementController.methodFields[index].inputType == 'number'
                                  ? TextInputType.number : disbursementController.methodFields[index].inputType == 'email' ? TextInputType.emailAddress : TextInputType.name,
                              focusNode: disbursementController.focusList[index],
                              nextFocus: index != disbursementController.methodFields.length-1 ? disbursementController.focusList[index + 1] : null,
                              isRequired: disbursementController.methodFields[index].isRequired == 1,
                            ),
                          ),
                          SizedBox(width: disbursementController.methodFields[index].inputType == 'date' ? Dimensions.paddingSizeExtraLarge : 0),

                          disbursementController.methodFields[index].inputType == 'date' ? InkWell(
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                String formattedDate = DateConverterHelper.dateTimeForCoupon(pickedDate);
                                setState(() {
                                  disbursementController.textControllerList[index].text = formattedDate;
                                });
                              }

                            },
                            child: Icon(Icons.calendar_month_sharp, color: Theme.of(context).hintColor),
                          ) : const SizedBox(),

                        ]),
                        SizedBox(height: index != disbursementController.methodFields.length-1 ? Dimensions.paddingSizeLarge : 0),

                      ]);
                    },
                  ),

                ]),
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge, vertical: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)],
            ),
            child: CustomButtonWidget(
              isLoading: disbursementController.isLoading,
              buttonText: 'edit_method'.tr,
              onPressed: () {
                bool fieldEmpty = false;
                for (var element in disbursementController.methodFields) {
                  if(element.isRequired == 1){
                    if(disbursementController.textControllerList[disbursementController.methodFields.indexOf(element)].text.isEmpty){
                      fieldEmpty = true;
                    }
                  }
                }

                if(fieldEmpty){
                  showCustomSnackBar('required_fields_can_not_be_empty'.tr);
                }else{
                  Map<String?, String> data = {};
                  data['disbursement_withdrawal_method_id'] = widget.method.id.toString();
                  data['withdraw_method_id'] = disbursementController.widthDrawMethods![disbursementController.selectedMethodIndex!].id.toString();
                  for (var result in disbursementController.methodFields) {
                    data[result.inputName] = disbursementController.textControllerList[disbursementController.methodFields.indexOf(result)].text.trim();
                  }
                  disbursementController.addWithdrawMethod(data, isUpdate: true);
                }
              },
            ),
          ),

        ]),
      );
    });
  }
}
