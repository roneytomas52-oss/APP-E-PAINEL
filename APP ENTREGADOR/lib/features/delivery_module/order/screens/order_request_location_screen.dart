import 'dart:collection';
import 'dart:math';
import 'dart:ui';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/order_model.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/widgets/request_location_card_widget.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';


class OrderRequestLocationScreen extends StatefulWidget {
  final OrderModel orderModel;
  final OrderController orderController;
  const OrderRequestLocationScreen({super.key, required this.orderModel, required this.orderController});

  @override
  State<OrderRequestLocationScreen> createState() => _OrderRequestLocationScreenState();
}

class _OrderRequestLocationScreenState extends State<OrderRequestLocationScreen> {
  GoogleMapController? _controller;
  final Set<Marker> _markers = HashSet<Marker>();
  GlobalKey<ExpandableBottomSheetState> key = GlobalKey<ExpandableBottomSheetState>();

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 600), () {
      key.currentState?.expand();
    });
  }

  @override
  Widget build(BuildContext context) {

    bool parcel = widget.orderModel.orderType == 'parcel';

    return Scaffold(

      appBar: CustomAppBarWidget(
        title: 'new_order_request'.tr,
        subtitle: '${'order_id'.tr}: #${widget.orderModel.id}',
      ),

      body: SafeArea(
        child: ExpandableBottomSheet(
          key: key,
          background: Stack(children: [

            GoogleMap(
              initialCameraPosition: CameraPosition(target: LatLng(
                double.parse(widget.orderModel.deliveryAddress?.latitude ?? '0'), double.parse(widget.orderModel.deliveryAddress?.longitude ?? '0'),
              ), zoom: 16),
              minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
              zoomControlsEnabled: false,
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
                setMarker(widget.orderModel, parcel);
              },
            ),

            // Positioned(
            //   bottom: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
            //   child: LocationCardWidget(
            //     orderModel: widget.orderModel, orderController: widget.orderController,
            //     onTap: widget.onTap, index: widget.index,
            //   ),
            // ),

          ]),
          persistentContentHeight: 100,
          expandableContent: RequestLocationCardWidget(
            orderModel: widget.orderModel, orderController: widget.orderController,
          ),
        ),
      ),

    );
  }

  void setMarker(OrderModel orderModel, bool parcel) async {
    try {
      Uint8List destinationImageData = await convertAssetToUnit8List(Images.customerMarker, width: 100);
      Uint8List restaurantImageData = await convertAssetToUnit8List(parcel ? Images.userMarker : Images.restaurantMarker, width: parcel ? 70 : 100);
      Uint8List deliveryBoyImageData = await convertAssetToUnit8List(Images.yourMarker, width: 100);

      LatLngBounds? bounds;
      if (_controller != null) {
        double deliveryLat = double.parse(orderModel.deliveryAddress?.latitude ?? '0');
        double deliveryLng = double.parse(orderModel.deliveryAddress?.longitude ?? '0');
        double storeLat = double.parse(orderModel.storeLat ?? '0');
        double storeLng = double.parse(orderModel.storeLng ?? '0');
        double receiverLat = double.parse(orderModel.receiverDetails?.latitude ?? '0');
        double receiverLng = double.parse(orderModel.receiverDetails?.longitude ?? '0');
        double deliveryManLat = Get.find<ProfileController>().recordLocationBody?.latitude ?? 0;
        double deliveryManLng = Get.find<ProfileController>().recordLocationBody?.longitude ?? 0;

        // Determine bounds based on locations
        if (parcel) {
          bounds = LatLngBounds(
            southwest: LatLng(
              min(deliveryLat, min(receiverLat, deliveryManLat)),
              min(deliveryLng, min(receiverLng, deliveryManLng)),
            ),
            northeast: LatLng(
              max(deliveryLat, max(receiverLat, deliveryManLat)),
              max(deliveryLng, max(receiverLng, deliveryManLng)),
            ),
          );
        } else {
          bounds = LatLngBounds(
            southwest: LatLng(
              min(deliveryLat, min(storeLat, deliveryManLat)),
              min(deliveryLng, min(storeLng, deliveryManLng)),
            ),
            northeast: LatLng(
              max(deliveryLat, max(storeLat, deliveryManLat)),
              max(deliveryLng, max(storeLng, deliveryManLng)),
            ),
          );
        }

        LatLng centerBounds = LatLng(
          (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
          (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
        );

        if (kDebugMode) {
          print('center bound $centerBounds');
        }

        // Zoom to fit bounds
        _controller!.moveCamera(CameraUpdate.newLatLngBounds(bounds, 50));

        // Clear previous markers
        _markers.clear();

        // Add destination marker (delivery address for normal, sender for parcel)
        if (orderModel.deliveryAddress != null) {
          _markers.add(Marker(
            markerId: const MarkerId('destination'),
            position: LatLng(deliveryLat, deliveryLng),
            infoWindow: InfoWindow(
              title: parcel ? 'Sender' : 'Destination',
              snippet: orderModel.deliveryAddress?.address,
            ),
            icon: BitmapDescriptor.bytes(destinationImageData, height: 40, width: 40),
          ));
        }

        // Add receiver marker for parcel order
        if (parcel && orderModel.receiverDetails != null) {
          _markers.add(Marker(
            markerId: const MarkerId('receiver'),
            position: LatLng(receiverLat, receiverLng),
            infoWindow: InfoWindow(
              title: 'Receiver',
              snippet: orderModel.receiverDetails?.address,
            ),
            icon: BitmapDescriptor.bytes(restaurantImageData, height: 40, width: 40),
          ));
        }

        // Add store marker for normal order
        if (!parcel && orderModel.storeLat != null && orderModel.storeLng != null) {
          _markers.add(Marker(
            markerId: const MarkerId('store'),
            position: LatLng(storeLat, storeLng),
            infoWindow: InfoWindow(
              title: orderModel.storeName,
              snippet: orderModel.storeAddress,
            ),
            icon: BitmapDescriptor.bytes(restaurantImageData, height: 40, width: 40),
          ));
        }

        // Add delivery boy marker
        if (Get.find<ProfileController>().recordLocationBody != null) {
          _markers.add(Marker(
            markerId: const MarkerId('delivery_boy'),
            position: LatLng(deliveryManLat, deliveryManLng),
            infoWindow: InfoWindow(
              title: 'delivery_man'.tr,
              snippet: Get.find<ProfileController>().recordLocationBody?.location,
            ),
            icon: BitmapDescriptor.bytes(deliveryBoyImageData, height: 40, width: 40),
          ));
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting markers: $e');
      }
    }
    setState(() {});
  }

  Future<Uint8List> convertAssetToUnit8List(String imagePath, {int width = 50}) async {
    ByteData data = await rootBundle.load(imagePath);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!.buffer.asUint8List();
  }
}
