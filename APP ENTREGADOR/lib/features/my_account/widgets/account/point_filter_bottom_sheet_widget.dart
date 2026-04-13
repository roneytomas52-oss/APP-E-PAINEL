import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_drop_down_button.dart';
import 'package:sixam_mart_delivery/features/my_account/controllers/my_account_controller.dart';
import 'package:sixam_mart_delivery/features/refer_and_earn/controllers/refer_and_earn_controller.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:intl/intl.dart';

class PointFilterBottomSheetWidget extends StatefulWidget {
  final Function(String? dateRange, String? startDate, String? endDate)? onApply;
  final VoidCallback? onReset;
  final String? startDate;
  final String? endDate;
  final String? type;

  const PointFilterBottomSheetWidget({
    super.key,
    this.onApply,
    this.onReset, this.startDate, this.endDate, this.type,
  });

  @override
  State<PointFilterBottomSheetWidget> createState() => _PointFilterBottomSheetWidgetState();
}

class _PointFilterBottomSheetWidgetState extends State<PointFilterBottomSheetWidget> {
  String? _selectedDateRange;
  DateTimeRange? _customDateRange;
  
  final List<String> _dateRangeOptions = [
    'custom_date_range', 'this_week', 'this_month', 'this_year',
  ];

  final List<String> _transactionTypeOptions = [
    'both', 'debit', 'credit',
  ];

  @override
  void initState() {
    super.initState();
    if(widget.startDate != null && widget.endDate != null && widget.startDate!.isNotEmpty && widget.endDate!.isNotEmpty) {
      DateTime start = DateTime.parse(widget.startDate!);
      DateTime end = DateTime.parse(widget.endDate!);
      _customDateRange = DateTimeRange(start: start, end: end);
    }

    if(widget.type == 'custom') {
      _selectedDateRange = 'custom_date_range';
    } else {
      _selectedDateRange = widget.type ?? Get.find<ReferAndEarnController>().dateRange ?? 'custom_date_range';
    }
  }

  Future<void> _selectCustomDateRange() async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      currentDate: DateTime.now(),
      saveText: 'done'.tr,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      setState(() {
        _customDateRange = result;
      });
    }
  }

  String _formatDateRange(DateTimeRange range) {
    final DateFormat formatter = DateFormat('dd MMM yyyy');
    return '${formatter.format(range.start)} - ${formatter.format(range.end)}';
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyAccountController>(builder: (myAccountController) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radiusExtraLarge),
            topRight: Radius.circular(Dimensions.radiusExtraLarge),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top handle
            Container(
              margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.close, color: Theme.of(context).disabledColor),
                onPressed: () => Get.back(),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
              child: Text(
                'filter_by'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  CustomDropdownButton(
                    hintText: 'transaction_type'.tr,
                    dropdownMenuItems: _transactionTypeOptions.map((type) => DropdownMenuItem<String>(
                      value: type,
                      child: Text(
                        type.tr,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                      ),
                    )).toList(),
                    isBorder: true,
                    backgroundColor: Theme.of(context).cardColor,
                    onChanged: (value) {
                      myAccountController.setSelectedTransactionType(value!);
                    },
                    selectedValue: myAccountController.selectedTransactionType,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // Date Range Dropdown
                  CustomDropdownButton(
                    hintText: 'custom_date_range'.tr,
                    dropdownMenuItems: _dateRangeOptions.map((range) => DropdownMenuItem<String>(
                      value: range,
                      child: Text(
                        range.tr,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                      ),
                    )).toList(),
                    isBorder: true,
                    backgroundColor: Theme.of(context).cardColor,
                    maxHeight: 100,
                    onChanged: (value) {
                      setState(() {
                        _selectedDateRange = value;
                        if (value != 'custom_date_range') {
                          _customDateRange = null;
                        }
                      });
                    },
                    selectedValue: _selectedDateRange,
                  ),

                  // Custom Date Range Picker
                  if (_selectedDateRange == 'custom_date_range') ...[
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // Label
                    Text(
                      'custom_date_range'.tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    // Date Range Input
                    InkWell(
                      onTap: _selectCustomDateRange,
                      child: Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          border: Border.all(
                            color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _customDateRange != null
                                ? _formatDateRange(_customDateRange!)
                                : 'select_date_range'.tr,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: _customDateRange != null
                                  ? Theme.of(context).textTheme.bodyLarge!.color
                                  : Theme.of(context).disabledColor,
                              ),
                            ),
                            Icon(
                              Icons.calendar_month_rounded,
                              color: Theme.of(context).disabledColor,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: Dimensions.paddingSizeLarge),
                ],
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Reset Button
                    Expanded(
                      child: CustomButtonWidget(
                        buttonText: 'reset'.tr,
                        transparent: true,
                        isBorder: true,
                        fontColor: Theme.of(context).textTheme.bodyLarge!.color,
                        backgroundColor: Colors.transparent,
                        onPressed: () {
                          setState(() {
                            _selectedDateRange = 'custom_date_range';
                            _customDateRange = null;
                          });
                          widget.onReset?.call();
                        },
                      ),
                    ),

                    const SizedBox(width: Dimensions.paddingSizeDefault),

                    // Filter Button
                    Expanded(
                      child: CustomButtonWidget(
                        buttonText: 'filter'.tr,
                        onPressed: () {
                          if(_selectedDateRange == 'custom_date_range') {
                            _selectedDateRange = 'custom';
                          }
                          widget.onApply?.call(_selectedDateRange, _customDateRange?.start.toString(), _customDateRange?.end.toString());
                          Get.back(result: {
                            'dateRange': _selectedDateRange,
                            'customRange': _customDateRange,
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
