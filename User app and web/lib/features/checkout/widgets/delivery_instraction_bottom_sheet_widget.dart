import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class DeliveryInstractionBottomSheetWidget extends StatefulWidget {
  const DeliveryInstractionBottomSheetWidget({super.key});

  @override
  State<DeliveryInstractionBottomSheetWidget> createState() => _DeliveryInstractionBottomSheetWidgetState();
}

class _DeliveryInstractionBottomSheetWidgetState extends State<DeliveryInstractionBottomSheetWidget> {
  int selectIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 550,
      margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 30),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: ResponsiveHelper.isMobile(context) ? const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge))
            : const BorderRadius.all(Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
        child: Column(children: [
          !ResponsiveHelper.isDesktop(context) ? Container(
            height: 4, width: 35,
            margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(10)),
          ) : const SizedBox(),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('select_delivery_instruction'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
            IconButton(
              onPressed: () => Get.back(),
              icon: Icon(Icons.clear, color: Theme.of(context).disabledColor),
            )
          ]),

          GetBuilder<CheckoutController>(
            builder: (checkoutController) {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: AppConstants.deliveryInstructionList.length,
                  itemBuilder: (context, index){
                    bool isSelected = selectIndex == index;
                return InkWell(
                  onTap: () {
                    setState(() {
                      selectIndex = index;
                    });
                    // cartController.setAvailableIndex(index);
                    // Get.back();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, width: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                    margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                    child: Text(
                      AppConstants.deliveryInstructionList[index].tr,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: isSelected ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).disabledColor),
                    ),
                  ),
                );
              });
            }
          ),

          SafeArea(
            child: CustomButton(
              buttonText: 'apply'.tr,
              onPressed: selectIndex == -1 ? null : () {
                Get.find<CheckoutController>().setInstruction(selectIndex);
                Get.back();
              },
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge)
        ]),
      ),
    );
  }
}
