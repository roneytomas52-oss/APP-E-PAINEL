import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_loader.dart';
import 'package:sixam_mart_delivery/features/disbursement/controllers/disbursement_controller.dart';
import 'package:sixam_mart_delivery/features/disbursement/domain/models/disbursement_method_model.dart';
import 'package:sixam_mart_delivery/features/disbursement/helper/disbursement_helper.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/helper/string_extension.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/features/my_account/widgets/confirm_dialog_widget.dart';

class WithdrawMethodScreen extends StatefulWidget {
  final bool isFromDashboard;
  const WithdrawMethodScreen({super.key, required this.isFromDashboard});

  @override
  State<WithdrawMethodScreen> createState() => _WithdrawMethodScreenState();
}

class _WithdrawMethodScreenState extends State<WithdrawMethodScreen> {

  DisbursementHelper disbursementHelper = DisbursementHelper();

  @override
  void initState() {
    super.initState();
    initCall();
  }

  Future<void> initCall() async {

    Get.find<DisbursementController>().getDisbursementMethodList();
    Get.find<DisbursementController>().getWithdrawMethodList();
    disbursementHelper.enableDisbursementWarningMessage(false, canShowDialog: !widget.isFromDashboard);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DisbursementController>(builder: (disbursementController) {
      return Scaffold(
        appBar: CustomAppBarWidget(title: 'withdraw_method'.tr),

        floatingActionButton: disbursementController.disbursementMethodBody != null && disbursementController.disbursementMethodBody!.methods!.isNotEmpty? FloatingActionButton(
          onPressed: () => Get.toNamed(RouteHelper.getAddWithdrawMethodRoute()),
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        ) : const SizedBox(),

        body: disbursementController.disbursementMethodBody != null ? disbursementController.disbursementMethodBody!.methods!.isNotEmpty ? RefreshIndicator(
          onRefresh: () async {
            await Get.find<DisbursementController>().getDisbursementMethodList();
            await Get.find<DisbursementController>().getWithdrawMethodList();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Text('withdraw_method_list'.tr, style: robotoBold),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: disbursementController.disbursementMethodBody!.methods!.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeDefault, top: 2),
                  itemBuilder: (context, index) {
                    Methods method = disbursementController.disbursementMethodBody!.methods![index];
                    return CustomCard(
                      width: context.width,
                      isBorder: false,
                      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                      child: Column(children: [

                        Padding(
                          padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                          child: Row(children: [

                            Expanded(
                              child: Row(children: [
                                Text(
                                  '${method.methodName}', maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoBold,
                                ),

                                if (method.isDefault == true) ...[
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    ),
                                    padding: const EdgeInsets.all(2),
                                    child: Text(
                                      'default'.tr,
                                      style: robotoMedium.copyWith(color: Colors.blue, fontSize: Dimensions.fontSizeSmall),
                                    ),
                                  ),
                                ],
                              ]),
                            ),

                            PopupMenuButton(
                              position: PopupMenuPosition.under,
                              offset: const Offset(0, 8),
                              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
                              splashRadius: Dimensions.radiusLarge,
                              menuPadding: const EdgeInsets.all(0),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'status',
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: Text('mark_as_default'.tr, style: robotoRegular),
                                        trailing: SizedBox(
                                          width: 24, height: 24,
                                          child: Checkbox(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall - 1)),
                                            side: BorderSide(color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),
                                            value: method.isDefault,
                                            activeColor: Theme.of(context).primaryColor,
                                            onChanged: (value) {
                                              disbursementController.makeDefaultMethod({'id': '${method.id}', 'is_default': '1'}, index);
                                            }
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      const Divider(height: 1),
                                    ],
                                  ),
                                ),

                                PopupMenuItem(
                                  value: 'edit',
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: Row(
                                          children: [
                                            Icon(Icons.edit_document, size: 18, color: Colors.blue),
                                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                            Text('edit'.tr, style: robotoRegular),
                                          ],
                                        ),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      const Divider(height: 1),
                                    ],
                                  ),
                                ),

                                PopupMenuItem(
                                  value: 'delete',
                                  child: ListTile(
                                    title: Row(
                                      children: [
                                        Icon(CupertinoIcons.delete, size: 16, color: Colors.red),
                                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                        Text('delete'.tr, style: robotoRegular),
                                      ],
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                              onSelected: (value) async {
                                if(value == 'edit') {
                                  Get.toNamed(RouteHelper.getEditWithdrawMethodRoute(method: method));
                                }else if(value == 'delete') {
                                  Get.dialog(ConfirmDialogWidget(id: method.id!), barrierDismissible: false);
                                }else {
                                  Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);
                                  await disbursementController.makeDefaultMethod({'id': '${method.id}', 'is_default': '1'}, index);
                                }
                              },
                            ),
                          ]),
                        ),

                        Container(
                          padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                          margin: EdgeInsets.only(left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            color: Theme.of(context).disabledColor.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
                          ),
                          child: ListView.builder(
                            itemCount: method.methodFields!.length,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: index != method.methodFields!.length-1 ? Dimensions.paddingSizeDefault : 0),
                                child: Row(children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      method.methodFields![index].userInput!.replaceAll('_', ' ').toTitleCase(), style: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(' :  ', style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),

                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      method.methodFields?[index].userData ?? 'N/A',
                                      style: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ]),
                              );
                            },
                          ),
                        ),

                      ]),

                    );
                  },
                ),
              ),
            ],
          ),
        ) : const EmptyWithdrawScreen() : const Center(child: CircularProgressIndicator()),
      );
    });
  }
}

class EmptyWithdrawScreen extends StatelessWidget {
  const EmptyWithdrawScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge * 1.5),
        child: Column(mainAxisSize: MainAxisSize.min ,children: [

          Image.asset(Images.withdraw, height: 70, width: 70),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

          Text('withdraw_method'.tr, style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeExtraLarge
          ), textAlign: TextAlign.center),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          Text('add_withdraw_hint'.tr, style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault, height: 1.6, color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5)
          ), textAlign: TextAlign.center),

          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

          CustomButtonWidget(
            width: 200,
            buttonText: "add_withdraw_info".tr,
            onPressed: () => Get.toNamed(RouteHelper.getAddWithdrawMethodRoute()),
          ),

          SizedBox(height : Get.height * 0.2)

        ]),
      ),
    );
  }
}