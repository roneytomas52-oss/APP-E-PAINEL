import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/location/domain/models/prediction_model.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';
import 'package:sixam_mart/features/location/screens/pick_map_screen.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';

class GuestDeliveryAddress extends StatefulWidget {
  final CheckoutController checkoutController;
  final TextEditingController guestNameTextEditingController;
  final TextEditingController guestNumberTextEditingController;
  final TextEditingController guestEmailController;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;
  const GuestDeliveryAddress({super.key, required this.checkoutController, required this.guestNameTextEditingController,
    required this.guestNumberTextEditingController, required this.guestNumberNode, required this.guestEmailController, required this.guestEmailNode,
  });

  @override
  State<GuestDeliveryAddress> createState() => _GuestDeliveryAddressState();
}

class _GuestDeliveryAddressState extends State<GuestDeliveryAddress> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    bool takeAway = (widget.checkoutController.orderType == 'take_away');
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
      child: Column(children: [
        Row(children: [

          Text(takeAway ? 'contact_information'.tr : 'delivery_information'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color)),
          const Spacer(),

        ]),

        Column(children: [
          const SizedBox(height: Dimensions.paddingSizeLarge),
          CustomTextField(
            labelText: 'enter_your_name'.tr,
            titleText: 'write_name'.tr,
            inputType: TextInputType.name,
            controller: widget.guestNameTextEditingController,
            nextFocus: widget.guestNumberNode,
            capitalization: TextCapitalization.words,
            required: true,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          CustomTextField(
            labelText: 'phone'.tr,
            titleText: 'write_number'.tr,
            controller: widget.guestNumberTextEditingController,
            focusNode: widget.guestNumberNode,
            nextFocus: widget.guestEmailNode,
            inputType: TextInputType.phone,
            isPhone: true,
            required: true,
            onCountryChanged: (CountryCode countryCode) {
              widget.checkoutController.countryDialCode = countryCode.dialCode;
            },
            countryDialCode: widget.checkoutController.countryDialCode ?? Get.find<LocalizationController>().locale.countryCode,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          CustomTextField(
            titleText: 'enter_email'.tr,
            labelText: 'email'.tr,
            controller: widget.guestEmailController,
            focusNode: widget.guestEmailNode,
            inputAction: TextInputAction.done,
            inputType: TextInputType.emailAddress,
            // prefixIcon: Icons.mail,
            required: true,
          ),
          // const SizedBox(height: Dimensions.paddingSizeLarge),

          !takeAway ? Column(children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(top: isDesktop ? Dimensions.paddingSizeSmall : 0),
                child: TextButton(
                  onPressed: () async {
                    if(isDesktop) {
                      showGeneralDialog(context: context, pageBuilder: (_,__,___) {
                        return SizedBox(
                          height: 300, width: 300,
                          child: PickMapScreen(fromAddAddress: false, fromSignUp: false, fromLandingPage: false,
                            route: '', canRoute: false, fromGuestCheckout: true,
                            onPicked: (AddressModel address) async {
                              widget.checkoutController.getDistanceInKM(
                                LatLng(double.parse(address.latitude!), double.parse(address.longitude!)),
                                LatLng(double.parse(widget.checkoutController.store!.latitude!), double.parse(widget.checkoutController.store!.longitude!)),
                              );
                              widget.checkoutController.setGuestAddress(address, isUpdate: true);
                            }),
                        );
                      });
                    } else {
                      Get.toNamed(
                        RouteHelper.getPickMapRoute('parcel', false),
                        arguments: PickMapScreen(
                          fromAddAddress: false, fromSignUp: false, fromLandingPage: false,
                          route: '', canRoute: false, fromGuestCheckout: true,
                          onPicked: (AddressModel address) async {
                            widget.checkoutController.getDistanceInKM(
                              LatLng(double.parse(address.latitude!), double.parse(address.longitude!)),
                              LatLng(double.parse(widget.checkoutController.store!.latitude!), double.parse(widget.checkoutController.store!.longitude!)),
                            );
                            widget.checkoutController.setGuestAddress(address, isUpdate: true);
                          },
                        ),
                      );
                    }
                  },
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.location_on_rounded, color: Theme.of(context).primaryColor),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Text('select_from_map'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                  ]),
                ),
              ),
            ),

            Builder(
              builder: (context) {
                bool isExist = widget.checkoutController.contactPersonAddressController.text.isNotEmpty;
                return TypeAheadField(
                  hideOnEmpty: true,
                  controller: widget.checkoutController.contactPersonAddressController,
                  builder: (context, controller, focusNode) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onSubmitted: (text) => FocusScope.of(context).requestFocus(widget.checkoutController.streetNode),
                      textInputAction: TextInputAction.search,
                      textCapitalization: TextCapitalization.words,
                      keyboardType: TextInputType.streetAddress,
                      decoration: InputDecoration(
                        hintText: 'delivery_address'.tr,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          borderSide: BorderSide(style: BorderStyle.solid, width: ResponsiveHelper.isDesktop(context) ? 0.7 : 0.3, color: Theme.of(context).disabledColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          borderSide: BorderSide(style: BorderStyle.solid, width: 1, color: Theme.of(context).primaryColor),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          borderSide: BorderSide(style: BorderStyle.solid, width: 0.3, color: Theme.of(context).primaryColor),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          borderSide: BorderSide(style: BorderStyle.solid, color: Theme.of(context).colorScheme.error),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          borderSide: BorderSide(style: BorderStyle.solid, color: Theme.of(context).colorScheme.error),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          borderSide: BorderSide(style: BorderStyle.solid, color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),
                        ),
                        hintStyle: Theme.of(context).textTheme.displayMedium!.copyWith(
                          fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor,
                        ),
                        filled: true, fillColor: Theme.of(context).cardColor,
                        suffixIcon: IconButton(
                          onPressed: () async {
                            if(isExist) {
                              controller.clear();
                              widget.checkoutController.contactPersonAddressController.text = '';
                              setState(() {});
                              return;
                            }
                            Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);
                            AddressModel address = await Get.find<LocationController>().getCurrentLocation(true);
                            ZoneResponseModel responseModel = await Get.find<LocationController>().getZone(address.latitude.toString(), address.longitude.toString(), false);
                            if(!responseModel.isSuccess) {
                              showCustomSnackBar('service_not_available_in_this_location'.tr);
                              return;
                            }
                            AddressModel modifiedAddress = AddressModel(
                              id: address.id, addressType: address.addressType, contactPersonNumber: address.contactPersonNumber, contactPersonName: address.contactPersonName,
                              address: address.address, latitude: address.latitude, longitude: address.longitude, zoneId: responseModel.isSuccess ? responseModel.zoneIds[0] : 0,
                              zoneIds: responseModel.zoneIds, method: address.method, streetNumber: address.streetNumber, house: address.house, floor: address.floor,
                              zoneData: responseModel.zoneData,
                            );
                            widget.checkoutController.getDistanceInKM(
                              LatLng(double.parse(address.latitude!), double.parse(address.longitude!)),
                              LatLng(double.parse(widget.checkoutController.store!.latitude!), double.parse(widget.checkoutController.store!.longitude!)),
                            );
                            widget.checkoutController.setGuestAddress(modifiedAddress, isUpdate: true);
                            Get.back();
                          },
                          icon: Icon(isExist ? Icons.clear : Icons.my_location, color: isExist ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).primaryColor),
                        ),
                      ),
                      style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeLarge,
                      ),
                    );
                  },

                  suggestionsCallback: (pattern) async {
                    return await Get.find<LocationController>().searchLocation(context, pattern);
                  },
                  itemBuilder: (context, PredictionModel suggestion) {
                    return Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: Row(children: [
                        const Icon(Icons.location_on),
                        Expanded(child: Text(
                          suggestion.description ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.displayMedium!.copyWith(
                            color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeLarge,
                          ),
                        )),
                      ]),
                    );
                  },
                  onSelected: (PredictionModel suggestion) async {
                    AddressModel address = await Get.find<LocationController>().setLocation(suggestion.placeId, suggestion.description, null);
                    ZoneResponseModel responseModel = await Get.find<LocationController>().getZone(address.latitude.toString(), address.longitude.toString(), false);
                    if(!responseModel.isSuccess) {
                      showCustomSnackBar('service_not_available_in_this_location'.tr);
                      return;
                    }
                    AddressModel modifiedAddress = AddressModel(
                      id: address.id, addressType: address.addressType, contactPersonNumber: address.contactPersonNumber, contactPersonName: address.contactPersonName,
                      address: address.address, latitude: address.latitude, longitude: address.longitude, zoneId: responseModel.isSuccess ? responseModel.zoneIds[0] : 0,
                      zoneIds: responseModel.zoneIds, method: address.method, streetNumber: address.streetNumber, house: address.house, floor: address.floor,
                      zoneData: responseModel.zoneData,
                    );
                    widget.checkoutController.setGuestAddress(modifiedAddress, isUpdate: false);
                    widget.checkoutController.getDistanceInKM(
                      LatLng(double.parse(address.latitude!), double.parse(address.longitude!)),
                      LatLng(double.parse(widget.checkoutController.store!.latitude!), double.parse(widget.checkoutController.store!.longitude!)),
                    );
                    if(widget.checkoutController.contactPersonAddressController.text.isNotEmpty) {
                      Future.delayed(const Duration(milliseconds: 200) , (){
                        FocusScope.of(Get.context!).requestFocus(widget.checkoutController.streetNode);
                      });
                    }
                  },

                  errorBuilder : (_,value) {
                    return const SizedBox();
                  },
                );
              }
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Column(
              children: [
                if(_isExpanded) ...[
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  !isDesktop ? CustomTextField(
                    labelText: 'street_number'.tr,
                    titleText: 'write_street_number'.tr,
                    inputType: TextInputType.streetAddress,
                    focusNode: widget.checkoutController.streetNode,
                    nextFocus: widget.checkoutController.houseNode,
                    controller: widget.checkoutController.streetNumberController,
                  ) : const SizedBox(),
                  SizedBox(height: !isDesktop ? Dimensions.paddingSizeLarge : 0),

                  Row(
                      children: [
                        isDesktop ? Expanded(
                          child: CustomTextField(
                            titleText: 'write_street_number'.tr,
                            labelText: 'street_number'.tr,
                            inputType: TextInputType.streetAddress,
                            focusNode: widget.checkoutController.streetNode,
                            nextFocus: widget.checkoutController.houseNode,
                            controller: widget.checkoutController.streetNumberController,
                          ),
                        ) : const SizedBox(),
                        SizedBox(width: isDesktop ? Dimensions.paddingSizeSmall : 0),

                        Expanded(
                          child: CustomTextField(
                            titleText: 'write_house_number'.tr,
                            labelText: 'house'.tr,
                            inputType: TextInputType.text,
                            focusNode: widget.checkoutController.houseNode,
                            nextFocus: widget.checkoutController.floorNode,
                            controller: widget.checkoutController.houseController,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Expanded(
                          child: CustomTextField(
                            titleText: 'write_floor_number'.tr,
                            labelText: 'floor'.tr,
                            inputType: TextInputType.text,
                            focusNode: widget.checkoutController.floorNode,
                            inputAction: TextInputAction.done,
                            controller: widget.checkoutController.floorController,
                          ),
                        ),

                      ]
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                ],
                InkWell(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_isExpanded ? 'show_less'.tr : 'view_more_details'.tr, style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Theme.of(context).primaryColor, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),

          ]) : const SizedBox(),

        ]),

      ]),
    );
  }

  Widget addressInfo(String key, String value) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('$key: ', style: robotoRegular),
        Flexible(child: Text(value, style: robotoRegular, maxLines: 1, overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}
