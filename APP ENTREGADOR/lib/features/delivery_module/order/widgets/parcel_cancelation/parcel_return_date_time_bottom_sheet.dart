import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/widgets/parcel_cancelation/time_picker_widget.dart';
import 'package:sixam_mart_delivery/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class ParcelReturnDateTimeBottomSheet extends StatefulWidget {
  final int orderId;
  final String canceledDateTime;
  const ParcelReturnDateTimeBottomSheet({super.key, required this.orderId, required this.canceledDateTime});

  @override
  State<ParcelReturnDateTimeBottomSheet> createState() => _ParcelReturnDateTimeBottomSheetState();
}

class _ParcelReturnDateTimeBottomSheetState extends State<ParcelReturnDateTimeBottomSheet> {
  late OrderController returnController;

  @override
  void initState() {
    super.initState();
    returnController = Get.find<OrderController>();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (splashController) {
      // Initialize dates when splashController is ready
      final returnDays = int.tryParse(splashController.configModel?.parcelReturnTimeFee?.parcelReturnTime?.toString() ?? '4') ?? 4;

      // Initialize dates on first build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        returnController.initializeDates(widget.canceledDateTime, returnDays);
      });

      return Container(
        width: context.width,
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radiusExtraLarge),
            topRight: Radius.circular(Dimensions.radiusExtraLarge),
          ),
        ),
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _buildTopHandle(),
              _buildHeader(),
              _buildDateSelection(),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              _buildTimeSelection(),
              const SizedBox(height: 40),
              _buildActionButtons(),
            ]),
          ),
          _buildCloseButton(),
        ]),
      );
    });
  }

  Widget _buildTopHandle() {
    return Column(children: [
      Center(
        child: Container(
          height: 5, width: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
        ),
      ),
      const SizedBox(height: Dimensions.paddingSizeLarge),
    ]);
  }

  Widget _buildHeader() {
    return Column(children: [
      Text(
        'set_return_date_and_estimated_time'.tr,
        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: Dimensions.paddingSizeSmall),
      Text(
        'please_select_a_suitable_return_date_and_estimated_delivery_time_for_your_parcel'.tr,
        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: Dimensions.paddingSizeLarge),

      Text(
        'return_fine_description'.tr,
        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: Dimensions.paddingSizeSmall),

      Text(
        PriceConverterHelper.convertPrice(Get.find<OrderController>().orderModel?.parcelCancellation?.dmPenaltyFee ?? 0),
        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
        textAlign: TextAlign.center,
      ),

      const SizedBox(height: Dimensions.paddingSizeLarge),
    ]);
  }

  Widget _buildDateSelection() {
    return GetBuilder<OrderController>(builder: (controller) {
      return Container(
        width: context.width,
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('date'.tr, style: robotoMedium),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          SizedBox(
            height: 40,
            child: controller.availableDates.isEmpty ? const Center(child: CircularProgressIndicator()) : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.availableDates.length,
              itemBuilder: (context, index) {
                final date = controller.availableDates[index];
                final isSelected = controller.isDateSelected(date);

                return GestureDetector(
                  onTap: () => controller.selectDate(date),
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(right: index == controller.availableDates.length - 1 ? 0 : Dimensions.paddingSizeSmall),
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge, vertical: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          controller.formatDate(date),
                          style: robotoRegular.copyWith(
                            color: isSelected ? Colors.white : null,
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ]),
      );
    });
  }

  Widget _buildTimeSelection() {
    return GetBuilder<OrderController>(builder: (controller) {
      return Container(
        width: context.width,
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('estimated_delivery_time'.tr, style: robotoMedium),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Row(children: [
            // Hour picker
            TimePickerWidget(
              times: List.generate(12, (index) => (index + 1).toString()),
              onChanged: (int index) {
                controller.selectHour(index + 1);
              },
              initialPosition: controller.selectedHour - 1,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: Text(':', style: robotoBold),
            ),

            // Minute picker
            TimePickerWidget(
              times: List.generate(60, (index) => index.toString().padLeft(2, '0')),
              onChanged: (int index) {
                controller.selectMinute(index);
              },
              initialPosition: controller.selectedMinute,
            ),

            const SizedBox(width: Dimensions.paddingSizeDefault),

            // AM/PM selector
            Expanded(
              child: Container(
                height: 70,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.selectPeriod('AM'),
                        child: Container(
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: controller.selectedPeriod == 'AM' ? Theme.of(context).primaryColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                          child: Text(
                            'AM',
                            style: robotoRegular.copyWith(color: controller.selectedPeriod == 'AM' ? Colors.white : null),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.selectPeriod('PM'),
                        child: Container(
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: controller.selectedPeriod == 'PM' ? Theme.of(context).primaryColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                          child: Text(
                            'PM',
                            style: robotoRegular.copyWith(color: controller.selectedPeriod == 'PM' ? Colors.white : null),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ]),
      );
    });
  }

  Widget _buildActionButtons() {
    return GetBuilder<OrderController>(builder: (controller) {
      return Row(children: [
        Expanded(
          child: CustomButtonWidget(
            buttonText: 'cancel'.tr,
            backgroundColor: Theme.of(context).disabledColor.withValues(alpha: 0.3),
            fontColor: Theme.of(context).textTheme.bodyLarge!.color,
            onPressed: () {
              Get.back();
            },
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        Expanded(
          child: CustomButtonWidget(
            isLoading: controller.isLoading,
            buttonText: 'okay'.tr,
            onPressed: () {
              if (controller.selectedDateTime != null) {
                final selectedDateTime = controller.selectedDateTime!;

                if(controller.selectedDate == null) {
                  showCustomSnackBar('please_select_a_date'.tr);
                }else if(selectedDateTime.isBefore(DateTime.now().add(const Duration(minutes: 1)))){
                  showCustomSnackBar('return_date_and_time_must_be_in_future'.tr);
                }else{
                  controller.addParcelReturnDate(orderId: widget.orderId, returnDate: selectedDateTime.toString()).then((value) {
                    if (Get.isBottomSheetOpen!) {
                      Get.back();
                    }
                  });
                }
              }
            },
          ),
        ),
      ]);
    });
  }

  Widget _buildCloseButton() {
    return Positioned(
      top: 0, right: 0,
      child: InkWell(
        onTap: () => Get.back(),
        child: Icon(
          Icons.clear,
          color: Theme.of(context).disabledColor,
          size: 20,
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<OrderController>();
    super.dispose();
  }
}
