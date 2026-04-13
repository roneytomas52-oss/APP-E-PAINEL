import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/chat/domain/models/chat_model.dart';
import 'package:sixam_mart/features/chat/widgets/image_preview_widget.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/file_type_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageFileViewWidget extends StatefulWidget {
  final Message currentMessage;
  final bool isRightMessage;
  const ImageFileViewWidget({super.key, required this.currentMessage, required this.isRightMessage});

  @override
  State<ImageFileViewWidget> createState() => _ImageFileViewWidgetState();
}

class _ImageFileViewWidgetState extends State<ImageFileViewWidget> {

  Future<void> _openFile(String fileUrl, FileType fileType, int index) async {
    if (fileType == FileType.pdf) {
      final uri = Uri.parse(fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not open PDF file',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else if (fileType == FileType.image || fileType == FileType.video) {
      if (ResponsiveHelper.isDesktop(context)) {
        Get.dialog(
          Dialog(
            insetPadding: EdgeInsets.zero,
            child: ImagePreviewWidget(currentMessage: widget.currentMessage, currentIndex: index),
          ),
        );
      } else {
        Get.to(() => ImagePreviewWidget(currentMessage: widget.currentMessage, currentIndex: index));
      }
    } else {
      final uri = Uri.parse(fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not open file',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Widget _buildFilePreview(String fileUrl, FileType fileType) {
    switch (fileType) {
      case FileType.pdf:
        return Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.picture_as_pdf, size: 34, color: Theme.of(context).disabledColor),
            const SizedBox(height: 4),
            Text('PDF',
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
            ),
          ]),
        );
      case FileType.video:
        return Stack(alignment: Alignment.center, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            child: Container(color: Colors.black12,
              child: Icon(Icons.videocam, size: 50, color: Colors.white70),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
            child: Icon(Icons.play_arrow, size: 30, color: Colors.white),
          ),
        ]);
      case FileType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          child: CustomImage(image: fileUrl, fit: BoxFit.cover, height: double.infinity, width: double.infinity),
        );
      case FileType.other:
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.insert_drive_file, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(height: 4),
            Text(
              FileTypeHelper.getFileExtension(fileUrl),
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ]),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.currentMessage.fileFullUrl!.length > 3 ? 4 : widget.currentMessage.fileFullUrl!.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: Dimensions.paddingSizeSmall,
        crossAxisSpacing: Dimensions.paddingSizeSmall,
      ),
      itemBuilder: (context, index) {
        final fileUrl = widget.currentMessage.fileFullUrl![index];
        final fileType = FileTypeHelper.getFileType(fileUrl);

        return InkWell(
          onTap: () => _openFile(fileUrl, fileType, index),
          child: Stack(
            children: [
              Hero(
                tag: widget.currentMessage.fileFullUrl![index],
                child: _buildFilePreview(fileUrl, fileType),
              ),

              if((widget.isRightMessage ? index == 2 : index == 4) && widget.currentMessage.fileFullUrl!.length > 3 && widget.currentMessage.fileFullUrl!.length != 4)
              InkWell(
                onTap: () {
                  if(ResponsiveHelper.isDesktop(context)){
                    Get.dialog(
                      Dialog(
                        insetPadding: EdgeInsets.zero,
                        child: ImagePreviewWidget(currentMessage: widget.currentMessage, currentIndex: index),
                      ),
                    );
                  }else{
                    Get.to(() => ImagePreviewWidget(currentMessage: widget.currentMessage, currentIndex: index));
                  }
                },
                child: Container(
                  height: double.infinity, width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${widget.currentMessage.fileFullUrl!.length - 4} +',
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).cardColor),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
