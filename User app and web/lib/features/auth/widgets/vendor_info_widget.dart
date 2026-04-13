import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

void showVendorInfoSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Container(
      padding: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(),
              Center(child: Container(
                width: 40, height: 4, margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2),),
              )),
              Align(alignment: Alignment.topRight, child: GestureDetector(onTap: (){Navigator.pop(context);}, child: Icon(Icons.close, color: Theme.of(context).disabledColor))),
            ],
          ),

          Text('register_as_a_vendor_lets_you'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
          SizedBox(height: 15),

          _buildStepItem(text: 'sell_products_to_a_wider_customer_base'.tr, context: context),
          _buildStepItem(text: 'manage_orders_and_inventory_easily'.tr, context: context),
          _buildStepItem(text: 'receive_secure_and_timely_payouts'.tr, context: context),
          _buildStepItem(text: 'track_sales_and_performance_in_real_time'.tr, context: context),
        ]),
      ),
    ),
  );
}

Widget _buildStepItem({ required String text, required BuildContext context}) {
  return Padding(
    padding: EdgeInsets.only(bottom: 15),
    child: Row(children: [
      Container(height: 4, width: 4, decoration: BoxDecoration(color: Theme.of(context).disabledColor, shape: BoxShape.circle)),
      SizedBox(width: Dimensions.paddingSizeSmall),
      Expanded(child: Text(text)),
    ]),
  );
}