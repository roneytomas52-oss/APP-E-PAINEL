import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class TimePickerWidget extends StatefulWidget {
  final List<String> times;
  final Function(int index) onChanged;
  final int initialPosition;
  const TimePickerWidget({super.key, required this.times, required this.onChanged, required this.initialPosition});

  @override
  State<TimePickerWidget> createState() => _MinMaxTimePickerWidgetState();
}

class _MinMaxTimePickerWidgetState extends State<TimePickerWidget> {
  int selectedIndex = 10;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75, height: 70,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: CarouselSlider.builder(
        options: CarouselOptions(
          autoPlay: false,
          enlargeCenterPage: true,
          disableCenter: true,
          viewportFraction: 0.44,
          initialPage: widget.initialPosition,
          autoPlayInterval: const Duration(seconds: 7),
          onPageChanged: (index, reason) {
            setState(() {
              selectedIndex = index;
            });
            widget.onChanged(index);
          },
          scrollDirection: Axis.vertical,
        ),
        itemCount: widget.times.length,
        itemBuilder: (context, index, _) {
          return Center(child: Text(
            widget.times[index].toString(),
            style: selectedIndex == index ? robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge) : robotoRegular.copyWith(color: Theme.of(context).disabledColor),
          ));
        },
      ),
    );
  }
}
