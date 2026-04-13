import 'package:flutter/material.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class SearchFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData suffixIcon;
  final Function iconPressed;
  final Function? onSubmit;
  final Function? onChanged;
  const SearchFieldWidget({super.key, required this.controller, required this.hint, required this.suffixIcon,
    required this.iconPressed, this.onSubmit, this.onChanged});

  @override
  State<SearchFieldWidget> createState() => _SearchFieldWidgetState();
}

class _SearchFieldWidgetState extends State<SearchFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
      ),
      child: TextField(
        controller: widget.controller,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusMedium), borderSide: BorderSide.none),
          filled: true, fillColor: Theme.of(context).cardColor,
          isDense: true,
          suffixIcon: IconButton(
            onPressed: widget.iconPressed as void Function()?,
            icon: Icon(widget.suffixIcon, color: Theme.of(context).disabledColor.withValues(alpha: 0.6), size: 22, textDirection: TextDirection.ltr),
          ),
        ),
        onSubmitted: widget.onSubmit as void Function(String)?,
        onChanged: widget.onChanged as void Function(String)?,
      ),
    );
  }
}
