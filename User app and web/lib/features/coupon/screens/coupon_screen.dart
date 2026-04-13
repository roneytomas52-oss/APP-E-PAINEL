import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:sixam_mart/features/coupon/controllers/coupon_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';
import 'package:sixam_mart/common/widgets/not_logged_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/web_page_title_widget.dart';
import 'package:sixam_mart/features/coupon/widgets/coupon_card_widget.dart';
import 'package:sixam_mart/util/styles.dart';

class CouponScreen extends StatefulWidget {
  const CouponScreen({super.key});

  @override
  State<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {

  ScrollController scrollController = ScrollController();
  List<JustTheController>? _availableToolTipControllerList;
  @override
  void initState() {
    super.initState();

    initCall();
  }

  Future<void> initCall() async {
    if(AuthHelper.isLoggedIn()) {
     await Get.find<CouponController>().getCouponList();

      _availableToolTipControllerList = [];

      if(Get.find<CouponController>().couponList != null && Get.find<CouponController>().couponList!.isNotEmpty) {
        for(int i = 0; i < Get.find<CouponController>().couponList!.length; i++) {
          _availableToolTipControllerList!.add(JustTheController());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(title: 'coupon'.tr),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: isLoggedIn ? GetBuilder<CouponController>(builder: (couponController) {
        return couponController.couponList != null && _availableToolTipControllerList != null ? couponController.couponList!.isNotEmpty && _availableToolTipControllerList!.isNotEmpty ? RefreshIndicator(
          onRefresh: () async {
            await couponController.getCouponList();
          },
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                WebScreenTitleWidget(title: 'coupon'.tr),
                Center(child: FooterView(
                  child: SizedBox(width: Dimensions.webMaxWidth, child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveHelper.isDesktop(context) ? 3 : ResponsiveHelper.isTab(context) ? 2 : 1,
                      mainAxisSpacing: Dimensions.paddingSizeSmall, crossAxisSpacing: Dimensions.paddingSizeSmall,
                      childAspectRatio: ResponsiveHelper.isMobile(context) ? 3 : 3,
                    ),
                    itemCount: couponController.couponList!.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    itemBuilder: (context, index) {
                      return JustTheTooltip(
                        backgroundColor: Get.isDarkMode ? Colors.white : Colors.black87,
                        controller: _availableToolTipControllerList![index],
                        preferredDirection: AxisDirection.up,
                        tailLength: 14,
                        tailBaseWidth: 20,
                        triggerMode: TooltipTriggerMode.manual,
                        content: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${'code_copied'.tr} !',style: robotoRegular.copyWith(color: Theme.of(context).cardColor)),
                        ),
                        child: InkWell(
                          onTap: () {
                            _availableToolTipControllerList![index].showTooltip();
                            Clipboard.setData(ClipboardData(text: couponController.couponList![index].code!));
                            Future.delayed(const Duration(milliseconds: 750), () {
                              _availableToolTipControllerList![index].hideTooltip();
                            });
                            // if(!ResponsiveHelper.isDesktop(context)) {
                            //   showCustomSnackBar('coupon_code_copied'.tr, isError: false);
                            // }
                          },
                          child: CouponCardWidget(coupon: couponController.couponList![index], index: index, toolTipController: _availableToolTipControllerList),
                        ),
                      );
                    },
                  )),
                ))
              ],
            ),
          ),
        ) : NoDataScreen(text: 'no_coupon_found'.tr, showFooter: true) : const Center(child: CircularProgressIndicator());
      }) :  NotLoggedInScreen(callBack: (bool value)  {
        initCall();
        setState(() {});
      }),
    );
  }
}