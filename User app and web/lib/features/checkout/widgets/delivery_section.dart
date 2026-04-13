import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/common/widgets/address_widget.dart';
import 'package:sixam_mart/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/features/checkout/widgets/address_bottom_sheet.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/location/domain/models/prediction_model.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_dropdown.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/features/checkout/widgets/guest_delivery_address.dart';

class DeliverySection extends StatefulWidget {
  final CheckoutController checkoutController;
  final List<AddressModel> address;
  final List<DropdownItem<int>> addressList;
  final TextEditingController guestNameTextEditingController;
  final TextEditingController guestNumberTextEditingController;
  final TextEditingController guestEmailController;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;
  final bool isServiceAddress;
  final int? zoneId;
  const DeliverySection( {super.key, required this.checkoutController, required this.address, required this.addressList, required this.guestNameTextEditingController,
    required this.guestNumberTextEditingController, required this.guestNumberNode, required this.guestEmailController, required this.guestEmailNode, this.isServiceAddress = false, this.zoneId,
  });

  @override
  State<DeliverySection> createState() => _DeliverySectionState();
}

class _DeliverySectionState extends State<DeliverySection> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    _isExpanded = ResponsiveHelper.isDesktop(Get.context) ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    bool isGuestLoggedIn = AuthHelper.isGuestLoggedIn();
    bool takeAway = (widget.checkoutController.orderType == 'take_away');
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return Column(children: [
      isGuestLoggedIn ? GuestDeliveryAddress(
        checkoutController: widget.checkoutController, guestNumberNode: widget.guestNumberNode,
        guestNameTextEditingController: widget.guestNameTextEditingController, guestNumberTextEditingController: widget.guestNumberTextEditingController,
        guestEmailController: widget.guestEmailController, guestEmailNode: widget.guestEmailNode,
      ) : !takeAway ? Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('delivery_information'.tr, style: robotoMedium),

            TextButton.icon(
              onPressed: () async {
                if(isDesktop){
                  Get.dialog(
                    Dialog(child: AddressBottomSheet()),
                  );
                }else{
                  showCustomBottomSheet(child: AddressBottomSheet());
                }
                // var address = await Get.toNamed(RouteHelper.getAddAddressRoute(true, false, widget.checkoutController.store!.zoneId));
                // if(address != null) {
                //   widget.checkoutController.getDistanceInKM(
                //     LatLng(double.parse(address.latitude), double.parse(address.longitude)),
                //     LatLng(double.parse(widget.checkoutController.store!.latitude!), double.parse(widget.checkoutController.store!.longitude!)),
                //   );
                //   widget.checkoutController.streetNumberController.text = address.streetNumber ?? '';
                //   widget.checkoutController.houseController.text = address.house ?? '';
                //   widget.checkoutController.floorController.text = address.floor ?? '';
                // }
              },
              icon: const Icon(Icons.arrow_drop_down, size: 20),
              label: Text('change_address'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
            ),
          ]),


          isDesktop ?  Stack(children: [
            Container(
              constraints: const BoxConstraints(minHeight:  90),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
              ),
              child: Container(
                height: 45,
                padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeExtraSmall,
                  horizontal: Dimensions.paddingSizeExtraSmall,
                ),
                child: AddressWidget(
                  address: widget.address[widget.checkoutController.addressIndex!],
                  fromAddress: false, fromCheckout: true,
                ),
              ),
            ),

            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: PopupMenuButton(
                    position: PopupMenuPosition.under,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    onSelected: (value) {},
                    itemBuilder: (context)  => List.generate(
                      widget.address.length, (index) => PopupMenuItem(
                      child: InkWell(
                        onTap: () {
                          widget.checkoutController.getDistanceInKM(
                            LatLng(
                              double.parse(widget.address[index].latitude!),
                              double.parse(widget.address[index].longitude!),
                            ),
                            LatLng(double.parse(widget.checkoutController.store!.latitude!), double.parse(widget.checkoutController.store!.longitude!)),
                          );
                          widget.checkoutController.setAddressIndex(index);
                          widget.checkoutController.streetNumberController.text = widget.address[widget.checkoutController.addressIndex!].streetNumber ?? '';
                          widget.checkoutController.houseController.text = widget.address[widget.checkoutController.addressIndex!].house ?? '';
                          widget.checkoutController.floorController.text = widget.address[widget.checkoutController.addressIndex!].floor ?? '';
                          Navigator.pop(context);
                        },
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 20, width: 20,
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: widget.checkoutController.addressIndex == index ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),
                                ),
                                child: widget.checkoutController.addressIndex == index ? Container(
                                  height: 15, width: 15,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
                                ) : const SizedBox(),
                              ),

                              const SizedBox(width: Dimensions.paddingSizeSmall),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.address[index].addressType!.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                    Text(
                                      widget.address[index].address!, maxLines: 1, overflow: TextOverflow.ellipsis,
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                                    ),
                                  ],
                                ),
                              ),
                            ]
                        ),
                      ),
                    )
                    )
                ),
              ),
            ),
          ]) : Column(children: [

            CustomTextField(
              labelText: 'name'.tr,
              titleText: 'write_name'.tr,
              inputType: TextInputType.name,
              required: true,
              focusNode: widget.checkoutController.nameNode,
              nextFocus: widget.checkoutController.phoneNode,
              controller: widget.checkoutController.contactPersonNameController,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            CustomTextField(
              labelText: 'contact_person_number'.tr,
              titleText: 'write_number'.tr,
              controller: widget.checkoutController.contactPersonNumberController,
              inputType: TextInputType.phone,
              focusNode: widget.checkoutController.phoneNode,
              isPhone: true,
              required: true,
              onCountryChanged: (CountryCode countryCode) {
                widget.checkoutController.countryDialCode = countryCode.dialCode;
              },
              countryDialCode: widget.checkoutController.countryDialCode ?? Get.find<LocalizationController>().locale.countryCode,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            TypeAheadField(
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
                        if(widget.checkoutController.contactPersonAddressController.text.isNotEmpty) {
                          controller.clear();
                          widget.checkoutController.contactPersonAddressController.text = '';
                          return;
                        }
                        Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);
                        AddressModel address = await Get.find<LocationController>().getCurrentLocation(true);
                        ZoneResponseModel responseModel = await Get.find<LocationController>().getZone(address.latitude.toString(), address.longitude.toString(), false);
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
                        widget.checkoutController.insertAddresses(modifiedAddress, notify: true);
                        Get.back();
                      },
                      icon: Icon(widget.checkoutController.contactPersonAddressController.text.isNotEmpty ? Icons.clear : Icons.my_location, color: widget.checkoutController.contactPersonAddressController.text.isNotEmpty ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).primaryColor),
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
                AddressModel modifiedAddress = AddressModel(
                  id: address.id, addressType: address.addressType, contactPersonNumber: address.contactPersonNumber, contactPersonName: address.contactPersonName,
                  address: address.address, latitude: address.latitude, longitude: address.longitude, zoneId: responseModel.isSuccess ? responseModel.zoneIds[0] : 0,
                  zoneIds: responseModel.zoneIds, method: address.method, streetNumber: address.streetNumber, house: address.house, floor: address.floor,
                  zoneData: responseModel.zoneData,
                );
                widget.checkoutController.insertAddresses(modifiedAddress, notify: false);
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
            ),

          ]),

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
              if(!isDesktop)
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
        ]),
      ) : const SizedBox(),
    ]);
  }
}
