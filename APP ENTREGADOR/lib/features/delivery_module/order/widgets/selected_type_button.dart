import 'package:flutter/material.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/screens/order_status.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import '../controllers/order_controller.dart';

class SelectedTypeButton extends StatelessWidget {
  final String title;
  final int count;
  final OrderController orderController;
  final bool fromHistory;

  const SelectedTypeButton({
    super.key,
    required this.title,
    required this.count,
    required this.orderController,
    this.fromHistory = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isSelected =  fromHistory
        ? orderController.selectedHistoryStatus == title
        : orderController.selectedRunningStatus == title;

    return InkWell(
      onTap: () {
        if (fromHistory) {
          orderController.setHistoryOrderStatus(title);
        } else {
          orderController.setRunningOrderStatus(title);
        }
      },
      child: Container(
        margin: EdgeInsets.only(right: Dimensions.paddingSizeSmall),
        padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(width: isSelected ? 2 : 0, color: isSelected ? Theme.of(context).primaryColor :  Colors.transparent))),
        child: Row(
          children: [
            Text(getOrderStatus(title), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color:  isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor)),
            SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Text('( $count)', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color:  isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor)),
          ],
        ),
      ),
    );
  }
}