import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/disbursement/controllers/disbursement_controller.dart';
import 'package:sixam_mart_delivery/features/my_account/widgets/account/my_point_view.dart';
import 'package:sixam_mart_delivery/features/my_account/widgets/account/wallet_overview_widget.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/my_account/controllers/my_account_controller.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {

  late final MyAccountController _accountController;
  late final ProfileController _profileController;

  List<String> types = [
    'wallet_overview',
    'my_point',
  ];
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadInitialData();
  }

  void _initializeControllers() {
    _accountController = Get.find<MyAccountController>();
    _profileController = Get.find<ProfileController>();
  }

  void _loadInitialData() {
    _profileController.getProfile();
    _accountController.getWithdrawRequestList();
    _accountController.getWalletPaymentList();
    _accountController.getWalletProvidedEarningList();
    Get.find<DisbursementController>().getDisbursementMethodList();
    Get.find<DisbursementController>().getWithdrawMethodList();
    _accountController.getLoyaltyPointList(
      offset: 1,
      startDate: Get.find<MyAccountController>().from, endDate: Get.find<MyAccountController>().to,
      fromFilter: false,
      dateRange: Get.find<MyAccountController>().selectedDateType,
      transactionType: Get.find<MyAccountController>().selectedTransactionType ?? 'both',
    );
  }

  Future<void> _refreshData() async {
    if(selectedIndex == 0) {
      await Future.wait([
        _profileController.getProfile(),
        _accountController.getWithdrawRequestList(),
        _accountController.getWalletPaymentList(),
        _accountController.getWalletProvidedEarningList(),
      ]);
    } else {
      await _accountController.getLoyaltyPointList(
        offset: 1,
        startDate: Get.find<MyAccountController>().from, endDate: Get.find<MyAccountController>().to,
        fromFilter: false,
        dateRange: Get.find<MyAccountController>().selectedDateType,
        transactionType: Get.find<MyAccountController>().selectedTransactionType ?? 'both',
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'my_account'.tr),

      body: RefreshIndicator(
        onRefresh: () async {
          return await _refreshData();
        },
        child: Column(children: [
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

          selectedIndex == 0 ? const WalletOverviewWidget() : const MyPointView(),
        ]),
      ),

    );
  }
}