import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/order_model.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class InfoCardWidget extends StatelessWidget {
  final String title;
  final String image;
  final String? name;
  final DeliveryAddress? address;
  final String? phone;
  final String? latitude;
  final String? longitude;
  final bool showButton;
  final bool isStore;
  final Function? messageOnTap;
  final OrderModel order;
  final bool isChatAllow;
  const InfoCardWidget({super.key, required this.title, required this.image, required this.name, required this.address, required this.phone,
    required this.latitude, required this.longitude, required this.showButton, this.messageOnTap, this.isStore = false, required this.order, required this.isChatAllow});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        boxShadow: Get.isDarkMode ? null : [BoxShadow(color: Colors.grey[200]!, spreadRadius: 1, blurRadius: 5)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Row( crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
          Spacer(),

          isStore && isChatAllow ? order.isGuest! ? const SizedBox() : GestureDetector(
            onTap:  messageOnTap as void Function()?,
            child: Image.asset(Images.chatIcon, width: 24),
          ) : const SizedBox(),
          SizedBox(width: Dimensions.paddingSizeSmall),
          GestureDetector(
            onTap: () async {
              if(await canLaunchUrlString('tel:$phone')) {
                launchUrlString('tel:$phone', mode: LaunchMode.externalApplication);
              }else {
                showCustomSnackBar('invalid_phone_number_found');
              }
            },
            child: Image.asset(Images.callIcon, width: 24),
          ),
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        (name != null && name!.isNotEmpty) ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Image
          ClipOval(child: CustomImageWidget(
            image: image,
            height: 40, width: 40, fit: BoxFit.cover,
          )),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Name
            Text(name!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            // Address
            Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(address!.address ?? '',
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor), maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: address!.address != null ? Dimensions.paddingSizeExtraSmall : 0),
                  Wrap(children: [
                    (address!.streetNumber != null && address!.streetNumber!.isNotEmpty) ? Text('${'street_number'.tr}: ${address!.streetNumber!}, ',
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor), maxLines: 1, overflow: TextOverflow.ellipsis,
                    ) : const SizedBox(),

                    (address!.house != null && address!.house!.isNotEmpty) ? Text('${'house'.tr}: ${address!.house!}, ',
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor), maxLines: 1, overflow: TextOverflow.ellipsis,
                    ) : const SizedBox(),

                    (address!.floor != null && address!.floor!.isNotEmpty) ? Text('${'floor'.tr}: ${address!.floor!}' ,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor), maxLines: 1, overflow: TextOverflow.ellipsis,
                    ) : const SizedBox(),
                  ]),
                ]),
              ),
              showButton ? Container(
                padding: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                    color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4)
                ),
                child: Row(children: [
                  GestureDetector(
                    onTap: () async {
                      String url ='https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&mode=d';
                      if (await canLaunchUrlString(url)) {
                        await launchUrlString(url, mode: LaunchMode.externalApplication);
                      } else {
                        throw '${'could_not_launch'.tr} $url';
                      }
                    },
                    child: Row(children: [
                      Icon(Icons.directions, color: Theme.of(context).disabledColor, size: 20),
                      SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text('direction'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),
                    ]),
                  ),
                ]),
              ) : const SizedBox(height: Dimensions.paddingSizeDefault),
            ]),
            SizedBox(height: Dimensions.paddingSizeExtraSmall)
          ])),

        ]) : Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: Text('no_store_data_found'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)))),

      ]),
    );
  }
}
