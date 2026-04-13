import 'package:sixam_mart_delivery/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_ink_well_widget.dart';
import 'package:sixam_mart_delivery/features/notification/controllers/notification_controller.dart';
import 'package:sixam_mart_delivery/helper/date_converter_helper.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_delivery/features/notification/widgets/notification_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatefulWidget {
  final bool fromNotification;
  const NotificationScreen({super.key, this.fromNotification = false});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();

    Get.find<NotificationController>().getNotificationList();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (widget.fromNotification) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        } else {
          Future.delayed(Duration.zero, () {
            Get.back();
          });
        }
      },
      child: Scaffold(
        appBar: CustomAppBarWidget(
          title: 'notification'.tr,
          onBackPressed: () {
            if (widget.fromNotification) {
              Get.offAllNamed(RouteHelper.getInitialRoute());
            } else {
              Get.back();
            }
          },
        ),
        body: GetBuilder<NotificationController>(builder: (notificationController) {
          if (notificationController.notificationList != null) {
            notificationController.saveSeenNotificationCount(notificationController.notificationList!.length);
          }

          List<DateTime> dateTimeList = [];

          return notificationController.notificationList != null ? notificationController.notificationList!.isNotEmpty ? RefreshIndicator(
            onRefresh: () async {
              await notificationController.getNotificationList();
            },
            child: ListView.builder(
              itemCount: notificationController.notificationList!.length,
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              shrinkWrap: true,
              itemBuilder: (context, index) {

                DateTime originalDateTime = DateConverterHelper.dateTimeStringToDate(notificationController.notificationList![index].createdAt!);
                DateTime convertedDate = DateTime(originalDateTime.year, originalDateTime.month, originalDateTime.day);
                bool addTitle = false;

                if (!dateTimeList.contains(convertedDate)) {
                  addTitle = true;
                  dateTimeList.add(convertedDate);
                }

                bool isSeen = notificationController.getSeenNotificationIdList()!.contains(notificationController.notificationList![index].id);

                return Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    addTitle ? Padding(
                      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                      child: Text(
                        DateConverterHelper.convertTodayYesterdayDate(notificationController.notificationList![index].createdAt!),
                        style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7)),
                      ),
                    ) : const SizedBox(),

                    CustomInkWellWidget(
                      onTap: () {
                        notificationController.addSeenNotificationId(notificationController.notificationList![index].id!);

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return NotificationDialogWidget(notificationModel: notificationController.notificationList![index]);
                          },
                        );
                      },
                      radius: Dimensions.radiusDefault,
                      child: Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        decoration: BoxDecoration(
                          color: isSeen ? Theme.of(context).cardColor : Theme.of(context).disabledColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: Row(children: [

                          notificationController.notificationList![index].data?.type == 'push_notification' ? ClipOval(
                            child: CustomImageWidget(
                              image: '${notificationController.notificationList![index].imageFullUrl}',
                              height: 30, width: 30,
                              fit: BoxFit.cover,
                            ),
                          ) : CustomAssetImageWidget(
                            image: (notificationController.notificationList![index].data?.type == 'order_status') ? Images.orderNotification : Images.otherNotification,
                            height: 25, width: 25,
                          ),
                          const SizedBox(width: Dimensions.paddingSizeDefault),

                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                              Row(children: [

                                Expanded(
                                  child: Text(
                                    notificationController.notificationList![index].title ?? '',
                                    style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: isSeen ? FontWeight.w400 : FontWeight.w700),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),

                                Text(
                                  DateConverterHelper.beforeTimeFormat(notificationController.notificationList![index].updatedAt!, isWithUTC: true),
                                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5)),
                                ),

                              ]),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                              Padding(
                                padding: const EdgeInsets.only(right: 40),
                                child: Text(
                                  notificationController.notificationList![index].description ?? '',
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: isSeen ? Theme.of(context).disabledColor : Theme.of(context).hintColor),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              ),

                            ]),
                          ),

                        ]),
                      ),
                    ),

                  ]),
                );
              },
            ),
          ) : Center(child: Text('no_notification_found'.tr)) : const Center(child: CircularProgressIndicator());
        }),
      ),
    );
  }
}
