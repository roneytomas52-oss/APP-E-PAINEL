import 'package:flutter/material.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_dropdown_widget.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class CustomDropDown extends StatelessWidget {
  final Function(int, int)? onChange;
  final List<DropdownItem<int>> itemList;
  final String title;
  const CustomDropDown({super.key, this.onChange, required this.itemList, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).hintColor),
      ),
      child: CustomDropdown<int>(
        onChange: onChange,
        dropdownButtonStyle: DropdownButtonStyle(
          height: 45,
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
        items: itemList,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeExtraSmall),
          child: Text(title, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5))),
        ),
      ),
    );
  }
}
