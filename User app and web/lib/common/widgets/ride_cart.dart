import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/ride_share_module/ride_order/controllers/ride_controller.dart';
import 'package:sixam_mart/util/images.dart';
class RideCart extends StatelessWidget {
  const RideCart({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none, children: [
      Image.asset(Images.taxiCartIcon, height: 20, width: 20, color: Colors.white),

      GetBuilder<RideController>(builder: (rideController) {
        print('=========cart : ${rideController.haveRunningTrip}');
        return rideController.haveRunningTrip ? Positioned(
          top: -5, right: -5,
          child: Container(
            height: 10, width: 10, alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.error,
              border: Border.all(width: 1, color: Theme.of(context).cardColor),
            ),
          ),
        ) : const SizedBox();
      }),
    ]);
  }
}
