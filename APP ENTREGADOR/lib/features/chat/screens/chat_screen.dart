import 'dart:io';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_delivery/features/chat/controllers/chat_controller.dart';
import 'package:sixam_mart_delivery/features/language/controllers/language_controller.dart';
import 'package:sixam_mart_delivery/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart_delivery/features/chat/domain/models/conversation_model.dart';
import 'package:sixam_mart_delivery/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_delivery/helper/responsive_helper.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/paginated_list_view_widget.dart';
import 'package:sixam_mart_delivery/features/chat/widgets/message_bubble_widget.dart';

import '../../../common/widgets/custom_asset_image_widget.dart';

class ChatScreen extends StatefulWidget {
  final NotificationBodyModel? notificationBody;
  final User? user;
  final int? conversationId;
  final bool fromNotification;
  final bool? fromSupport;
  const ChatScreen({super.key, required this.notificationBody, required this.user, this.conversationId, this.fromNotification = false, this.fromSupport});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputMessageController = TextEditingController();
  late bool _isLoggedIn;
  final FocusNode _inputMessageFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    _isLoggedIn = Get.find<AuthController>().isLoggedIn();
    Get.find<ChatController>().getMessages(1, widget.notificationBody!, widget.user, widget.conversationId, firstLoad: true);

    if(widget.fromSupport!){
      Get.find<ChatController>().updateShowFaq(true);
    } else {
      Get.find<ChatController>().updateShowFaq(false);
    }

  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatController) {

      // String? baseUrl = '';
      // if(widget.notificationBody!.customerId != null || (widget.notificationBody!.conversationId != null && widget.notificationBody!.type == 'user')) {
      //   baseUrl = ImageType.customer_image_url.name;
      // }else {
      //   baseUrl = ImageType.store_image_url.name;
      // }

      bool showFaq = chatController.showFaqQuestions &&  chatController.messageModel != null
          && Get.find<SplashController>().configModel!.riderFaqs != null && Get.find<SplashController>().configModel!.riderFaqs!.isNotEmpty;

      return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) async{
          if(widget.fromNotification && !didPop) {
            Get.offAllNamed(RouteHelper.getInitialRoute());
          }else {
            return;
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: GestureDetector(onTap: () {
              if(widget.fromNotification){
                Get.offAllNamed(RouteHelper.getInitialRoute());
              }else{
                Get.back();
              }
            },
              child: const Icon(Icons.arrow_back_ios_rounded),
            ),
            title: Row(children: [
              Container(width: 40, height: 40, alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(width: 2,color: Theme.of(context).cardColor),
                  color: Theme.of(context).cardColor,
                ),
                child: ClipOval(child: CustomImageWidget(
                  image: '${chatController.messageModel != null ? chatController.messageModel!.conversation!.receiver!.imageFullUrl : ''}',
                  fit: BoxFit.cover, height: 40, width: 40,
                )),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  chatController.messageModel != null ? '${chatController.messageModel!.conversation!.receiver!.fName ?? ''}'
                      ' ${chatController.messageModel!.conversation!.receiver!.lName ?? ''}' : 'receiver_name'.tr,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
                Text(
                  chatController.messageModel != null ? '${chatController.messageModel!.conversation!.receiver!.phone ?? widget.user?.phone}' : '',
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                ),
              ]),
            ]),
            backgroundColor: Theme.of(context).cardColor,
            surfaceTintColor: Theme.of(context).cardColor,
            shadowColor: Theme.of(context).disabledColor.withValues(alpha: 0.5),
            elevation: 2,
          ),

          body: _isLoggedIn ? SafeArea(
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    Column(children: [

                      Expanded(child: chatController.messageModel != null ? chatController.messageModel!.messages!.isNotEmpty ? PaginatedListViewWidget(
                        scrollController: _scrollController,
                        totalSize: chatController.messageModel?.totalSize,
                        offset: chatController.messageModel?.offset,
                        showLoadingInUpper: true,
                        onPaginate: (int? offset) async => await chatController.getMessages(
                          offset!, widget.notificationBody!, widget.user, widget.conversationId,
                        ),
                        productView: Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            physics: ClampingScrollPhysics(),
                            //shrinkWrap: true,
                            reverse: true,
                            itemCount: chatController.messageModel!.messages!.length + (showFaq ? 1 : 0),
                            itemBuilder: (context, index) {
                              // index 0 in a reversed list appears at the bottom (above the input bar)
                              if (showFaq && index == 0) {
                                return Padding(
                                  padding: Get.find<LocalizationController>().isLtr
                                      ? EdgeInsets.only(right: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeSmall)
                                      : EdgeInsets.only(right: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeDefault),
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeExtraSmall),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.all(Radius.circular(Dimensions.paddingSizeSmall)),
                                      boxShadow: [BoxShadow(
                                        color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                                        spreadRadius: 2,
                                        blurRadius: 1,
                                      )],
                                    ),
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                          child: Text('faqs'.tr, style: robotoMedium),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            chatController.updateShowFaq(false, isUpdate: true);
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.all(5.0),
                                            child: Icon(Icons.cancel_outlined, size: 20),
                                          ),
                                        ),
                                      ]),
                                      ListView.separated(
                                        itemCount: Get.find<SplashController>().configModel?.riderFaqs?.length ?? 0,
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 15),
                                        itemBuilder: (context, faqIndex) {
                                          return InkWell(
                                            onTap: () {
                                              chatController.sendMessage(
                                                message: Get.find<SplashController>().configModel?.riderFaqs?[faqIndex].id?.toString() ?? '',
                                                notificationBody: null,
                                                conversationId: null,
                                                fromFaq: true,
                                              );
                                              chatController.updateShowFaq(false, isUpdate: true);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                                                borderRadius: BorderRadius.all(Radius.circular(Dimensions.paddingSizeSmall)),
                                              ),
                                              child: Text(Get.find<SplashController>().configModel?.riderFaqs?[faqIndex].question ?? ''),
                                            ),
                                          );
                                        },
                                        separatorBuilder: (context, index) {
                                          return const SizedBox(height: Dimensions.paddingSizeSmall);
                                        },
                                      ),
                                    ]),
                                  ),
                                );
                              }
                              final messageIndex = showFaq ? index - 1 : index;
                              return MessageBubbleWidget(
                                previousMessage: messageIndex == 0 ? null : chatController.messageModel?.messages?.elementAt(messageIndex-1),
                                message: chatController.messageModel!.messages![messageIndex],
                                nextMessage: messageIndex == (chatController.messageModel!.messages!.length - 1) ? null : chatController.messageModel?.messages?.elementAt(messageIndex+1),
                                user: chatController.messageModel!.conversation!.receiver,
                                sender: chatController.messageModel!.conversation!.sender,
                                userType: widget.notificationBody!.adminId != null ? AppConstants.admin : widget.notificationBody!.customerId != null || (widget.notificationBody!.conversationId != null && widget.notificationBody!.type == 'user')
                                    ? AppConstants.user : AppConstants.vendor,
                              );
                            },
                          ),
                        ),
                      ) : showFaq ? ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          physics: const ClampingScrollPhysics(),
                          itemCount: 1,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: Get.find<LocalizationController>().isLtr
                                  ? EdgeInsets.only(right: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeSmall)
                                  : EdgeInsets.only(right: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeDefault),
                              child: Container(
                                margin: EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeExtraSmall),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.all(Radius.circular(Dimensions.paddingSizeSmall)),
                                  boxShadow: [BoxShadow(
                                    color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                                    spreadRadius: 2,
                                    blurRadius: 1,
                                  )],
                                ),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                      child: Text('faqs'.tr, style: robotoMedium),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        chatController.updateShowFaq(false, isUpdate: true);
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Icon(Icons.cancel_outlined, size: 20),
                                      ),
                                    ),
                                  ]),
                                  ListView.separated(
                                    itemCount: Get.find<SplashController>().configModel?.riderFaqs?.length ?? 0,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 15),
                                    itemBuilder: (context, faqIndex) {
                                      return InkWell(
                                        onTap: () {
                                          chatController.sendMessage(
                                            message: Get.find<SplashController>().configModel?.riderFaqs?[faqIndex].id?.toString() ?? '',
                                            notificationBody: null,
                                            conversationId: null,
                                            fromFaq: true,
                                          );
                                          chatController.updateShowFaq(false, isUpdate: true);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                                            borderRadius: BorderRadius.all(Radius.circular(Dimensions.paddingSizeSmall)),
                                          ),
                                          child: Text(Get.find<SplashController>().configModel?.riderFaqs?[faqIndex].question ?? ''),
                                        ),
                                      );
                                    },
                                    separatorBuilder: (context, index) {
                                      return const SizedBox(height: Dimensions.paddingSizeSmall);
                                    },
                                  ),
                                ]),
                              ),
                            );
                          },
                        ) : const SizedBox() : const Center(child: CircularProgressIndicator())),
                      (chatController.messageModel != null && (chatController.messageModel!.status! || chatController.messageModel!.messages!.isEmpty)) ? Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                        ),
                        margin: EdgeInsets.zero,
                        padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                          // Images Preview
                          chatController.chatImage!.isNotEmpty ? SizedBox(height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: chatController.chatImage!.length,
                              itemBuilder: (BuildContext context, index){
                                return  chatController.chatImage!.isNotEmpty ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Stack(children: [

                                    Container(width: 100, height: 100,
                                      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault)),
                                        child: ResponsiveHelper.isWeb() ? Image.network(
                                          chatController.chatImage![index].path, width: 100, height: 100, fit: BoxFit.cover,
                                        ) : Image.file(
                                          File(chatController.chatImage![index].path), width: 100, height: 100, fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),

                                    Positioned(top:0, right:0,
                                      child: InkWell(
                                        onTap : () => chatController.removeImage(index),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault)),
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.all(4.0),
                                            child: Icon(Icons.clear, color: Colors.red, size: 15),
                                          ),
                                        ),
                                      ),
                                    )],
                                  ),
                                ) : const SizedBox();
                              },
                            ),
                          ) : const SizedBox(),

                          // Video Preview
                          (chatController.pickedVideoFile != null || chatController.pickedWebVideoFile != null) ? Container(
                            height: 60,
                            margin: const EdgeInsets.only(top: 8),
                            child: Stack(clipBehavior: Clip.none, children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                ),
                                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(Icons.video_library, size: 28, color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  Text(
                                    chatController.pickedVideoFile!.name.length > 15 ? '${chatController.pickedVideoFile!.name.substring(0, 15)}...' : chatController.pickedVideoFile!.name,
                                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  if(chatController.videoSize > 0)
                                    Text(
                                      '${chatController.videoSize.toStringAsFixed(2)} MB',
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor),
                                    )
                                ]),
                              ),
                              Positioned(top: -10, right: -10,
                                child: InkWell(
                                  onTap: () => chatController.pickVideoFile(true),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault)),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Icon(Icons.clear, color: Colors.red, size: 15),
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                          ) : const SizedBox(),

                          // Files Preview
                          (chatController.objFile!.isNotEmpty || chatController.objWebFile!.isNotEmpty) ? Container(
                            height: 60,
                            margin: const EdgeInsets.only(top: 8),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: ResponsiveHelper.isWeb() ? chatController.objWebFile?.length : chatController.objFile?.length,
                              itemBuilder: (BuildContext context, index) {
                                String fileName = '';
                                if (ResponsiveHelper.isWeb()) {
                                  fileName = chatController.objWebFile![index].name;
                                } else {
                                  fileName = chatController.objFile![index].name;
                                }

                                return Stack(clipBehavior: Clip.none, children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                                    ),
                                    padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                      Icon(
                                        fileName.endsWith('.pdf') ? Icons.picture_as_pdf : Icons.description,
                                        size: 28,
                                        color: Theme.of(context).disabledColor.withValues(alpha: 0.5),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        fileName.length > 15 ? '${fileName.substring(0, 15)}...' : fileName,
                                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                      if(chatController.fileSizeList.isNotEmpty && index < chatController.fileSizeList.length)
                                        Text(
                                          '${chatController.fileSizeList[index].toStringAsFixed(2)} MB',
                                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor),
                                        ),
                                    ]),
                                  ),
                                  Positioned(top: -10, right: -10,
                                    child: InkWell(
                                      onTap: () => chatController.pickFile(true, index: index),
                                      child: Container(
                                        decoration: const BoxDecoration(color: Colors.white,
                                          borderRadius: BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault)),
                                        ),
                                        child: const Padding(padding: EdgeInsets.all(4.0), child: Icon(Icons.clear, color: Colors.red, size: 15)),
                                      ),
                                    ),
                                  ),
                                ]);
                              },
                            ),
                          ) : const SizedBox(),

                          (chatController.isLoading && chatController.chatImage!.isNotEmpty)
                              ? Align(alignment: Alignment.centerRight, child: Padding(
                            padding: const EdgeInsets.only(right: Dimensions.paddingSizeLarge, top: Dimensions.paddingSizeExtraSmall),
                            child: Text(
                              '${'uploading'.tr} ${chatController.chatImage?.length} ${'images'.tr}',
                              style: robotoMedium.copyWith(color: Theme.of(context).hintColor),
                            ),
                          )) : const SizedBox(),

                          Row(children: [
                            Expanded(
                              child: Container(
                                height: 55,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                                    border: Border.all(width: 1, color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(children: [
                                    const SizedBox(width: Dimensions.paddingSizeDefault),
                                    //Emoji
                                    InkWell(
                                      onTap: () {
                                        _inputMessageFocus.unfocus();
                                        chatController.toggleEmojiPicker();
                                      },
                                      child: Icon(Icons.emoji_emotions_outlined, color: Theme.of(context).hintColor, size: 30),
                                    ),

                                    const SizedBox(width: Dimensions.paddingSizeDefault),
                                    // text editing button
                                    Expanded(
                                      child: TextField(
                                        inputFormatters: [LengthLimitingTextInputFormatter(Dimensions.messageInputLength)],
                                        controller: _inputMessageController,
                                        textCapitalization: TextCapitalization.sentences,
                                        style: robotoRegular,
                                        keyboardType: TextInputType.multiline,
                                        maxLines: null,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'type_here'.tr,
                                          hintStyle: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeLarge),
                                        ),
                                        onSubmitted: (String newText) {
                                          if(newText.trim().isNotEmpty && !Get.find<ChatController>().isSendButtonActive) {
                                            Get.find<ChatController>().toggleSendButtonActivity();
                                          }else if(newText.isEmpty && Get.find<ChatController>().isSendButtonActive) {
                                            Get.find<ChatController>().toggleSendButtonActivity();
                                          }
                                        },
                                        onChanged: (String newText) {
                                          if(newText.trim().isNotEmpty && !Get.find<ChatController>().isSendButtonActive) {
                                            Get.find<ChatController>().toggleSendButtonActivity();
                                          }else if(newText.isEmpty && Get.find<ChatController>().isSendButtonActive) {
                                            Get.find<ChatController>().toggleSendButtonActivity();
                                          }
                                        },
                                      ),
                                    ),

                                    //pick image button
                                    InkWell(
                                      onTap: () async {
                                        Get.find<ChatController>().pickImage(false);
                                      },
                                      child: Image.asset(Images.image, width: 25, height: 25, color: Theme.of(context).hintColor),
                                    ),

                                    MenuAnchor(
                                      builder: (BuildContext context, MenuController controller, Widget? child) {
                                        return InkWell(
                                          onTap: () async {
                                            FocusManager.instance.primaryFocus?.unfocus();
                                            _inputMessageFocus.unfocus();

                                            if (controller.isOpen) {
                                              controller.close();
                                            } else {
                                              controller.open();
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                                            child: CustomAssetImageWidget(image: Images.fileIcon, width: 25, height: 25, color: Theme.of(context).hintColor),
                                          ),
                                        );
                                      },
                                      menuChildren: List<MenuItemButton>.generate(2, (int index) => MenuItemButton(
                                        onPressed: () {
                                          if(index == 0) {
                                            Get.find<ChatController>().pickFile(false);
                                          } else {
                                            Get.find<ChatController>().pickVideoFile(false);
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Icon(index == 0 ? Icons.file_copy_outlined : Icons.video_collection_outlined, size: 18, color: Theme.of(context).primaryColor),
                                            const SizedBox(width: Dimensions.paddingSizeSmall),

                                            Text(index == 0 ? 'pick_files'.tr : 'pick_video'.tr, style: robotoMedium),
                                          ],
                                        ),
                                      ),
                                      ),
                                    ),

                                  ]),
                                ),
                            ),
                            SizedBox(width: Dimensions.paddingSizeDefault),
                            Container(height: 55, width: 55,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                                border: Border.all(width: 1, color: Theme.of(context).primaryColor.withValues(alpha: 0.2))
                              ),
                              child: GetBuilder<ChatController>(builder: (chatController) {
                                return !chatController.isLoading ? InkWell(
                                  onTap: () async {
                                    if(chatController.isSendButtonActive) {
                                      int totalAttachments = (chatController.chatImage?.length ?? 0) +
                                          (chatController.objFile?.length ?? 0) +
                                          (chatController.pickedVideoFile != null ? 1 : 0);

                                      if(totalAttachments > 3){
                                        showCustomSnackBar('you_do_not_send_more_then_3_photos'.tr);
                                      }else{
                                        chatController.sendMessage(
                                          message: _inputMessageController.text, notificationBody: widget.notificationBody, conversationId: widget.conversationId,
                                        ).then((success) {
                                          _inputMessageController.clear();
                                          if(success){
                                            WidgetsBinding.instance.addPostFrameCallback((_) {
                                              if (_scrollController.hasClients) {
                                                _scrollController.animateTo(
                                                  0.0,
                                                  duration: const Duration(milliseconds: 300),
                                                  curve: Curves.easeOut,
                                                );
                                              }
                                            });
                                            Future.delayed(const Duration(seconds: 2),() {
                                              chatController.getMessages(1, widget.notificationBody!, widget.user, widget.conversationId);
                                            });
                                          }
                                        });
                                      }

                                    }else{
                                      showCustomSnackBar('write_somethings'.tr);
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                    child: Image.asset(
                                      Images.send, width: 25, height: 25,
                                      color: chatController.isSendButtonActive ? Theme.of(context).primaryColor : Theme.of(context).hintColor,
                                    ),
                                  ),
                                ) : Padding(padding: EdgeInsets.all(Dimensions.paddingSizeSmall), child: const Center( child: CircularProgressIndicator())) ;
                              })
                            ),
                          ]),

                          if (chatController.isEmojiPickerVisible)
                            SizedBox(
                              height: 250,
                              child: EmojiPicker(
                                onEmojiSelected: (category, emoji) {
                                  if (!chatController.isSendButtonActive) {
                                    chatController.toggleSendButtonActivity();
                                  }
                                },
                                textEditingController: _inputMessageController,
                                config: Config(
                                  checkPlatformCompatibility: true,
                                  emojiViewConfig: EmojiViewConfig(
                                    emojiSizeMax: 28 * (foundation.defaultTargetPlatform == TargetPlatform.iOS ?  1.20 :  1.0),
                                  ),
                                  skinToneConfig: const SkinToneConfig(),
                                  categoryViewConfig: const CategoryViewConfig(),
                                  bottomActionBarConfig: const BottomActionBarConfig(),
                                  searchViewConfig: const SearchViewConfig(),
                                ),
                              ),
                            ),
                        ]),
                      ) : const SizedBox(),
                    ]),


                  ],
                ),
              ),
            ),
          ) : const Center(child: Text('Not Login')),
        ),
      );
    }
    );
  }
}
