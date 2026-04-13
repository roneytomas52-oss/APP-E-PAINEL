import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/drop_down_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/title_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/chart_widget.dart';
import 'package:sixam_mart_delivery/features/ride_module/review/screens/review_screen.dart';
import 'package:sixam_mart_delivery/features/ride_module/trip/controllers/trip_controller.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class TripOverviewWidget extends StatelessWidget {
  final TripController tripController;
  const TripOverviewWidget({super.key, required this.tripController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GetBuilder<TripController>(builder: (tripController) {
        return Stack(children: [
          Column(children: [
            const SizedBox(height: 80),

            const SizedBox(height: 220, child: ChartWidget()),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
              child: TitleWidget(title: 'reports'.tr),
            ),

            ReportsItemCard(title: 'total_trip', qty: tripController.tripOverView?.totalTrips?? 0),

            ReportsItemCard(title: 'total_trip_amount', amount: tripController.tripOverView?.totalEarn?? 0, isTotal: true),

            ReportsItemCard(title: 'total_cancel_trip', qty: tripController.tripOverView?.totalCancel?? 0),

            GestureDetector(
                onTap: ()=> Get.to(const ReviewScreen()),
                child: ReportsItemCard(title: 'total_review', qty: tripController.tripOverView?.totalReviews ?? 0)
            ),
            const SizedBox(height: 100),
          ]),

          Positioned(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Row(children: [
              Text('trips_overview'.tr, style: robotoBold.copyWith(
                color: Theme.of(context).textTheme.bodyMedium!.color, fontSize: Dimensions.fontSizeExtraLarge,
              )),

              const Spacer(),

              Container(
                width: 160,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(width: 1, color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
                ),
                child: DropDownWidget<String>(
                  showText: true,
                  icon: Icon(Icons.arrow_drop_down_outlined),
                  hintText: tripController.selectedOverview.tr,
                  showDivider: false,
                  padding: Dimensions.paddingSizeSmall,
                  items: tripController.selectedOverviewType.map((item) => CustomDropdownMenuItem<String>(
                      value: item,
                      child: Text(item.tr, style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: tripController.selectedOverview == item ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.5),
                      ))
                  )).toList(),
                  onChanged: (value) {
                    tripController.setOverviewType(value!);
                  },
                ),
              )

            ]),
          )),
        ]);
      }),
    );
  }
}


class ReportsItemCard extends StatelessWidget {
  final String? title;
  final double? amount;
  final bool isTotal;
  final int? qty;
  final bool isReview;
  const ReportsItemCard({super.key, this.title, this.amount, this.isTotal = false, this.qty, this.isReview = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 0, Dimensions.paddingSizeDefault,Dimensions.paddingSizeSmall),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: .05),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
          Text(title!.tr,style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color)),

          isTotal ?
          Text(PriceConverterHelper.convertPrice(amount!),style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)) :
          isReview ?
          Text(amount!.toString(),style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)) :
          Text(qty!.toString(),style: robotoMedium.copyWith(color: Theme.of(context).primaryColor))

        ]),
      ),
    );
  }
}
