import 'dart:async';
import 'package:dotted_border/dotted_border.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/widgets/bottom_view/parcel_bottom_view.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/widgets/bottom_view/regular_order_bottom_view.dart';
import 'package:sixam_mart_delivery/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_delivery/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart_delivery/features/chat/domain/models/conversation_model.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/order_details_model.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/order_model.dart';
import 'package:sixam_mart_delivery/helper/date_converter_helper.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/helper/responsive_helper.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/helper/string_extension.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/widgets/order_item_widget.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/widgets/info_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/custom_order_details_card.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int? orderId;
  final bool? isRunningOrder;
  final int? orderIndex;
  final bool fromNotification;
  final bool fromLocationScreen;
  const OrderDetailsScreen({super.key, required this.orderId, required this.isRunningOrder, required this.orderIndex,
    this.fromNotification = false, this.fromLocationScreen = false});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> with WidgetsBindingObserver {
  Timer? _timer;

  void _startApiCalling(){
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      Get.find<OrderController>().getOrderWithId(widget.orderId!);
    });
  }

  Future<void> _loadData() async {
    Get.find<OrderController>().pickPrescriptionImage(isRemove: true, isCamera: false);
    await Get.find<OrderController>().getOrderWithId(widget.orderId);
    Get.find<OrderController>().getOrderDetails(widget.orderId, Get.find<OrderController>().orderModel!.orderType == 'parcel');
    await Get.find<OrderController>().getLatestOrders();
    if(Get.find<OrderController>().showDeliveryImageField){
      Get.find<OrderController>().changeDeliveryImageStatus(isUpdate: false);
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _loadData();
    _startApiCalling();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if(state == AppLifecycleState.paused) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async{
        if((widget.fromNotification || widget.fromLocationScreen)) {
          Future.delayed(const Duration(milliseconds: 0), () async {
            await Get.offAllNamed(RouteHelper.getInitialRoute());
          });
        } else {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: CustomAppBarWidget(title: 'order_details'.tr, onBackPressed: (){
        if(widget.fromNotification || widget.fromLocationScreen) {
            Get.offAllNamed(RouteHelper.getInitialRoute());
          } else {
            Get.back();
          }
        }),
        body: SafeArea(
          child: GetBuilder<OrderController>(builder: (orderController) {

            OrderModel? controllerOrderModel = orderController.orderModel;

            bool restConfModel = Get.find<SplashController>().configModel!.orderConfirmationModel != 'deliveryman';

            bool? parcel, pickedUp, cod, wallet, partialPay, offlinePay, digitalyPaid;

            bool showDeliveryConfirmImage = false;

            double? deliveryCharge = 0;
            double itemsPrice = 0;
            double? discount = 0;
            double? couponDiscount = 0;
            double? tax = 0;
            double addOns = 0;
            double? dmTips = 0;
            double additionalCharge = 0;
            double extraPackagingAmount = 0;
            double referrerBonusAmount = 0;
            bool? isPrescriptionOrder = false;
            bool? taxIncluded = false;
            bool showChatPermission = true;
            OrderModel? order = controllerOrderModel;
            if(order != null && orderController.orderDetailsModel != null) {
              deliveryCharge = order.deliveryCharge;
              dmTips = order.dmTips;
              isPrescriptionOrder = order.prescriptionOrder;
              discount = order.storeDiscountAmount! + order.flashAdminDiscountAmount! + order.flashStoreDiscountAmount!;
              tax = order.totalTaxAmount;
              taxIncluded = order.taxStatus;
              additionalCharge = order.additionalCharge!;
              extraPackagingAmount = order.extraPackagingAmount!;
              referrerBonusAmount = order.referrerBonusAmount!;
              couponDiscount = order.couponDiscountAmount;
              if(isPrescriptionOrder!){
                double orderAmount = order.orderAmount ?? 0;
                itemsPrice = (orderAmount + discount) - ((taxIncluded! ? 0 : tax!) + deliveryCharge! + additionalCharge) - dmTips!;
              }else {
                for (OrderDetailsModel orderDetails in orderController.orderDetailsModel!) {
                  for (AddOn addOn in orderDetails.addOns!) {
                    addOns = addOns + (addOn.price! * addOn.quantity!);
                  }
                  itemsPrice = itemsPrice + (orderDetails.price! * orderDetails.quantity!);
                }
              }

              if (order.storeBusinessModel == 'commission') {
                showChatPermission = true;
              } else if (order.storeBusinessModel == 'subscription') {
                showChatPermission = order.storeChatPermission == 1;
              } else {
                showChatPermission = true;
              }
            }
            double subTotal = itemsPrice + addOns;
            double total = itemsPrice + addOns - discount+ (taxIncluded! ? 0 : tax!) + deliveryCharge! - couponDiscount! + dmTips! + additionalCharge + extraPackagingAmount - referrerBonusAmount;

            if(controllerOrderModel != null){
              parcel = controllerOrderModel.orderType == 'parcel';
              pickedUp = controllerOrderModel.orderStatus == AppConstants.pickedUp;
              cod = controllerOrderModel.paymentMethod == 'cash_on_delivery';
              wallet = controllerOrderModel.paymentMethod == 'wallet';
              digitalyPaid = controllerOrderModel.paymentMethod == 'ssl_commerz';
              partialPay = controllerOrderModel.paymentMethod == 'partial_payment';
              offlinePay = controllerOrderModel.paymentMethod == 'offline_payment';

              showDeliveryConfirmImage = pickedUp && Get.find<SplashController>().configModel!.dmPictureUploadStatus! && controllerOrderModel.orderStatus != 'delivered';
            }

            return (orderController.orderDetailsModel != null && controllerOrderModel != null) ? Column(children: [

              Expanded(child: SingleChildScrollView(
                padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                physics: const ClampingScrollPhysics(),
                child: Column(children: [

                  Row(children: [
                    Text('${parcel! ? 'delivery_id'.tr : 'order_id'.tr}:', style: robotoRegular),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Text(controllerOrderModel.id.toString(), style: robotoBold),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    const Expanded(child: SizedBox()),
                    Container(height: 7, width: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: controllerOrderModel.orderStatus?.toLowerCase() == "canceled" ? Colors.red : Colors.green,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Text(controllerOrderModel.orderStatus!.tr, style: robotoBold),
                  ]),

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  parcel && order?.orderStatus == AppConstants.canceled && !(order?.parcelCancellation?.beforePickup == 1) ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('return_date_and_time'.tr, style: robotoRegular),

                    Text(order?.parcelCancellation?.returnDate != null ? DateConverterHelper.dateTimeStringToDateTime(order!.parcelCancellation!.returnDate!) : 'not_set_yet'.tr, style: robotoRegular),
                  ]) : const SizedBox(),

                  controllerOrderModel.scheduleAt != null &&  controllerOrderModel.scheduleAt!.isNotEmpty ? Column(children: [
                    Row(children: [
                      Text('${(controllerOrderModel.scheduled ?? false) ? 'schedule'.tr : "order_date".tr} ', style: robotoRegular),
                      const Expanded(child: SizedBox()),

                      Text(
                        DateConverterHelper.dateTimeStringToDateTime(controllerOrderModel.scheduleAt!),
                        style: robotoRegular,
                      ),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                  ]) : const SizedBox(),

                  SizedBox(height: parcel && order?.orderStatus == AppConstants.canceled && !(order?.parcelCancellation?.beforePickup == 1) ? Dimensions.paddingSizeLarge : 0),

                  Row(children: [

                    if(!(controllerOrderModel.prescriptionOrder ?? false)) ... [
                      Text('${digitalyPaid == true && controllerOrderModel.chargePayer != null ? 'paid_by'.tr : parcel ? 'charge_payer'.tr : 'item'.tr}:', style: robotoRegular),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text(
                        digitalyPaid == true && controllerOrderModel.chargePayer != null ? controllerOrderModel.chargePayer! : parcel ? controllerOrderModel.chargePayer!.tr : orderController.orderDetailsModel!.length.toString(),
                        style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                      ),
                    ],
                    const Expanded(child: SizedBox()),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                      decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        cod! ? 'cod'.tr : wallet! ? 'wallet'.tr : partialPay! ? 'partially_pay'.tr : offlinePay! ? 'offline_payment'.tr : 'digitally_paid'.tr,
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                      )
                    )
                  ]),

                  orderController.orderDetailsModel!.isNotEmpty && orderController.orderDetailsModel![0].itemDetails != null && orderController.orderDetailsModel![0].itemDetails!.moduleType == 'food' ? Column(children: [
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    Row(children: [
                      Text('${'cutlery'.tr} ', style: robotoRegular),
                      const Expanded(child: SizedBox()),

                      Text(
                        controllerOrderModel.cutlery! ? 'yes'.tr : 'no'.tr,
                        style: robotoRegular,
                      ),
                    ]),
                  ]) : const SizedBox(),

                  SizedBox(height: Dimensions.paddingSizeSmall),
                  Divider(thickness: 1, color: Theme.of(context).disabledColor.withValues(alpha: 0.05)),
                  SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  controllerOrderModel.unavailableItemNote != null ?
                    CustomOrderDetailsCard(
                      title: '${'unavailable_item_note'.tr}: ' ,
                      metaValue: controllerOrderModel.unavailableItemNote!,
                    ) : const SizedBox(),
                  SizedBox(height: controllerOrderModel.unavailableItemNote != null ? Dimensions.paddingSizeSmall : 0),

                  controllerOrderModel.deliveryInstruction != null ?
                  CustomOrderDetailsCard(
                    title: '${'delivery_instruction'.tr}: ' ,
                    metaValue: controllerOrderModel.deliveryInstruction!.tr,
                  ) : const SizedBox(),

                  SizedBox(height: controllerOrderModel.deliveryInstruction != null ? Dimensions.paddingSizeSmall : 0),

                  controllerOrderModel.bringChangeAmount != null && controllerOrderModel.bringChangeAmount! > 0 ?
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: const Color(0XFF009AF1).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    child: RichText(
                      text: TextSpan(children: [
                        TextSpan(text: 'please_bring'.tr, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                        TextSpan(text: ' ${PriceConverterHelper.convertPrice(controllerOrderModel.bringChangeAmount)}', style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                        TextSpan(text: ' ${'in_change_for_the_customer_when_making_the_delivery'.tr}', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                      ]),
                    ),
                  ) : const SizedBox(),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  InfoCardWidget(
                    title: parcel ? 'sender_details'.tr : 'store_details'.tr,
                    address: parcel ? controllerOrderModel.deliveryAddress : DeliveryAddress(address: controllerOrderModel.storeAddress),
                    image: parcel ? '' : '${controllerOrderModel.storeLogoFullUrl}',
                    name: parcel ? controllerOrderModel.deliveryAddress!.contactPersonName : controllerOrderModel.storeName,
                    phone: parcel ? controllerOrderModel.deliveryAddress!.contactPersonNumber : controllerOrderModel.storePhone,
                    latitude: parcel ? controllerOrderModel.deliveryAddress!.latitude : controllerOrderModel.storeLat,
                    longitude: parcel ? controllerOrderModel.deliveryAddress!.longitude : controllerOrderModel.storeLng,
                    showButton: (controllerOrderModel.orderStatus != 'delivered' && controllerOrderModel.orderStatus != 'failed'
                        && controllerOrderModel.orderStatus != 'canceled' && controllerOrderModel.orderStatus != 'refunded'),
                    isStore: parcel ? false : true, isChatAllow: showChatPermission,
                    messageOnTap: () => Get.toNamed(RouteHelper.getChatRoute(
                      notificationBody: NotificationBodyModel(
                        orderId: controllerOrderModel.id, vendorId: orderController.orderDetailsModel![0].vendorId,
                      ),
                      user: User(
                        id: controllerOrderModel.storeId, fName: controllerOrderModel.storeName,
                        imageFullUrl: controllerOrderModel.storeLogoFullUrl, phone: controllerOrderModel.storePhone
                      ),
                    )),
                    order: order!,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  InfoCardWidget(
                    title: parcel ? 'receiver_details'.tr : 'customer_contact_details'.tr,
                    address: parcel ? controllerOrderModel.receiverDetails : controllerOrderModel.deliveryAddress,
                    image: parcel ? '' : controllerOrderModel.customer != null ? '${controllerOrderModel.customer!.imageFullUrl}' : '',
                    name: parcel ? controllerOrderModel.receiverDetails!.contactPersonName : controllerOrderModel.deliveryAddress!.contactPersonName,
                    phone: parcel ? controllerOrderModel.receiverDetails!.contactPersonNumber : controllerOrderModel.deliveryAddress!.contactPersonNumber,
                    latitude: parcel ? controllerOrderModel.receiverDetails!.latitude : controllerOrderModel.deliveryAddress!.latitude,
                    longitude: parcel ? controllerOrderModel.receiverDetails!.longitude : controllerOrderModel.deliveryAddress!.longitude,
                    showButton: controllerOrderModel.orderStatus != 'delivered' && controllerOrderModel.orderStatus != 'failed'
                        && controllerOrderModel.orderStatus != 'canceled' && controllerOrderModel.orderStatus != 'refunded',
                    isStore: parcel ? false : true, isChatAllow: showChatPermission,
                    messageOnTap: () => Get.toNamed(RouteHelper.getChatRoute(
                      notificationBody: NotificationBodyModel(
                        orderId: controllerOrderModel.id, customerId: controllerOrderModel.customer!.id,
                      ),
                      user: User(
                        id: controllerOrderModel.customer!.id, fName: controllerOrderModel.customer!.fName,
                        lName: controllerOrderModel.customer!.lName, imageFullUrl: controllerOrderModel.customer!.imageFullUrl,
                          phone: controllerOrderModel.customer?.phone,
                      ),
                    )),
                    order: order,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  parcel ? Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      boxShadow: Get.isDarkMode ? null : [BoxShadow(color: Colors.grey[200]!, spreadRadius: 1, blurRadius: 5)],
                    ),
                    child: controllerOrderModel.parcelCategory != null ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('parcel_category'.tr, style: robotoBold),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Row(children: [
                        ClipRRect(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), child: CustomImageWidget(
                          image: '${controllerOrderModel.parcelCategory!.imageFullUrl}',
                          height: 35, width: 35, fit: BoxFit.cover,
                        )),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(
                            controllerOrderModel.parcelCategory!.name!, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                          ),
                          Text(
                            controllerOrderModel.parcelCategory!.description!, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                          ),
                        ])),
                      ]),
                    ]) : SizedBox(
                      width: context.width,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('parcel_category'.tr, style: robotoRegular),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        Text('no_parcel_category_data_found'.tr, style: robotoMedium),
                      ]),
                    ),
                  ) : Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      boxShadow: Get.isDarkMode ? null : [BoxShadow(color: Colors.grey[200]!, spreadRadius: 1, blurRadius: 5)],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Column(
                      spacing: 10, crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('item_info'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: orderController.orderDetailsModel!.length,
                          itemBuilder: (context, index) {
                            return OrderItemWidget(order: controllerOrderModel, orderDetails: orderController.orderDetailsModel![index]);
                          },
                          separatorBuilder: (context, index){
                            return Divider(height: 25,);
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: parcel && order.parcelCancellation != null ? Dimensions.paddingSizeLarge : 0),

                  parcel && order.parcelCancellation != null ? Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      boxShadow: Get.isDarkMode ? null : [BoxShadow(color: Colors.grey[200]!, spreadRadius: 1, blurRadius: 5)],
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      order.parcelCancellation!.returnFee != null && order.parcelCancellation!.returnFee! > 0 ? Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(order.orderStatus == AppConstants.returned ? 'collected_return_fee_from_customer'.tr : 'collect_return_fee_from_customer'.tr, style: robotoRegular),

                          Text(PriceConverterHelper.convertPrice(order.parcelCancellation!.returnFee), style: robotoBold),
                        ]),
                      ) : const SizedBox(),
                      SizedBox(height: order.parcelCancellation!.returnFee != null && order.parcelCancellation!.returnFee! > 0 ? Dimensions.paddingSizeSmall : 0),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('canceled_by'.tr, style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error)),

                          Text(order.parcelCancellation?.cancelBy?.toTitleCase() ?? '', style: robotoRegular),
                        ]),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      order.parcelCancellation?.reason != null && order.parcelCancellation!.reason!.isNotEmpty ? Text('cancellation_reason'.tr, style: robotoSemiBold) : const SizedBox(),
                      SizedBox(height: order.parcelCancellation?.reason != null && order.parcelCancellation!.reason!.isNotEmpty ? Dimensions.paddingSizeSmall : 0),

                      order.parcelCancellation?.reason != null && order.parcelCancellation!.reason!.isNotEmpty ? Container(
                          padding: const EdgeInsets.all(12),
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(order.parcelCancellation!.reason!.length, (index) {
                              return Row(children: [
                                Container(
                                  height: 5, width: 5,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),

                                Expanded(child: Text(order.parcelCancellation!.reason?[index] ?? '', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7)))),
                              ]);
                            },
                            ),
                          )) : const SizedBox(),
                      SizedBox(height: order.parcelCancellation?.reason != null && order.parcelCancellation!.reason!.isNotEmpty ? Dimensions.paddingSizeSmall : 0),

                      order.parcelCancellation?.note != null ? Text('comments'.tr, style: robotoSemiBold) : const SizedBox(),
                      SizedBox(height: order.parcelCancellation?.note != null ? Dimensions.paddingSizeSmall : 0),

                      order.parcelCancellation?.note != null ? Container(
                        padding: const EdgeInsets.all(12),
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: Text(order.parcelCancellation?.note ?? '', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7))),
                      ) : const SizedBox(),
                    ]),
                  ) : const SizedBox(),

                  (controllerOrderModel.orderNote != null && controllerOrderModel.orderNote!.isNotEmpty) ? Container(
                    margin: !parcel ? EdgeInsets.only(top: Dimensions.paddingSizeLarge) : null,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      boxShadow: Get.isDarkMode ? null : [BoxShadow(color: Colors.grey[200]!, spreadRadius: 1, blurRadius: 5)],
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('additional_note'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Container(
                        width: 1170,
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(width: 1, color: Theme.of(context).disabledColor),
                        ),
                        child: Text(
                          controllerOrderModel.orderNote!,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                        ),
                      ),
                    ]),
                  ) : const SizedBox(),
                  // SizedBox(height: (controllerOrderModel.orderNote != null && controllerOrderModel.orderNote!.isNotEmpty) ? Dimensions.paddingSizeLarge : 0),

                  (Get.find<SplashController>().getModule(controllerOrderModel.moduleType).orderAttachment!
                      && controllerOrderModel.orderAttachmentFullUrl != null && controllerOrderModel.orderAttachmentFullUrl!.isNotEmpty)
                      ? Container(
                        margin: EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          boxShadow: Get.isDarkMode ? null : [BoxShadow(color: Colors.grey[200]!, spreadRadius: 1, blurRadius: 5)],
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('prescription'.tr, style: robotoRegular),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio: 1.5,
                              crossAxisCount: ResponsiveHelper.isTab(context) ? 5 : 3,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 5,
                            ),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controllerOrderModel.orderAttachmentFullUrl!.length,
                            itemBuilder: (BuildContext context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: InkWell(
                                  onTap: () => openDialog(context, controllerOrderModel.orderAttachmentFullUrl![index]),
                                  child: Center(child: ClipRRect(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    child: CustomImageWidget(
                                      image: controllerOrderModel.orderAttachmentFullUrl![index],
                                      width: 100, height: 100,
                                    ),
                                  )),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                        ]),
                      ) : const SizedBox(),

                  (controllerOrderModel.orderStatus == 'delivered' && controllerOrderModel.orderProofFullUrl != null
                  && controllerOrderModel.orderProofFullUrl!.isNotEmpty) ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Text('order_proof'.tr, style: robotoRegular),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 1.5,
                        crossAxisCount: ResponsiveHelper.isTab(context) ? 5 : 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 5,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controllerOrderModel.orderProofFullUrl!.length,
                      itemBuilder: (BuildContext context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () => openDialog(context, controllerOrderModel.orderProofFullUrl![index]),
                            child: Center(child: ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child: CustomImageWidget(
                                image: controllerOrderModel.orderProofFullUrl![index],
                                width: 100, height: 100,
                              ),
                            )),
                          ),
                        );
                      },
                    ),
                  ]) : const SizedBox(),


                  Container(
                    margin: EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      boxShadow: Get.isDarkMode ? null : [BoxShadow(color: Colors.grey[200]!, spreadRadius: 1, blurRadius: 5)],
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('billing_summary'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                      SizedBox(height: Dimensions.paddingSizeSmall),

                      !parcel ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('item_price'.tr, style: robotoRegular),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(PriceConverterHelper.convertPrice(itemsPrice), style: robotoRegular),
                        ]),
                      ]) : const SizedBox(),
                      SizedBox(height: !parcel ? 10 : 0),

                      Get.find<SplashController>().getModuleConfig(order.moduleType).addOn! ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('addons'.tr, style: robotoRegular),
                          Text('(+) ${PriceConverterHelper.convertPrice(addOns)}', style: robotoRegular),
                        ],
                      ) : const SizedBox(),

                      Get.find<SplashController>().getModuleConfig(order.moduleType).addOn! ? Divider(
                        thickness: 1, color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                      ) : const SizedBox(),

                      Get.find<SplashController>().getModuleConfig(order.moduleType).addOn! ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('subtotal'.tr, style: robotoMedium),
                          Text(PriceConverterHelper.convertPrice(subTotal), style: robotoMedium),
                        ],
                      ) : const SizedBox(),
                      SizedBox(height: Get.find<SplashController>().getModuleConfig(order.moduleType).addOn! ? 10 : 0),

                      !parcel ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('discount'.tr, style: robotoRegular),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Text('(-) ${PriceConverterHelper.convertPrice(discount)}', style: robotoRegular),
                        ]),
                      ]) : const SizedBox(),
                      SizedBox(height: !parcel ? 10 : 0),

                      couponDiscount > 0 ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('coupon_discount'.tr, style: robotoRegular),
                        Text(
                          '(-) ${PriceConverterHelper.convertPrice(couponDiscount)}',
                          style: robotoRegular,
                        ),
                      ]) : const SizedBox(),
                      SizedBox(height: couponDiscount > 0 ? 10 : 0),

                      (referrerBonusAmount > 0) ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('referral_discount'.tr, style: robotoRegular),
                          Text('(-) ${PriceConverterHelper.convertPrice(referrerBonusAmount)}', style: robotoRegular),
                        ],
                      ) : const SizedBox(),
                      SizedBox(height: referrerBonusAmount > 0 ? 10 : 0),

                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('delivery_fee'.tr, style: robotoRegular),
                        Text('(+) ${PriceConverterHelper.convertPrice(deliveryCharge)}', style: robotoRegular),
                      ]),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('delivery_man_tips'.tr, style: robotoRegular),
                          Text('(+) ${PriceConverterHelper.convertPrice(dmTips)}', style: robotoRegular),
                        ],
                      ),
                      const SizedBox(height: 10),

                      (extraPackagingAmount > 0) ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('extra_packaging'.tr, style: robotoRegular),
                          Text('(+) ${PriceConverterHelper.convertPrice(extraPackagingAmount)}', style: robotoRegular),
                        ],
                      ) : const SizedBox(),
                      SizedBox(height: extraPackagingAmount > 0 ? 10 : 0),

                      (order.additionalCharge != null && order.additionalCharge! > 0) ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Expanded(
                          child: Text(Get.find<SplashController>().configModel!.additionalChargeName!, style: robotoRegular, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        SizedBox(width: Dimensions.paddingSizeSmall),

                        Text('(+) ${PriceConverterHelper.convertPrice(order.additionalCharge)}', style: robotoRegular, textDirection: TextDirection.ltr),
                      ]) : const SizedBox(),
                      (order.additionalCharge != null && order.additionalCharge! > 0) ? const SizedBox(height: 10) : const SizedBox(),

                      (tax! == 0) || taxIncluded ? const SizedBox() : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('vat_tax'.tr, style: robotoRegular),
                        Text('(+) ${PriceConverterHelper.convertPrice(tax)}', style: robotoRegular),
                      ]),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                        child: Divider(thickness: 1, color: Theme.of(context).hintColor.withValues(alpha: 0.5)),
                      ),

                      partialPay! ? DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          color: Theme.of(context).primaryColor,
                          strokeWidth: 1,
                          strokeCap: StrokeCap.butt,
                          dashPattern: const [8, 5],
                          padding: const EdgeInsets.all(0),
                          radius: const Radius.circular(Dimensions.radiusDefault),
                        ),
                        child: Ink(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          color: !restConfModel ? Theme.of(context).primaryColor.withValues(alpha: 0.05) : Colors.transparent,
                          child: Column(children: [

                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('total_amount'.tr, style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor,
                              )),
                              Text(
                                PriceConverterHelper.convertPrice(total),
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                              ),
                            ]),
                            const SizedBox(height: 10),

                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('paid_by_wallet'.tr, style: !restConfModel ? robotoMedium : robotoRegular),
                              Text(
                                PriceConverterHelper.convertPrice(order.payments![0].amount),
                                style: !restConfModel ? robotoMedium : robotoRegular,
                              ),
                            ]),
                            const SizedBox(height: 10),

                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('${order.payments?[1].paymentStatus == 'paid' ? 'paid_by'.tr : 'due_amount'.tr} (${order.payments![1].paymentMethod?.tr})', style: !restConfModel ? robotoMedium : robotoRegular),
                              Text(
                                PriceConverterHelper.convertPrice(order.payments![1].amount),
                                style: !restConfModel ? robotoMedium : robotoRegular,
                              ),
                            ]),
                          ]),
                        ),
                      ) : const SizedBox(),
                      SizedBox(height: partialPay ? 20 : 0),

                      !partialPay ? Row(children: [
                        Text('total_amount'.tr, style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor,
                        )),

                        taxIncluded ? Text(' ${'vat_tax_inc'.tr}', style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor,
                        )) : const SizedBox(),

                        const Expanded(child: SizedBox()),

                        Text(
                          PriceConverterHelper.convertPrice(total),
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                        ),
                      ]) : const SizedBox(),
                    ]),
                  ),

                ]),
              )),

              parcel ? ParcelBottomView(
                orderController: orderController, controllerOrderModel: controllerOrderModel, orderId: widget.orderId!,
                fromLocationScreen: widget.fromLocationScreen, showDeliveryConfirmImage: showDeliveryConfirmImage, total: total,
              ) : RegularOrderBottomView(
                orderController: orderController, controllerOrderModel: controllerOrderModel, fromLocationScreen: widget.fromLocationScreen,
                orderId: widget.orderId!, showDeliveryConfirmImage: showDeliveryConfirmImage, total: total,
              ),

            ]) : const Center(child: CircularProgressIndicator());
          }),
        ),
      ),
    );
  }

  void openDialog(BuildContext context, String imageUrl) => showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
        child: Stack(children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            child: PhotoView(
              tightMode: true,
              imageProvider: NetworkImage(imageUrl),
              heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
            ),
          ),

          Positioned(top: 0, right: 0, child: IconButton(
            splashRadius: 5,
            onPressed: () => Get.back(),
            icon: const Icon(Icons.cancel, color: Colors.red),
          )),

        ]),
      );
    },
  );
}
