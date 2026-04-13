import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class ConfirmationTripDialog extends StatelessWidget {
  final bool isStartedTrip;

  const ConfirmationTripDialog({super.key, required this.isStartedTrip});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha:0.5),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [
        isStartedTrip
            ? Text(
          'on_the_way_to_your_destination'.tr,
          textAlign: TextAlign.center,
          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Theme.of(context).cardColor),
        )
            : Text('calculating_fare'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Theme.of(context).cardColor)),
        const SizedBox(height: Dimensions.paddingSizeDefault),

         const CircularProgressIndicator(),

         // const LoadingOverlayPro(isLoading: true,backgroundColor: Colors.transparent, child: SizedBox(),)

      ])),
    );
  }
}
