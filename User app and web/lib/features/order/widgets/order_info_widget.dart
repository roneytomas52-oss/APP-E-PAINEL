import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_card.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/checkout/widgets/payment_method_bottom_sheet.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/features/chat/domain/models/conversation_model.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/review/domain/models/review_model.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/helper/string_extension.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/rating_bar.dart';
import 'package:sixam_mart/features/chat/widgets/image_dialog_widget.dart';
import 'package:sixam_mart/features/order/widgets/delivery_details_widget.dart';
import 'package:sixam_mart/features/payment/widgets/offline_info_edit_dialog_widget.dart';
import 'package:sixam_mart/features/order/widgets/order_banner_view_widget.dart';
import 'package:sixam_mart/features/order/widgets/order_item_widget.dart';
import 'package:sixam_mart/features/parcel/widgets/details_widget.dart';
import 'package:sixam_mart/features/review/widgets/review_dialog_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OrderInfoWidget extends StatelessWidget {
  final OrderModel order;
  final bool ongoing;
  final bool parcel;
  final bool prescriptionOrder;
  final OrderController orderController;
  final Function timerCancel;
  final Function startApiCall;
  final bool showChatPermission;
  const OrderInfoWidget({super.key, required this.order, required this.ongoing, required this.parcel, required this.prescriptionOrder, required this.orderController,
    required this.timerCancel, required this.startApiCall, required this.showChatPermission});

  @override
  Widget build(BuildContext context) {

    ExpansibleController controller = ExpansibleController();
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isGuestLoggedIn = AuthHelper.isGuestLoggedIn();

    return Stack(children: [

      !isDesktop ? OrderBannerViewWidget(
        order: order, orderController: orderController, ongoing: ongoing,
        parcel: parcel, prescriptionOrder: prescriptionOrder,
      ) : const SizedBox(),

      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        !isDesktop && (orderController.orderDetails!.isNotEmpty && orderController.orderDetails![0].itemDetails!.moduleType == 'food')
            && order.orderStatus != 'pending' ? SizedBox(height: Dimensions.paddingSizeExtraLarge) :SizedBox.shrink(),

        !isDesktop ? SizedBox(height: DateConverter.isBeforeTime(order.scheduleAt) && Get.find<SplashController>().getModuleConfig(order.moduleType).newVariation!
          ? order.orderStatus == 'pending' ? 100 : 140 :
          parcel || prescriptionOrder || (orderController.orderDetails!.isNotEmpty && orderController.orderDetails![0].itemDetails!.moduleType == 'grocery')
          || (orderController.orderDetails!.isNotEmpty && orderController.orderDetails![0].itemDetails!.moduleType == 'ecommerce')
          || (orderController.orderDetails!.isNotEmpty && orderController.orderDetails![0].itemDetails!.moduleType == 'pharmacy')
          ? 140 : 0) : const SizedBox(),

        CustomCard(
          isBorder: false, borderRadius: isDesktop ? Dimensions.radiusDefault : 0,
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [

            isDesktop ? OrderBannerViewWidget(
              order: order, orderController: orderController, ongoing: ongoing,
              parcel: parcel, prescriptionOrder: prescriptionOrder,
            ) : const SizedBox(),
            isDesktop ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),

            Text('general_info'.tr, style: robotoSemiBold),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            if(isDesktop)...[
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(parcel ? 'delivery_id'.tr : 'order_id'.tr, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6))),

                Text('#${order.id}', style: robotoBold),
              ]),
              Divider(height: Dimensions.paddingSizeLarge, color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('status'.tr, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6))),

                Text('${order.orderStatus?.tr}', style: robotoMedium.copyWith(color: order.orderStatus == 'canceled' || order.orderStatus == 'failed' ? Colors.red : null)),
              ]),
              Divider(height: Dimensions.paddingSizeLarge, color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),

            ],

            parcel && order.orderStatus == AppConstants.canceled ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('return_date_and_time'.tr, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6))),

              Text(order.parcelCancellation?.returnDate != null ? DateConverter.dateTimeStringToDateTime(order.parcelCancellation!.returnDate!) : 'not_set_yet'.tr, style: robotoRegular),
            ]) : const SizedBox(),
            parcel && order.orderStatus == AppConstants.canceled ? Divider(height: Dimensions.paddingSizeLarge, color: Theme.of(context).disabledColor.withValues(alpha: 0.5)) : const SizedBox(),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('order_date'.tr, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6))),

              Text(DateConverter.dateTimeStringToDateTime(order.createdAt!), style: robotoRegular),
            ]),
            Divider(height: Dimensions.paddingSizeLarge, color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),

            order.scheduled == 1 ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('scheduled_at'.tr, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6))),

              Text(DateConverter.dateTimeStringToDateTime(order.scheduleAt!), style: robotoRegular),
            ]) : const SizedBox(),
            order.scheduled == 1 ? Divider(height: Dimensions.paddingSizeLarge, color: Theme.of(context).disabledColor.withValues(alpha: 0.5)) : const SizedBox(),

            order.orderStatus != 'canceled' && Get.find<SplashController>().configModel!.orderDeliveryVerification! ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('delivery_verification_code'.tr, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6))),

              Text(order.otp ?? '', style: robotoBold),
            ]) : const SizedBox(),
            order.orderStatus != 'canceled' && Get.find<SplashController>().configModel!.orderDeliveryVerification! ? Divider(height: Dimensions.paddingSizeLarge, color: Theme.of(context).disabledColor.withValues(alpha: 0.5)) : const SizedBox(),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('payment_method'.tr, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6))),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: Text( order.paymentMethod == 'cash_on_delivery' ? 'cash_on_delivery'.tr
                  : order.paymentMethod == 'wallet' ? 'wallet_payment'.tr
                  : order.paymentMethod == 'partial_payment' ? 'partial_payment'.tr
                  : order.paymentMethod == 'offline_payment' ? 'offline_payment'.tr : 'digital_payment'.tr,
                  style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall),
                ),
              ),
            ]),
            Divider(color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('order_type'.tr, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6))),

              Text(order.orderType == 'delivery' ? 'home_delivery'.tr : order.orderType!.tr ,
                style: robotoBold.copyWith(color: Colors.blueAccent, fontSize: Dimensions.fontSizeSmall),
              ),
            ]),
            parcel ? Divider(color: Theme.of(context).disabledColor.withValues(alpha: 0.5)) : const SizedBox(),

            parcel ? Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('charge_pay_by'.tr, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6))),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                Text(
                  order.chargePayer!.tr,
                  style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                ),
              ]),
            ) : const SizedBox(),
            order.orderStatus == 'delivered' ? Divider(height: Dimensions.paddingSizeLarge, color: Theme.of(context).disabledColor.withValues(alpha: 0.5)) : const SizedBox(),

            order.orderStatus == 'delivered' ? Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('delivered_at'.tr, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6))),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                Text(
                  DateConverter.dateTimeStringToDateTime(order.delivered!),
                  style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                ),
              ]),
            ) : const SizedBox(),

            Get.find<SplashController>().getModuleConfig(order.moduleType).newVariation! ? Column(children: [
              Divider(color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('cutlery'.tr, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6))),

                Text(
                  order.cutlery! ? 'yes'.tr : 'no'.tr,
                  style: robotoRegular,
                ),
              ]),
            ]) : const SizedBox(),

            order.unavailableItemNote != null ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Divider(height: Dimensions.paddingSizeLarge, color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),

              RichText(maxLines: 3, overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                  children: [
                    TextSpan(text: '${'unavailable_item_note'.tr}: ', style: robotoMedium),
                    TextSpan(text: order.unavailableItemNote ?? '', style: robotoRegular),
                  ],
                ),
              ),
            ]) : const SizedBox(),

            order.deliveryInstruction != null ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Divider(height: Dimensions.paddingSizeLarge, color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),

              RichText(
                text: TextSpan(
                  text: '${'delivery_instruction'.tr}: ',
                  style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color),
                  children: <TextSpan>[
                    TextSpan(
                      text: order.deliveryInstruction?.tr ?? '',
                      style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6))
                    ),
                  ],
                ),
              ),
            ]) : const SizedBox(),
            SizedBox(height: order.deliveryInstruction != null ? Dimensions.paddingSizeSmall : 0),

            !parcel ? order.orderStatus == 'canceled' ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Divider(height: Dimensions.paddingSizeLarge, color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),

              Text('${'cancellation_note'.tr}: ', style: robotoMedium),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              order.cancellationReason != null ? InkWell(
                onTap: () => Get.dialog(ReviewDialogWidget(review: ReviewModel(comment: order.cancellationReason), fromOrderDetails: true)),
                child: Text(
                  order.cancellationReason ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6)),
                ),
              ) : order.cancellationNote != null ? Text(
                order.cancellationNote ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6)),
              ) : const SizedBox(),
            ]) : const SizedBox() : const SizedBox(),

            (order.orderStatus == 'refund_requested' || order.orderStatus == 'refund_request_canceled') ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Divider(height: Dimensions.paddingSizeLarge, color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),

              order.orderStatus == 'refund_requested' ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                RichText(text: TextSpan(children: [
                  TextSpan(text: '${'refund_note'.tr}:', style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color)),
                  TextSpan(text: '(${(order.refund != null) ? order.refund!.customerReason : ''})', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color)),
                ])),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                (order.refund != null && order.refund!.customerNote != null) ? InkWell(
                  onTap: () => Get.dialog(ReviewDialogWidget(review: ReviewModel(comment: order.refund!.customerNote), fromOrderDetails: true)),
                  child: Text(
                    '${order.refund!.customerNote}', maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                  ),
                ) : const SizedBox(),
                SizedBox(height: (order.refund != null && order.refund!.imageFullUrl != null) ? Dimensions.paddingSizeSmall : 0),

                (order.refund != null && order.refund!.imageFullUrl != null && order.refund!.imageFullUrl!.isNotEmpty) ? InkWell(
                  onTap: () => showDialog(context: context, builder: (context) {
                    return ImageDialogWidget(imageUrl: order.refund!.imageFullUrl!.isNotEmpty ? order.refund!.imageFullUrl![0] : '');
                  }),
                  child: CustomImage(
                    height: 40, width: 40, fit: BoxFit.cover,
                    image: order.refund != null ? order.refund!.imageFullUrl!.isNotEmpty ? order.refund!.imageFullUrl![0] : '' : '',
                  ),
                ) : const SizedBox(),
              ]) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${'refund_cancellation_note'.tr}:', style: robotoMedium),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                InkWell(
                  onTap: () => Get.dialog(ReviewDialogWidget(review: ReviewModel(comment: order.refund!.adminNote), fromOrderDetails: true)),
                  child: Text(
                    '${order.refund != null ? order.refund!.adminNote : ''}', maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                  ),
                ),

              ]),
            ]) : const SizedBox(),

            order.bringChangeAmount != null && order.bringChangeAmount! > 0 ? Column(children: [
              Divider(height: Dimensions.paddingSizeLarge, color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: const Color(0XFF009AF1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(text: 'please_bring'.tr, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                    TextSpan(text: ' ${PriceConverter.convertPrice(order.bringChangeAmount)}', style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                    TextSpan(text: ' ${'in_change_when_making_the_delivery'.tr}', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                  ]),
                ),
              ),
            ]) : const SizedBox(),

          ]),
        ),
        SizedBox(height: Dimensions.paddingSizeSmall),

        (order.orderNote != null && order.orderNote!.isNotEmpty) ? CustomCard(
          borderRadius: isDesktop ? Dimensions.radiusDefault : 0, isBorder: false,
          padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('additional_note'.tr, style: robotoRegular),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            InkWell(
              onTap: () => Get.dialog(ReviewDialogWidget(review: ReviewModel(comment: order.orderNote), fromOrderDetails: true)),
              child: Text(
                order.orderNote!, overflow: TextOverflow.ellipsis, maxLines: 3,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
              ),
            ),
          ]),
        ) : const SizedBox(),
        SizedBox(height: (order.orderNote != null && order.orderNote!.isNotEmpty) ? Dimensions.paddingSizeDefault : 0),

        parcel && order.parcelCancellation != null ? CustomCard(
          borderRadius: isDesktop ? Dimensions.radiusDefault : 0, isBorder: false,
          padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            order.parcelCancellation!.returnFee != null && order.parcelCancellation!.returnFee! > 0 ? Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('you_will_pay_return_fee'.tr, style: robotoRegular),

                Text(PriceConverter.convertPrice(order.parcelCancellation!.returnFee), style: robotoBold),
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
        SizedBox(height: parcel && order.parcelCancellation != null ?  Dimensions.paddingSizeSmall : 0),

        (!parcel && isDesktop) ? Text('delivery_information'.tr, style: robotoMedium) :  const SizedBox(),
        (!parcel && isDesktop) ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),

        (!parcel && order.store != null && (order.deliveryAddress?.address != null || order.deliveryAddress?.contactPersonNumber != null || order.deliveryAddress?.contactPersonName != null) ) ? CustomCard(
          borderRadius: isDesktop ? Dimensions.radiusDefault : 0, isBorder: false,
          padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            !isDesktop ? Text('delivery_information'.tr, style: robotoSemiBold) : const SizedBox(),
            !isDesktop ? const Divider() : const SizedBox(),

            DeliveryDetailsWidget(deliveryAddress: order.deliveryAddress),

          ]),
        ) : const SizedBox(),


        // Item - info
        // SizedBox(height: !isDesktop ? (parcel || orderController.orderDetails!.isNotEmpty) ? Dimensions.paddingSizeSmall : 0 : 0),
        !isDesktop ? (parcel || orderController.orderDetails!.isNotEmpty) ? CustomCard(
          borderRadius: isDesktop ? Dimensions.radiusDefault : 0, isBorder: false,
          padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: parcel ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            DetailsWidget(title: 'sender_details'.tr, address: order.deliveryAddress),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            DetailsWidget(title: 'receiver_details'.tr, address: order.receiverDetails),
          ]) : Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              childrenPadding: EdgeInsets.zero,
              initiallyExpanded: true,
              tilePadding: EdgeInsets.zero,
              title: Row(children: [
                Text('item_info'.tr, style: robotoSemiBold),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text('${orderController.orderDetails!.length}',
                    style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeSmall),
                  ),
                ),
              ]),
              children: <Widget>[
                ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orderController.orderDetails!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: index == orderController.orderDetails!.length - 1 ? 0 : Dimensions.paddingSizeSmall),
                      child: OrderItemWidget(order: order, orderDetails: orderController.orderDetails![index]),
                    );
                  },
                ),
              ],
            ),
          ),
        ) : const SizedBox() : const SizedBox(),

        (isDesktop && Get.find<SplashController>().getModuleConfig(order.moduleType).orderAttachment! && order.orderAttachmentFullUrl != null
          && order.orderAttachmentFullUrl!.isNotEmpty ) ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),

        (isDesktop && Get.find<SplashController>().getModuleConfig(order.moduleType).orderAttachment! && order.orderAttachmentFullUrl != null
          && order.orderAttachmentFullUrl!.isNotEmpty )  ? Text('prescription'.tr, style: robotoMedium) :  const SizedBox(),

        (isDesktop && Get.find<SplashController>().getModuleConfig(order.moduleType).orderAttachment! && order.orderAttachmentFullUrl != null
          && order.orderAttachmentFullUrl!.isNotEmpty ) ? const SizedBox(height: Dimensions.paddingSizeLarge) : const SizedBox(),

        (Get.find<SplashController>().getModuleConfig(order.moduleType).orderAttachment! && order.orderAttachmentFullUrl != null && order.orderAttachmentFullUrl!.isNotEmpty) ? CustomCard(
          borderRadius: isDesktop ? Dimensions.radiusDefault : 0, isBorder: false,
          padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            !isDesktop ? Text('prescription'.tr, style: robotoSemiBold) : const SizedBox(),
            !isDesktop ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),

            SizedBox(child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 1,
                crossAxisCount: isDesktop ? 8 : 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 5,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.orderAttachmentFullUrl!.length,
              itemBuilder: (BuildContext context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => openDialog(context, '${order.orderAttachmentFullUrl![index]}'),
                    child: Center(child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      child: CustomImage(
                        image: '${order.orderAttachmentFullUrl![index]}',
                        width: 100, height: 100,
                      ),
                    )),
                  ),
                );
              }),
            ),

            const SizedBox(height: Dimensions.paddingSizeLarge),

            SizedBox(width: (Get.find<SplashController>().getModuleConfig(order.moduleType).orderAttachment!
                && order.orderAttachmentFullUrl != null && order.orderAttachmentFullUrl!.isNotEmpty) ? Dimensions.paddingSizeSmall : 0),

          ]),
        ) : const SizedBox(),
        SizedBox(height: Get.find<SplashController>().getModuleConfig(order.moduleType).orderAttachment! && order.orderAttachmentFullUrl != null && order.orderAttachmentFullUrl!.isNotEmpty ? Dimensions.paddingSizeSmall : 0),

        (order.orderStatus == 'delivered' && order.orderProofFullUrl != null && order.orderProofFullUrl!.isNotEmpty) ? CustomCard(
          borderRadius: isDesktop ? Dimensions.radiusDefault : 0, isBorder: false,
          padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
          margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              itemCount: order.orderProofFullUrl!.length,
              itemBuilder: (BuildContext context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => openDialog(context, order.orderProofFullUrl![index]),
                    child: Center(child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      child: CustomImage(
                        image: order.orderProofFullUrl![index],
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
        SizedBox(height: (order.orderStatus == 'delivered' && order.orderProofFullUrl != null && order.orderProofFullUrl!.isNotEmpty) ? Dimensions.paddingSizeSmall : 0),

        (order.deliveryMan != null && isDesktop) ? Text('delivery_man_details'.tr, style: robotoMedium) : const SizedBox(),
        SizedBox(height: (order.deliveryMan != null && isDesktop) ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeSmall),

        order.deliveryMan != null ? CustomCard(
          borderRadius: isDesktop ? Dimensions.radiusDefault : 0, isBorder: false,
          padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('delivery_man_details'.tr, style: robotoSemiBold),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Row(children: [
              ClipOval(child: CustomImage(
                image: '${order.deliveryMan!.imageFullUrl}',
                height: 35, width: 35, fit: BoxFit.cover,
              )),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${order.deliveryMan!.fName} ${order.deliveryMan!.lName}', maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                ),
                RatingBar(
                  rating: order.deliveryMan!.avgRating, size: 10,
                  ratingCount: order.deliveryMan!.ratingCount,
                ),
              ])),

              (order.orderStatus != 'delivered' && order.orderStatus != 'failed' && order.orderStatus != 'canceled' && order.orderStatus != 'refunded') ? Row(children: [

                showChatPermission ? InkWell(
                  onTap: () async{
                    timerCancel();
                    await Get.toNamed(RouteHelper.getChatRoute(
                      notificationBody: NotificationBodyModel(deliverymanId: order.deliveryMan!.id, orderId: int.parse(order.id.toString())),
                      user: User(id: order.deliveryMan!.id, fName: order.deliveryMan!.fName, lName: order.deliveryMan!.lName, imageFullUrl: order.deliveryMan!.imageFullUrl),
                    ));
                    startApiCall();
                  },
                  child: Image.asset(Images.chatOrderDetails, height: 20, width: 20),
                ) : const SizedBox(),
                SizedBox(width: showChatPermission ? Dimensions.paddingSizeSmall : 0),

                InkWell(
                  onTap: () async {
                    if(await canLaunchUrlString('tel:${order.deliveryMan!.phone}')) {
                      launchUrlString('tel:${order.deliveryMan!.phone}', mode: LaunchMode.externalApplication);
                    }else {
                      showCustomSnackBar('${'can_not_launch'.tr} ${order.deliveryMan!.phone}');
                    }
                  },
                  child: Image.asset(Images.phoneOrderDetails, height: 20, width: 20),
                ),

              ]) : const SizedBox(),

            ]),
          ]),
        ) : const SizedBox(),
        SizedBox(height: order.deliveryMan != null ? Dimensions.paddingSizeSmall : 0),

        (parcel &&  isDesktop) ? CustomCard(
          borderRadius: isDesktop ? Dimensions.radiusDefault : 0, isBorder: false,
          padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            DetailsWidget(title: 'sender_details'.tr, address: order.deliveryAddress),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            DetailsWidget(title: 'receiver_details'.tr, address: order.receiverDetails),
          ]),
        ) : const SizedBox(),
        SizedBox(height: (parcel &&  isDesktop) ? Dimensions.paddingSizeSmall : 0),


        SizedBox(height: (!parcel && order.store != null) ? Dimensions.paddingSizeSmall : 0),

        isDesktop ? Text(parcel ? 'parcel_category'.tr : Get.find<SplashController>().getModuleConfig(order.moduleType).showRestaurantText! ? 'restaurant_details'.tr : 'store_details'.tr, style: robotoMedium)  : const SizedBox(),

        SizedBox(height: isDesktop ? Dimensions.paddingSizeSmall : 0),

        CustomCard(
          borderRadius: isDesktop ? Dimensions.radiusDefault : 0, isBorder: false,
          padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            !isDesktop ? Text(parcel ? 'parcel_category'.tr : Get.find<SplashController>().getModuleConfig(order.moduleType).showRestaurantText! ? 'restaurant_details'.tr : 'store_details'.tr, style: robotoSemiBold) : const SizedBox(),
            !isDesktop ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),

            (parcel && order.parcelCategory == null) ? Text(
              'no_parcel_category_data_found'.tr, style: robotoMedium,
            ) : (!parcel && order.store == null) ? Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              child: Text('no_restaurant_data_found'.tr, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
            )) : Row(children: [
              ClipOval(child: CustomImage(
                image: parcel ? '${order.parcelCategory!.imageFullUrl}' : '${order.store!.logoFullUrl}',
                height: 35, width: 35, fit: BoxFit.cover,
              )),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  parcel ? order.parcelCategory!.name! : order.store!.name!, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                ),
                Text(
                  parcel ? order.parcelCategory!.description! : order.store?.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                ),
              ])),

              (!parcel && order.orderType == 'take_away' && (order.orderStatus == 'pending' || order.orderStatus == 'accepted'
                  || order.orderStatus == 'confirmed' || order.orderStatus == 'processing' || order.orderStatus == 'handover'
                  || order.orderStatus == 'picked_up')) ? TextButton.icon(onPressed: () async {
                if(!parcel) {
                  String url ='https://www.google.com/maps/dir/?api=1&destination=${order.store!.latitude}'
                      ',${order.store!.longitude}&mode=d';
                  if (await canLaunchUrlString(url)) {
                    await launchUrlString(url);
                  }else {
                    showCustomSnackBar('unable_to_launch_google_map'.tr);
                  }
                }
              }, icon: const Icon(Icons.directions), label: Text('direction'.tr),

              ) : const SizedBox(),

              (showChatPermission && AuthHelper.isLoggedIn() && !parcel && order.orderStatus != 'delivered' && order.orderStatus != 'failed' && order.orderStatus != 'canceled' && order.orderStatus != 'refunded') ? InkWell(
                onTap: () async {
                  await Get.toNamed(RouteHelper.getChatRoute(
                    notificationBody: NotificationBodyModel(orderId: order.id, restaurantId: order.store!.vendorId),
                    user: User(id: order.store!.vendorId, fName: order.store!.name, lName: '', imageFullUrl: order.store!.logoFullUrl),
                  ));
                },
                child: Image.asset(Images.chatOrderDetails, height: 20, width: 20),
              ) : const SizedBox(),

              SizedBox(width: order.store?.phone != null ? Dimensions.paddingSizeSmall : 0),

              (showChatPermission && AuthHelper.isLoggedIn() && !parcel && order.orderStatus != 'delivered'
                  && order.orderStatus != 'failed' && order.orderStatus != 'canceled' && order.orderStatus != 'refunded')
                  ? InkWell(
                onTap: () async {
                  if(await canLaunchUrlString('tel:${order.store?.phone ?? '' }')) {
                    launchUrlString('tel:${order.store?.phone ?? '' }', mode: LaunchMode.externalApplication);
                  }else {
                    showCustomSnackBar('${'can_not_launch'.tr} ${order.store?.phone ?? ''}');
                  }
                },
                child: Image.asset(Images.phoneOrderDetails, height: 20, width: 20),
              ) : const SizedBox(),

              !isGuestLoggedIn && (Get.find<SplashController>().configModel!.refundActiveStatus! && order.orderStatus == 'delivered' && !parcel
                  && (parcel || (orderController.orderDetails!.isNotEmpty && orderController.orderDetails![0].itemCampaignId == null))) ? InkWell(
                onTap: () => Get.toNamed(RouteHelper.getRefundRequestRoute(order.id.toString())),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: Dimensions.paddingSizeSmall),
                  child: Text('refund_this_order'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),
                ),
              ) : const SizedBox(),

            ]),
          ]),
        ),
        SizedBox(height: Dimensions.paddingSizeDefault),

        isDesktop ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('payment_method'.tr, style: robotoMedium),
            /*order.paymentMethod == 'offline_payment' ? Text(
              orderController.trackModel!.offlinePayment != null ? orderController.trackModel!.offlinePayment!.data!.status!.tr : '',
              style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
            ) : */const SizedBox(),
          ],
        ) : const SizedBox(),
        SizedBox(height: isDesktop ? Dimensions.paddingSizeLarge : 0),

        CustomCard(
          borderRadius: isDesktop ? Dimensions.radiusDefault : 0, isBorder: false,
          padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

              Text('payment_details'.tr, style: robotoSemiBold),

              if(order.paymentMethod == 'offline_payment' || (order.paymentMethod == 'partial_payment' && orderController.trackModel!.offlinePayment != null))...[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    color: (orderController.trackModel!.offlinePayment != null ? orderController.trackModel!.offlinePayment!.data!.status.toString() == 'denied' : false)
                        ? Colors.red.withValues(alpha: 0.1)
                        : orderController.trackModel!.offlinePayment == null ? Colors.red.withValues(alpha: 0.1) : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 2),
                  child: Text(
                    orderController.trackModel!.offlinePayment != null ? orderController.trackModel!.offlinePayment!.data!.status!.tr : 'unpaid'.tr,
                    style: robotoMedium.copyWith(color: (orderController.trackModel!.offlinePayment != null ? orderController.trackModel!.offlinePayment!.data!.status.toString() == 'denied' : false)
                        ? Colors.red
                        : orderController.trackModel!.offlinePayment == null ? Colors.red : Theme.of(context).primaryColor),
                  ),
                )
              ]else if(order.paymentMethod == 'partial_payment' && order.payments != null && order.payments![1].paymentStatus == 'unpaid')...[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 2),
                  child: Text(
                    'unpaid'.tr,
                    style: robotoRegular.copyWith(color: Colors.red),
                  ),
                )
              ]else...[
                Container(
                  decoration: BoxDecoration(
                    color: orderController.trackModel?.paymentStatus == 'unpaid' ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 2),
                  child: Text(
                    '${orderController.trackModel?.paymentStatus?.tr}',
                    style: robotoRegular.copyWith(color: orderController.trackModel?.paymentStatus == 'unpaid' ? Colors.red : Colors.green),
                  ),
                )
              ]

            ]),

            const Divider(height: Dimensions.paddingSizeLarge),

            order.paymentMethod == 'partial_payment' && order.orderStatus != 'canceled' && order.payments != null && order.payments![1].paymentStatus == 'unpaid' && order.payments![1].paymentMethod != 'cash_on_delivery'
                ? partialPaymentView(context, orderController, order.payments!)
                : order.paymentMethod == 'offline_payment' || (order.paymentMethod == 'partial_payment' && orderController.trackModel!.offlinePayment != null)
                ? offlineView(context, orderController, controller, ongoing) : Column(
              children: [

                const SizedBox(height: Dimensions.paddingSizeSmall),

                Row(children: [

                  Image.asset(
                    order.paymentMethod == 'cash_on_delivery' ? Images.cash
                        : order.paymentMethod == 'wallet' ? Images.wallet
                        : order.paymentMethod == 'partial_payment' ? Images.partialWallet
                        : Images.digitalPayment,
                    width: 20, height: 20,
                    color: order.paymentMethod == 'partial_payment' ? null : Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(
                    child: Text(
                      order.paymentMethod == 'cash_on_delivery' ? 'cash'.tr
                          : order.paymentMethod == 'wallet' ? 'wallet'.tr
                          : order.paymentMethod == 'partial_payment' ? '${'partial_payment'.tr} (${order.payments != null ? order.payments![1].paymentMethod?.tr.replaceAll('_', ' ').toCapitalized() : ''})'
                          : '${'digital_payment'.tr} ${order.paymentMethod != 'digital_payment' ? '(${order.paymentMethod?.toCapitalized().replaceAll('_', ' ')})' : ''}',
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color),
                    ),
                  ),

                  if(order.paymentMethod == 'wallet' || order.paymentMethod == 'cash_on_delivery')
                    Text(PriceConverter.convertPrice(order.orderAmount), style: robotoBold.copyWith(color: Theme.of(context).primaryColor),)

                ]),


                (order.paymentMethod == 'partial_payment' && order.orderStatus == 'failed' && order.payments != null && order.payments?[1].paymentMethod == 'digital_payment')
                    || (orderController.trackModel?.paymentStatus == 'unpaid' && order.orderStatus != 'canceled' && (order.paymentMethod != 'cash_on_delivery' && order.paymentMethod != 'wallet' && order.paymentMethod != 'partial_payment')) ? Column(
                  children: [
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Text('your_payment_was_incomplete_Please_choose_an_option_below_to_complete_your_transaction'.tr, style: robotoRegular, textAlign: TextAlign.start,),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    paymentSectionButton(context, orderController),
                  ],
                ) : const SizedBox(),

              ],
            ),

          ]),
        ),

      ]),

    ]);
  }
}

Widget paymentSectionButton(BuildContext context, OrderController orderController) {
  return (orderController.paymentModel != null && orderController.trackModel?.orderStatus != 'canceled') ? !orderController.isPaymentLoading ? Row(children: [
      orderController.paymentModel?.isCashOnDeliveryActive??false ? Expanded(
        child: CustomButton(
          buttonText: 'switch_to_cod'.tr,
          onPressed: (){
            if((((orderController.paymentModel?.maxCodOrderAmount != null && orderController.paymentModel!.orderAmount! < orderController.paymentModel!.maxCodOrderAmount!) || orderController.paymentModel!.maxCodOrderAmount == null || orderController.paymentModel!.maxCodOrderAmount == 0) && orderController.paymentModel!.orderType != 'parcel') || orderController.paymentModel!.orderType == 'parcel'){
              orderController.switchToCOD(orderController.paymentModel!.orderID, guestId: orderController.paymentModel!.guestId, fromOrderDetails: true).then((success){
                if(success){
                  orderController.timerTrackOrder(orderController.paymentModel!.orderID.toString(), contactNumber: orderController.paymentModel!.contactNumber);
                  if(AuthHelper.isLoggedIn()) {
                    Get.find<OrderController>().getRunningOrders(1);
                    Get.find<OrderController>().getHistoryOrders(1);
                    double total = ((orderController.paymentModel!.orderAmount! / 100) * Get.find<SplashController>().configModel!.loyaltyPointItemPurchasePoint!);
                    Get.find<AuthController>().saveEarningPoint(total.toStringAsFixed(0));
                  }
                }
              });
            }else{
              if(Get.isDialogOpen!) {
                Get.back();
              }
              showCustomSnackBar('${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(orderController.paymentModel!.maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}');
            }
          },
          color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
          textColor: Theme.of(context).textTheme.bodyLarge!.color,
        ),
      ) : const SizedBox(),
      SizedBox(width: orderController.paymentModel?.isCashOnDeliveryActive??false ? Dimensions.paddingSizeSmall : 0),

      !AuthHelper.isGuestLoggedIn() ? Expanded(
        child: CustomButton(
          buttonText: 'pay_again'.tr,
          onPressed: (){
            if(ResponsiveHelper.isDesktop(context)) {
              Get.dialog(Dialog(backgroundColor: Colors.transparent, child: PaymentMethodBottomSheet(
                isCashOnDeliveryActive: orderController.paymentModel?.isCashOnDeliveryActive??false, isDigitalPaymentActive: orderController.paymentModel?.isDigitalPaymentActive??false,
                totalPrice: orderController.paymentModel?.orderAmount??0, isOfflinePaymentActive: orderController.paymentModel?.isOfflinePaymentActive??false,
                paymentModel: orderController.paymentModel,
              )));

            } else {
              Get.bottomSheet(
                PaymentMethodBottomSheet(
                  isCashOnDeliveryActive: orderController.paymentModel?.isCashOnDeliveryActive??false, isDigitalPaymentActive: orderController.paymentModel?.isDigitalPaymentActive??false,
                  totalPrice: orderController.paymentModel?.orderAmount??0, isOfflinePaymentActive: orderController.paymentModel?.isOfflinePaymentActive??false,
                  paymentModel: orderController.paymentModel,
                ),
                backgroundColor: Colors.transparent, isScrollControlled: true,
              );
            }
          },
        ),
      ) : const SizedBox(),
    ]) : const Center(child: CircularProgressIndicator()) : const SizedBox();
}

Widget partialPaymentView(BuildContext context, OrderController orderController, List<Payments> payments) {
  return Column(children: [
    Row(children: [
      Image.asset(
        Images.partialWallet, width: 20, height: 20,
        // color: Theme.of(context).textTheme.bodyMedium!.color,
      ),
      const SizedBox(width: Dimensions.paddingSizeSmall),

      Expanded(
        child: Text(
          '${payments[1].paymentMethod?.tr} (${'partial'.tr})',
          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color),
        ),
      ),

      Text(PriceConverter.convertPrice(payments[1].amount??0), style: robotoBold.copyWith(color: Theme.of(context).primaryColor),)
    ]),
    const SizedBox(height: Dimensions.paddingSizeLarge),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('your_payment_was_incomplete_Please_choose_an_option_below_to_complete_your_transaction'.tr, style: robotoRegular, textAlign: TextAlign.start,),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        paymentSectionButton(context, orderController),
      ],
    ),

  ]);
}

Widget offlineView(BuildContext context, OrderController orderController, ExpansibleController controller, bool ongoing) {
  return Column(children: [
    Row(children: [
      Image.asset(
        Images.cash, width: 20, height: 20,
        color: Theme.of(context).textTheme.bodyMedium!.color,
      ),
      const SizedBox(width: Dimensions.paddingSizeSmall),

      Expanded(
        child: Text(
          '${orderController.trackModel?.paymentMethod == 'partial_payment' ? '${'partial'.tr} - ' : ''}${'offline_payment'.tr}${orderController.trackModel!.offlinePayment != null ? '(${orderController.trackModel!.offlinePayment!.data!.methodName})' : ''}',
          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color),
        ),
      ),

      if(orderController.trackModel!.offlinePayment != null)
        Text(PriceConverter.convertPrice(orderController.trackModel?.orderAmount??0), style: robotoBold.copyWith(color: Theme.of(context).primaryColor),)
    ]),
    const SizedBox(height: Dimensions.paddingSizeDefault),

    orderController.trackModel!.offlinePayment != null
        ? Column(children: [
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('seller_payment_info'.tr, style: robotoMedium.copyWith()),
            const SizedBox(),
          ]),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orderController.trackModel!.offlinePayment!.methodFields!.length,
            itemBuilder: (context, index){
              return Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 4, child: Text(orderController.trackModel!.offlinePayment!.methodFields![index].inputName.toString().replaceAll('_', ' '), style: robotoRegular)),
                  Text(': '),
                  Expanded(flex: 8, child: Text('${orderController.trackModel!.offlinePayment!.methodFields![index].inputData}', style: robotoRegular)),
                ]),
              );
            },
          ),
        ]),
      ),

      const SizedBox(height: Dimensions.paddingSizeSmall),

      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('my_payment_info'.tr, style: robotoMedium.copyWith()),

            (ongoing && orderController.trackModel!.offlinePayment != null && orderController.trackModel!.offlinePayment!.data!.status != 'verified') ? InkWell(
              onTap: (){
                Get.dialog(OfflineInfoEditDialogWidget(offlinePayment: orderController.trackModel!.offlinePayment!, orderId: orderController.trackModel!.id!), barrierDismissible: true);
              },
              child: Image.asset(Images.editIcon, height: 30,),
            ) : const SizedBox(),
          ]),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orderController.trackModel!.offlinePayment!.input!.length,
            itemBuilder: (context, index){
              Input data = orderController.trackModel!.offlinePayment!.input![index];
              return Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 4, child: Text(data.userInput.toString().replaceAll('_', ' '), style: robotoRegular)),
                  Text(': '),
                  Expanded(flex: 8, child: Text(data.userData.toString(), style: robotoRegular)),
                ]),
              );
            },
          ),
        ]),
      ),
      const SizedBox(height: Dimensions.paddingSizeDefault),

      orderController.trackModel!.offlinePayment!.data?.status == 'denied' ? Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: Colors.red.withValues(alpha: 0.2), width: 2),
            ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('# ${'denied_note'.tr}:', style: robotoBold.copyWith(color: Colors.red)),
              Text(orderController.trackModel!.offlinePayment!.data?.adminNote??'no_note_found'.tr, style: robotoMedium.copyWith()),
            ]),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          paymentSectionButton(context, orderController),
        ],
      ) : const SizedBox(),
    ])
        : orderController.trackModel?.orderStatus != 'canceled' ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('your_payment_was_incomplete_Please_choose_an_option_below_to_complete_your_transaction'.tr, style: robotoRegular, textAlign: TextAlign.start,),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        paymentSectionButton(context, orderController),
      ],
    ) : const SizedBox(),

  ]);
}

void openDialog(BuildContext context, String imageUrl) => showDialog(
  context: context,
  builder: (BuildContext context) {
    print("the image url is : $imageUrl");
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
      child: Stack(children: [

        ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          child: GetPlatform.isWeb ? CustomImage(image: imageUrl) : PhotoView(
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