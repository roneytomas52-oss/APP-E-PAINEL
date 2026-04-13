import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class TabSectionWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChanged;

  const TabSectionWidget({super.key, required this.selectedIndex, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge, bottom: Dimensions.paddingSizeSmall),
      child: Row(children: [
        _buildTab(
          context: context,
          title: 'withdraw_history'.tr,
          index: 0,
        ),

        _buildTab(
          context: context,
          title: 'payment_history'.tr,
          index: 1,
        ),

        _buildTab(
          context: context,
          title: 'wallet_earning'.tr,
          index: 2,
        ),
      ]),
    );
  }

  Widget _buildTab({required BuildContext context, required String title, required int index}) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => onTabChanged(index),
        hoverColor: Colors.transparent,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text(
            title,
            style: robotoMedium.copyWith(
              color: isSelected ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).disabledColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 3),

          Container(
            height: 3,
            margin: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              color: isSelected ? Theme.of(context).primaryColor : null,
            ),
          ),
        ]),
      ),
    );
  }
}