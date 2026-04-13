import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/address/controllers/address_controller.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/location/widgets/permission_dialog_widget.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class AddressBottomSheet extends StatefulWidget {
  const AddressBottomSheet({super.key});

  @override
  State<AddressBottomSheet> createState() => _AddressBottomSheetState();
}

class _AddressBottomSheetState extends State<AddressBottomSheet> {

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return GetBuilder<AddressController>(builder: (addressController) {
      return GetBuilder<CheckoutController>(builder: (checkoutController) {
        return GetBuilder<LocationController>(builder: (locationController) {
          return Container(
            width: isDesktop ? 500 : context.width,
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20), bottom: Radius.circular(isDesktop ? 20 : 0)),
            ),
            child: Stack(children: [
              Padding(
                padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall),
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Center(
                    child: Container(
                      height: 5, width: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).disabledColor.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('select_your_address'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),

                      // InkWell(
                      //   onTap: () async {
                      //     Get.back();
                      //
                      //     var address = await Get.toNamed(RouteHelper.getAddAddressRoute(true, false, checkoutController.store!.zoneId));
                      //     if(address != null) {
                      //
                      //       checkoutController.insertAddresses(address, notify: true);
                      //
                      //       checkoutController.getDistanceInKM(
                      //         LatLng(double.parse(address.latitude), double.parse(address.longitude )),
                      //         LatLng(double.parse(checkoutController.store!.latitude!), double.parse(checkoutController.store!.longitude!)),
                      //       );
                      //     }
                      //   },
                      //   child: Text('${'add_new_address'.tr} +', style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                      // ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Text('saved_addresses'.tr, style: robotoRegular),

                  addressController.addressList != null ? addressController.addressList!.isNotEmpty ? Flexible(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                      shrinkWrap: true,
                      itemCount: addressController.addressList?.length,
                      itemBuilder: (context, index) {
                        final address = addressController.addressList?[index];
                        bool isSelectedAddress = checkoutController.address?.latitude == address!.latitude && checkoutController.address?.longitude == address.longitude;

                        return Container(
                          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                          padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            color: isSelectedAddress ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            border: Border.all(
                              color: isSelectedAddress ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Theme.of(context).disabledColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: InkWell(
                            onTap: () async {
                              Get.back();

                              checkoutController.insertAddresses(address, notify: true);

                              checkoutController.getDistanceInKM(
                                LatLng(
                                  double.parse(address.latitude!),
                                  double.parse(address.longitude!),
                                ),
                                LatLng(double.parse(checkoutController.store!.latitude!), double.parse(checkoutController.store!.longitude!)),
                              );
                            },
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(mainAxisSize: MainAxisSize.min, children: [
                                Image.asset(
                                  address.addressType == 'home' ? Images.homeIcon : address.addressType == 'office' ? Images.workIcon : Images.otherIcon,
                                  color: isSelectedAddress ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                                  height: ResponsiveHelper.isDesktop(context) ? 25 : 18, width: ResponsiveHelper.isDesktop(context) ? 25 : 18,
                                ),
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                Text(
                                  address.addressType!.tr,
                                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                                ),
                              ]),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                              Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: Text(
                                  address.address ?? '',
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ]),
                          ),
                        );
                      },
                    ),
                  ) : Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 100),
                    child: CustomAssetImageWidget(Images.emptyBox, height: 100, width: 100),
                  )) : Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 100),
                    child: CircularProgressIndicator(),
                  )),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Center(
                    child: GestureDetector(
                      onTap: () {
                        _checkPermission(() async {
                          Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);
                          AddressModel addressModel = await locationController.getCurrentLocation(true, mapController: null, notify: true);

                          if(addressModel.zoneIds!.isNotEmpty) {
                            checkoutController.insertAddresses(addressModel, notify: true);

                            checkoutController.getDistanceInKM(
                              LatLng(locationController.position.latitude, locationController.position.longitude),
                              LatLng(double.parse(checkoutController.store!.latitude!), double.parse(checkoutController.store!.longitude!)),
                            );

                            Get.back();
                            Get.back();
                          }
                        });
                      },
                      child: Container(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
                      ),

                        child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [

                          Icon(Icons.my_location_sharp, size: 20, color: Theme.of(context).primaryColor),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          Text('use_my_current_location'.tr, style: robotoRegular),

                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Center(
                    child: InkWell(
                      onTap: () async {
                        Get.back();

                        var address = await Get.toNamed(RouteHelper.getAddAddressRoute(true, false, checkoutController.store!.zoneId));
                        if(address != null) {

                          checkoutController.insertAddresses(address, notify: true);

                          checkoutController.getDistanceInKM(
                            LatLng(double.parse(address.latitude), double.parse(address.longitude )),
                            LatLng(double.parse(checkoutController.store!.latitude!), double.parse(checkoutController.store!.longitude!)),
                          );
                        }
                      },
                      child: Text('${'add_new_address'.tr} +', style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                    ),
                  ),

                ]),
              ),

              Positioned(
                top: 0, right: 0,
                child: InkWell(
                  onTap: () => Get.back(),
                  child: Icon(Icons.clear, color: Theme.of(context).disabledColor, size: 20),
                ),
              ),
            ]),
          );
        });
      });
    });
  }

  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr);
    }else if(permission == LocationPermission.deniedForever) {
      Get.dialog(const PermissionDialogWidget());
    }else {
      onTap();
    }
  }

}
