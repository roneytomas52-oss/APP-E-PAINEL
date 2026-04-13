import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/widgets/camera_button_sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeliveryConfirmationSection extends StatelessWidget {
  const DeliveryConfirmationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(builder: (orderController) {
      return Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('completed_after_delivery_picture'.tr, style: robotoBold),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          _buildImagePickerList(context, orderController),
        ]),
      );
    });
  }

  Widget _buildImagePickerList(BuildContext context, OrderController orderController) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: orderController.pickedPrescriptions.length + 1,
        itemBuilder: (context, index) {
          final isAddButton = index == orderController.pickedPrescriptions.length;

          if (isAddButton && index < 5) {
            return _buildAddImageButton(context);
          }

          final file = orderController.pickedPrescriptions[index];
          return _buildImagePreview(file);
        },
      ),
    );
  }

  Widget _buildAddImageButton(BuildContext context) {
    return InkWell(
      onTap: () {
        if (GetPlatform.isIOS) {
          Get.find<OrderController>().pickPrescriptionImage(isRemove: false, isCamera: false);
        } else {
          Get.bottomSheet(const CameraButtonSheetWidget());
        }
      },
      child: Container(
        height: 60, width: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
        ),
        child: Icon(
          CupertinoIcons.camera_fill,
          color: Theme.of(context).primaryColor,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildImagePreview(XFile? file) {
    if (file == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: Image.file(File(file.path), width: 60, height: 60, fit: BoxFit.cover),
      ),
    );
  }

}
