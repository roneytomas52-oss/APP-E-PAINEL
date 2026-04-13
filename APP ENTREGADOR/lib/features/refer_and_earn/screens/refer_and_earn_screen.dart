import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/refer_and_earn/controllers/refer_and_earn_controller.dart';
import 'package:sixam_mart_delivery/features/refer_and_earn/widgets/referral_details.dart';
import 'package:sixam_mart_delivery/features/refer_and_earn/widgets/referral_earning.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class ReferAndEarnScreen extends StatefulWidget {
  const ReferAndEarnScreen({super.key});

  @override
  State<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends State<ReferAndEarnScreen> {
    List<String> types = [
      'referral_details',
      'earning',
    ];
    int selectedIndex = 0;

    @override
  void initState() {
    super.initState();
    Get.find<ReferAndEarnController>().getEarningHistoryList(1);
    Get.find<ReferAndEarnController>().setDateRange('this_year');
    Get.find<ProfileController>().getProfile();
    Get.find<ReferAndEarnController>().setReferralTypeIndex(0);
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: CustomAppBarWidget(title: 'refer_and_earn'.tr),
        body: Column(children: [

          const SizedBox(height: Dimensions.paddingSizeSmall),

          SizedBox(
            height: 50,
            child: ListView.builder(
              itemCount: types.length,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              itemBuilder: (context, index) {
                bool isSelected = selectedIndex == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeExtraSmall),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),
                        color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                      alignment: Alignment.center,
                      child: Text(types[index].tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: isSelected ? Theme.of(context).cardColor : Theme.of(context).textTheme.bodyLarge!.color)),
                    ),
                  ),
                );
            }),
          ),

          const SizedBox(height: Dimensions.paddingSizeSmall),

          selectedIndex == 0 ? const ReferralDetails(status: false) : const ReferralEarningScreen(),
        ]),
      );
    }

}
  