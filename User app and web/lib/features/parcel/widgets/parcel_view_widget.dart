import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:sixam_mart/common/widgets/custom_card.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/address/controllers/address_controller.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/location/domain/models/prediction_model.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';
import 'package:sixam_mart/features/parcel/controllers/parcel_controller.dart';
import 'package:sixam_mart/features/parcel/widgets/saved_address_bottom_sheet.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/features/location/screens/pick_map_screen.dart';

class ParcelViewWidget extends StatefulWidget {
  final bool isSender ;
  final Widget bottomButton;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController streetController;
  final TextEditingController houseController;
  final TextEditingController floorController;
  final TextEditingController? guestEmailController;
  final String? countryCode;
  final TextEditingController senderAddressController;
  final TextEditingController receiverAddressController;
  const ParcelViewWidget({super.key, required this.isSender, required this.nameController, required this.phoneController,
    required this.streetController, required this.houseController, required this.floorController, required this.bottomButton, required this.countryCode,
    this.guestEmailController, required this.senderAddressController, required this.receiverAddressController});

  @override
  State<ParcelViewWidget> createState() => _ParcelViewWidgetState();
}

class _ParcelViewWidgetState extends State<ParcelViewWidget> {
  final FocusNode streetNode = FocusNode();
  final FocusNode houseNode = FocusNode();
  final FocusNode floorNode = FocusNode();
  final FocusNode nameNode = FocusNode();
  final FocusNode phoneNode = FocusNode();
  final FocusNode guestEmailNode = FocusNode();
  final FocusNode addressNode = FocusNode();

  String? _countryCode;
  String? _addressCountryCode;

  @override
  void initState() {
    super.initState();
    _addressCountryCode = null;
    _countryCode = _addressCountryCode ?? widget.countryCode;
    _setSenderAndReceiverAddress(isSender: widget.isSender, pickupAddress: Get.find<ParcelController>().pickupAddress, destinationAddress: Get.find<ParcelController>().destinationAddress);
  }

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);
    _countryCode = _addressCountryCode ?? widget.countryCode;
    String? countryDialCode;

    return SizedBox(width: Dimensions.webMaxWidth, child: GetBuilder<AddressController>(builder: (addressController) {
      return GetBuilder<ParcelController>(builder: (parcelController) {

        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   if (mounted) {
        //     _setSenderAndReceiverAddress(isSender: widget.isSender, pickupAddress: parcelController.pickupAddress, destinationAddress: parcelController.destinationAddress);
        //   }
        // });

        return Align(
        alignment: Alignment.topCenter,
        child: SizedBox(width: Dimensions.webMaxWidth, child: SingleChildScrollView(
          physics: ResponsiveHelper.isDesktop(context) ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [

            CustomCard(
              borderRadius: isDesktop ? Dimensions.radiusDefault : 0,
              isBorder: false,
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(children: [

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(widget.isSender ? 'pickup_location'.tr : 'delivery_location'.tr, style: robotoMedium),

                  addressController.addressList != null && addressController.addressList!.isNotEmpty && AuthHelper.isLoggedIn() ? InkWell(
                    onTap: () {
                      if(isDesktop){
                        Get.dialog(
                          Dialog(
                            child: SavedAddressBottomSheet(
                              isSender: widget.isSender,
                              nameController: widget.nameController,
                              phoneController: widget.phoneController,
                              streetController: widget.streetController,
                              houseController: widget.houseController,
                              floorController: widget.floorController,
                              guestEmailController: widget.guestEmailController,
                              senderAddressController: widget.senderAddressController,
                              receiverAddressController: widget.receiverAddressController,
                              countryCode: widget.countryCode,
                            ),
                          ),
                        );
                      }else{
                        showCustomBottomSheet(child: SavedAddressBottomSheet(
                          isSender: widget.isSender,
                          nameController: widget.nameController,
                          phoneController: widget.phoneController,
                          streetController: widget.streetController,
                          houseController: widget.houseController,
                          floorController: widget.floorController,
                          guestEmailController: widget.guestEmailController,
                          senderAddressController: widget.senderAddressController,
                          receiverAddressController: widget.receiverAddressController,
                          countryCode: widget.countryCode,
                        ));
                      }
                    },
                    child: Row(
                      children: [
                        Text('change_address'.tr, style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor,
                        )),
                        Icon(Icons.arrow_drop_down_rounded, size: 34, color: Theme.of(context).primaryColor),
                        // Image.asset(Images.paymentSelect, height: 24, width: 24),
                      ],
                    ),
                  ) : TextButton.icon(
                    onPressed: () async {
                      if(isDesktop){
                        showGeneralDialog(context: context, pageBuilder: (_,__,___) {
                          return SizedBox(
                            height: 300, width: 300,
                            child: PickMapScreen(fromSignUp: false, canRoute: false, fromAddAddress: false, route:'', onPicked: (AddressModel address) async {

                              ZoneResponseModel responseModel = await Get.find<LocationController>().getZone(address.latitude.toString(), address.longitude.toString(), false);

                              AddressModel a = AddressModel(
                                id: address.id, addressType: address.addressType, contactPersonNumber: address.contactPersonNumber, contactPersonName: address.contactPersonName,
                                address: address.address, latitude: address.latitude, longitude: address.longitude, zoneId: responseModel.isSuccess ? responseModel.zoneIds[0] : 0,
                                zoneIds: address.zoneIds, method: address.method, streetNumber: address.streetNumber, house: address.house, floor: address.floor,
                                zoneData: responseModel.zoneData,
                              );

                              print('----check----->>> ${parcelController.isPickedUp} // address: ${a.toJson()}');
                              if(parcelController.isPickedUp!) {
                                widget.senderAddressController.text = a.address ?? '';
                                parcelController.setPickupAddress(a, true);
                              }else {
                                widget.receiverAddressController.text = a.address ?? '';
                                parcelController.setDestinationAddress(a);
                              }
                            }),
                          );
                        });
                      }else{
                        Get.toNamed(RouteHelper.getPickMapRoute('parcel', false), arguments: PickMapScreen(
                          fromSignUp: false, fromAddAddress: false, canRoute: false, route: '', onPicked: (AddressModel address) async {

                          if(parcelController.isPickedUp!) {
                            ZoneResponseModel responseModel = await Get.find<LocationController>().getZone(address.latitude.toString(), address.longitude.toString(), false);
                            AddressModel pickupAddress = AddressModel(
                              id: address.id, addressType: address.addressType, contactPersonNumber: address.contactPersonNumber, contactPersonName: address.contactPersonName,
                              address: address.address, latitude: address.latitude, longitude: address.longitude, zoneId: responseModel.isSuccess ? responseModel.zoneIds[0] : 0,
                              zoneIds: responseModel.zoneIds, method: address.method, streetNumber: address.streetNumber, house: address.house, floor: address.floor,
                              zoneData: responseModel.zoneData,
                            );
                            parcelController.setPickupAddress(pickupAddress, true);
                            _setSenderAndReceiverAddress(isSender: widget.isSender, pickupAddress: parcelController.pickupAddress, destinationAddress: parcelController.destinationAddress);

                          }else {
                            ZoneResponseModel responseModel = await Get.find<LocationController>().getZone(address.latitude.toString(), address.longitude.toString(), false);
                            AddressModel a = AddressModel(
                              id: address.id, addressType: address.addressType, contactPersonNumber: address.contactPersonNumber, contactPersonName: address.contactPersonName,
                              address: address.address, latitude: address.latitude, longitude: address.longitude, zoneId: responseModel.isSuccess ? responseModel.zoneIds[0] : 0,
                              zoneIds: responseModel.zoneIds, method: address.method, streetNumber: address.streetNumber, house: address.house, floor: address.floor,
                              zoneData: responseModel.zoneData,
                            );
                            parcelController.setDestinationAddress(a);
                            _setSenderAndReceiverAddress(isSender: widget.isSender, pickupAddress: parcelController.pickupAddress, destinationAddress: parcelController.destinationAddress);

                          }
                        },
                        ));
                      }


                    },
                    icon: const Icon(Icons.location_on, size: 20),
                    label: Text('select_from_map'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                  ),
                ]),
                SizedBox(height: addressController.addressList != null && addressController.addressList!.isNotEmpty ? Dimensions.paddingSizeDefault : 0),

                // CustomTextField(
                //   titleText: 'address'.tr,
                //   labelText: 'address'.tr,
                //   focusNode: addressNode,
                //   nextFocus: streetNode,
                //   controller: parcelController.isSender ? widget.senderAddressController : widget.receiverAddressController,
                //   required: true,
                // ),
                // const SizedBox(height: Dimensions.paddingSizeLarge),

                Builder(
                  builder: (context) {
                    bool emptyText = parcelController.isSender
                        ? widget.senderAddressController.text.isEmpty
                        : widget.receiverAddressController.text.isEmpty;

                    return TypeAheadField(
                      hideOnEmpty: true,
                      controller: parcelController.isSender ? widget.senderAddressController : widget.receiverAddressController,
                      builder: (context, controller, focusNode) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          onSubmitted: (text) => FocusScope.of(context).requestFocus(streetNode),
                          textInputAction: TextInputAction.search,
                          textCapitalization: TextCapitalization.words,
                          keyboardType: TextInputType.streetAddress,
                          decoration: InputDecoration(
                            hintText: parcelController.isSender ?'sender_address'.tr : 'receiver_address'.tr,
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
                                if(!emptyText) {
                                  controller.clear();
                                  if(parcelController.isSender) {
                                    widget.senderAddressController.text = '';
                                    parcelController.setPickupAddress(null, true);
                                  } else {
                                    widget.receiverAddressController.text = '';
                                    parcelController.setDestinationAddress(null, notify: true);
                                  }
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
                                if(parcelController.isSender) {
                                  widget.senderAddressController.text = address.address ?? '';
                                  parcelController.setPickupAddress(modifiedAddress, true);
                                } else {
                                  widget.receiverAddressController.text = address.address ?? '';
                                  parcelController.setDestinationAddress(modifiedAddress, notify: true);
                                }
                                Get.back();
                              },
                              icon: Icon(!emptyText ? Icons.clear : Icons.my_location, color: !emptyText ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).primaryColor),
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
                        if(parcelController.isSender) {
                          widget.senderAddressController.text = suggestion.description ?? '';
                          parcelController.setPickupAddress(modifiedAddress, true);
                          if(widget.senderAddressController.text.isNotEmpty) {
                            FocusScope.of(Get.context!).requestFocus(streetNode);
                          }
                        } else {
                          widget.receiverAddressController.text = suggestion.description ?? '';
                          parcelController.setDestinationAddress(modifiedAddress, notify: true);
                          if(widget.receiverAddressController.text.isNotEmpty) {
                            FocusScope.of(Get.context!).requestFocus(streetNode);
                          }
                        }
                      },

                      errorBuilder : (_,value) {
                        return const SizedBox();
                      },
                    );
                  }
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                !isDesktop ? CustomTextField(
                  titleText: 'street_number'.tr,
                  labelText: 'street_number'.tr,
                  inputType: TextInputType.streetAddress,
                  focusNode: streetNode,
                  nextFocus: houseNode,
                  controller: widget.streetController,
                ) : const SizedBox(),
                SizedBox(height: !isDesktop ? Dimensions.paddingSizeLarge : 0),

                Row(
                  children: [
                    isDesktop ? Expanded(
                      child: CustomTextField(
                        labelText: 'street_number'.tr,
                        titleText: 'street_number'.tr,
                        inputType: TextInputType.streetAddress,
                        focusNode: streetNode,
                        nextFocus: houseNode,
                        controller: widget.streetController,
                      ),
                    ) : const SizedBox(),
                    SizedBox(width: isDesktop ? Dimensions.paddingSizeSmall : 0),

                    Expanded(
                      child: CustomTextField(
                        labelText: 'house'.tr,
                        titleText: 'house'.tr,
                        inputType: TextInputType.text,
                        focusNode: houseNode,
                        nextFocus: floorNode,
                        controller: widget.houseController,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(
                      child: CustomTextField(
                        labelText: 'floor'.tr,
                        titleText: 'floor'.tr,
                        inputType: TextInputType.text,
                        focusNode: floorNode,
                        nextFocus: nameNode,
                        controller: widget.floorController,
                      ),
                    ),
                  ],
                ),
              ]),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            CustomCard(
              borderRadius: isDesktop ? Dimensions.radiusDefault : 0,
              isBorder: false,
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: !isDesktop ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Text(parcelController.isSender ? 'sender_information'.tr : 'receiver_information'.tr, style: robotoMedium),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                CustomTextField(
                  labelText: parcelController.isSender ? 'sender_name'.tr : 'receiver_name'.tr,
                  titleText: parcelController.isSender ? 'sender_name'.tr : 'receiver_name'.tr,
                  inputType: TextInputType.name,
                  focusNode: nameNode,
                  nextFocus: phoneNode,
                  controller: widget.nameController,
                  required: true,
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                CustomTextField(
                  titleText: parcelController.isSender ? 'sender_phone_number'.tr : 'receiver_phone_number'.tr,
                  labelText: parcelController.isSender ? 'sender_phone_number'.tr : 'receiver_phone_number'.tr,
                  controller: widget.phoneController,
                  focusNode: phoneNode,
                  inputType: TextInputType.phone,
                  inputAction: AuthHelper.isGuestLoggedIn() ? TextInputAction.next : TextInputAction.done,
                  nextFocus: AuthHelper.isGuestLoggedIn() ? guestEmailNode : null,
                  isPhone: true,
                  required: true,
                  onCountryChanged: (CountryCode countryCode) {
                    countryDialCode = countryCode.dialCode;
                    parcelController.setCountryCode(countryDialCode!, parcelController.isSender);
                  },
                  countryDialCode: countryDialCode ?? _countryCode,
                ),
                SizedBox(height: AuthHelper.isGuestLoggedIn() ? Dimensions.paddingSizeLarge : 0),

                AuthHelper.isGuestLoggedIn() ? CustomTextField(
                  titleText: parcelController.isSender ? 'sender_email'.tr : 'receiver_email'.tr,
                  labelText: parcelController.isSender ? 'sender_email'.tr : 'receiver_email'.tr,
                  controller: widget.guestEmailController,
                  inputType: TextInputType.emailAddress,
                  focusNode: guestEmailNode,
                  required: parcelController.isSender,
                  prefixImage: Images.mail,
                  inputAction: TextInputAction.done,
                ) : const SizedBox(),

              ]) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Text(parcelController.isSender ? 'sender_information'.tr : 'receiver_information'.tr, style: robotoMedium),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Row(children: [
                  Expanded(child: CustomTextField(
                    labelText: parcelController.isSender ? 'sender_name'.tr : 'receiver_name'.tr,
                    titleText: parcelController.isSender ? 'sender_name'.tr : 'receiver_name'.tr,
                    inputType: TextInputType.name,
                    focusNode: nameNode,
                    nextFocus: phoneNode,
                    controller: widget.nameController,
                    required: true,
                  )),
                  SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(child: CustomTextField(
                    titleText: parcelController.isSender ? 'sender_phone_number'.tr : 'receiver_phone_number'.tr,
                    labelText: parcelController.isSender ? 'sender_phone_number'.tr : 'receiver_phone_number'.tr,
                    controller: widget.phoneController,
                    focusNode: phoneNode,
                    inputType: TextInputType.phone,
                    inputAction: AuthHelper.isGuestLoggedIn() ? TextInputAction.next : TextInputAction.done,
                    nextFocus: AuthHelper.isGuestLoggedIn() ? guestEmailNode : null,
                    isPhone: true,
                    required: true,
                    onCountryChanged: (CountryCode countryCode) {
                      countryDialCode = countryCode.dialCode;
                      parcelController.setCountryCode(countryDialCode!, parcelController.isSender);
                    },
                    countryDialCode: countryDialCode ?? _countryCode,
                  )),

                ]),

                SizedBox(height: AuthHelper.isGuestLoggedIn() ? Dimensions.paddingSizeLarge : 0),

                AuthHelper.isGuestLoggedIn() ? CustomTextField(
                  titleText: parcelController.isSender ? 'sender_email'.tr : 'receiver_email'.tr,
                  labelText: parcelController.isSender ? 'sender_email'.tr : 'receiver_email'.tr,
                  controller: widget.guestEmailController,
                  inputType: TextInputType.emailAddress,
                  focusNode: guestEmailNode,
                  required: parcelController.isSender,
                  prefixImage: Images.mail,
                  inputAction: TextInputAction.done,
                ) : const SizedBox(),

              ]),
            ),

            ResponsiveHelper.isDesktop(context) ? Padding(
              padding: EdgeInsets.symmetric(vertical: Dimensions.fontSizeSmall),
              child: widget.bottomButton,
            ) : const SizedBox(),

          ]),
        )),
        );
      });
    }));
  }

  void _setSenderAndReceiverAddress({required bool isSender, required AddressModel? pickupAddress, required AddressModel? destinationAddress}) {
    AddressModel? userAddressFromSharedPref = AddressHelper.getUserAddressFromSharedPref();

    if(isSender){
      widget.senderAddressController.text = pickupAddress?.address ?? (userAddressFromSharedPref?.address ?? '');
    }else{
      widget.receiverAddressController.text = destinationAddress?.address ?? (userAddressFromSharedPref?.address ?? '');
    }
  }
}
