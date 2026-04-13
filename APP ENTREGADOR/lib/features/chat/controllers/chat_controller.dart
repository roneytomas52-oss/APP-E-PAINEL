import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart_delivery/api/api_client.dart';
import 'package:sixam_mart_delivery/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart_delivery/features/chat/domain/models/conversation_model.dart';
import 'package:sixam_mart_delivery/features/chat/domain/models/message_model.dart';
import 'package:sixam_mart_delivery/features/chat/domain/services/chat_service_interface.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/splash/controllers/splash_controller.dart';

import '../../../common/widgets/custom_snackbar_widget.dart';
import '../../../helper/date_converter_helper.dart';
import '../../../helper/responsive_helper.dart';

class ChatController extends GetxController implements GetxService {
  final ChatServiceInterface chatServiceInterface;
  ChatController({required this.chatServiceInterface});

  List<bool>? _showDate;
  List<bool>? get showDate => _showDate;

  List<XFile>? _imageFiles;
  List<XFile>? get imageFiles => _imageFiles;

  bool _isSendButtonActive = false;
  bool get isSendButtonActive => _isSendButtonActive;

  final bool _isSeen = false;
  bool get isSeen => _isSeen;

  final bool _isSend = true;
  bool get isSend => _isSend;

  final bool _isMe = false;
  bool get isMe => _isMe;

  bool _isLoading= false;
  bool get isLoading => _isLoading;

  List <XFile>?_chatImage = [];
  List<XFile>? get chatImage => _chatImage;

  int? _pageSize;
  int? get pageSize => _pageSize;

  int? _offset;
  int? get offset => _offset;

  bool _isEmojiPickerVisible = false;
  bool get isEmojiPickerVisible => _isEmojiPickerVisible;

  ConversationsModel? _conversationModel ;
  ConversationsModel? get conversationModel => _conversationModel;

  ConversationsModel? _searchConversationModel;
  ConversationsModel? get searchConversationModel => _searchConversationModel;

  MessageModel? _messageModel;
  MessageModel? get messageModel => _messageModel;

  XFile? _pickedVideoFile;
  XFile? get pickedVideoFile => _pickedVideoFile;

  PlatformFile? _pickedWebVideoFile ;
  PlatformFile? get pickedWebVideoFile => _pickedWebVideoFile;

  String _type = 'customer';
  String get type => _type;

  bool _clickTab = false;
  bool get clickTab => _clickTab;

  List<XFile>? _objFile = [];
  List<XFile>? get objFile => _objFile;

  List<PlatformFile>? _objWebFile = [];
  List<PlatformFile>? get objWebFile => _objWebFile;

  double _videoSize = 0.0;
  double get videoSize => _videoSize;

  List<double> _fileSizeList = [];
  List<double> get fileSizeList => _fileSizeList;

  bool _singleFIleCrossMaxLimit = false;
  bool get singleFIleCrossMaxLimit => _singleFIleCrossMaxLimit;

  bool showFaqQuestions = false;

  void updateShowFaq(bool action, {bool isUpdate = false}){
    showFaqQuestions = action;
    if(isUpdate){
      update();
    }
  }

  Future<void> getConversationList(int offset, {String type = ''}) async{
    _searchConversationModel = null;
    _conversationModel = null;
    ConversationsModel? conversationModel = await chatServiceInterface.getConversationList(offset, type);
    if(conversationModel != null) {
      if(offset == 1) {
        _conversationModel = conversationModel;
      }else {
        _conversationModel!.totalSize = conversationModel.totalSize;
        _conversationModel!.offset = conversationModel.offset;
        _conversationModel!.conversations!.addAll(conversationModel.conversations!);
      }
    }
    update();
  }

  Future<void> searchConversation(String name, {String type = ''}) async {
    _searchConversationModel = ConversationsModel();
    update();
    ConversationsModel? searchConversationModel = await chatServiceInterface.searchConversationList(name, type);
    if(searchConversationModel != null) {
      _searchConversationModel = searchConversationModel;
    }
    update();
  }

  void removeSearchMode() {
    _searchConversationModel = null;
    update();
  }

  Future<void> getMessages(int offset, NotificationBodyModel notificationBody, User? user, int? conversationID, {bool firstLoad = false}) async {
    if(firstLoad) {
      _messageModel = null;
    }

    MessageModel? messageModel = await chatServiceInterface.processGetMessage(offset, notificationBody, conversationID);

    if (messageModel != null) {
      if (offset == 1) {
        if(Get.find<ProfileController>().profileModel == null || Get.find<ProfileController>().profileModel?.userinfo == null) {
          await Get.find<ProfileController>().getProfile();
        }
        _messageModel = messageModel;
        if(_messageModel!.conversation == null && user != null) {
          _messageModel!.conversation = Conversation(sender: User(
            id: Get.find<ProfileController>().profileModel!.id, imageFullUrl: Get.find<ProfileController>().profileModel!.imageFullUrl,
            fName: Get.find<ProfileController>().profileModel!.fName, lName: Get.find<ProfileController>().profileModel!.lName,
          ), receiver: user);
        }else if(_messageModel!.conversation != null && _messageModel!.conversation!.receiverType == 'delivery_man') {
          User? receiver = _messageModel!.conversation!.receiver;
          _messageModel!.conversation!.receiver = _messageModel!.conversation!.sender;
          _messageModel!.conversation!.sender = receiver;
        }else if(_messageModel!.conversation != null && _messageModel!.conversation!.receiverType == 'admin') {
          User? receiver = User(
            id: 0, fName: Get.find<SplashController>().configModel!.businessName, lName: '',
            imageFullUrl: Get.find<SplashController>().configModel!.logo,
            phone: Get.find<SplashController>().configModel!.phone
          );
          _messageModel!.conversation!.receiver = receiver;
        }
      }else {
        _messageModel!.totalSize = messageModel.totalSize;
        _messageModel!.offset = messageModel.offset;
        _messageModel!.messages!.addAll(messageModel.messages!);
      }
    }
    _isLoading = false;
    update();

  }

  Future<bool> sendMessage({required String message, required NotificationBodyModel? notificationBody, required int? conversationId, bool fromFaq = false}) async {
    bool isSuccess = false;
    _isLoading = true;
    update();

    List<MultipartBody> allFiles = [];

    if(_chatImage != null && _chatImage!.isNotEmpty) {
      allFiles.addAll(chatServiceInterface.processMultipartBody(_chatImage!));
    }

    if(_objFile != null && _objFile!.isNotEmpty) {
      allFiles.addAll(chatServiceInterface.processMultipartFiles(_objFile!));
    }

    if(_pickedVideoFile != null) {
      allFiles.addAll(chatServiceInterface.processMultipartVideo(_pickedVideoFile));
    }
    MessageModel? messageModel;

    if(!fromFaq){
      messageModel = await chatServiceInterface.processSendMessage(notificationBody, allFiles, message, conversationId);
    }else{
      messageModel = await chatServiceInterface.sendFaqMessage(questionId: message);
    }



    if (messageModel != null) {
      _imageFiles = [];
      _chatImage = [];
      _objFile = [];
      _objWebFile = [];
      _pickedVideoFile = null;
      _pickedWebVideoFile = null;
      _videoSize = 0;
      _fileSizeList = [];
      _isSendButtonActive = false;
      _isLoading = false;
      _messageModel = messageModel;

      if(_messageModel!.conversation != null && _messageModel!.conversation!.receiverType == 'delivery_man') {
        User? receiver = _messageModel!.conversation!.receiver;
        _messageModel!.conversation!.receiver = _messageModel!.conversation!.sender;
        _messageModel!.conversation!.sender = receiver;
      }
      else if(_messageModel!.conversation != null && _messageModel!.conversation!.receiverType == 'admin') {
        User? receiver = User(
          id: 0, fName: Get.find<SplashController>().configModel!.businessName, lName: '',
          imageFullUrl: Get.find<SplashController>().configModel!.logo,
          phone: Get.find<SplashController>().configModel!.phone
        );
        _messageModel!.conversation!.receiver = receiver;
      }
      isSuccess = true;
    }
    update();
    return isSuccess;
  }

  void pickImage(bool isRemove) async {
    final ImagePicker picker = ImagePicker();
    if(isRemove) {
      _imageFiles = [];
      _chatImage = [];
    }else {
      _imageFiles = await picker.pickMultiImage(imageQuality: 30);
      if (_imageFiles != null) {
        _chatImage = imageFiles;
        _isSendButtonActive = true;
      }
    }
    update();
  }
  void removeImage(int index){
    chatImage!.removeAt(index);
    update();
  }

  void toggleSendButtonActivity() {
    _isSendButtonActive = !_isSendButtonActive;
    update();
  }

  String getChatTime(String todayChatTimeInUtc, String? nextChatTimeInUtc) {
    String chatTime = '';
    DateTime todayConversationDateTime = DateConverterHelper.isoUtcStringToLocalTimeOnly(todayChatTimeInUtc);
    try{
      todayConversationDateTime = DateConverterHelper.isoUtcStringToLocalTimeOnly(todayChatTimeInUtc);
    }catch(e) {
      todayConversationDateTime = DateConverterHelper.dateTimeStringToDate(todayChatTimeInUtc);
    }

    DateTime nextConversationDateTime;
    DateTime currentDate = DateTime.now();

    if(nextChatTimeInUtc == null){
      return chatTime = DateConverterHelper.isoStringToLocalDateAndTime(todayChatTimeInUtc);
    }else{
      nextConversationDateTime = DateConverterHelper.isoUtcStringToLocalTimeOnly(nextChatTimeInUtc);

      if(todayConversationDateTime.difference(nextConversationDateTime) < const Duration(minutes: 30) &&
          todayConversationDateTime.weekday == nextConversationDateTime.weekday){
        chatTime = '';
      }else if(currentDate.weekday != todayConversationDateTime.weekday
          && DateConverterHelper.countDays(todayConversationDateTime) < 6){
        if( (currentDate.weekday -1 == 0 ? 7 : currentDate.weekday -1) == todayConversationDateTime.weekday){
          chatTime = DateConverterHelper.convert24HourTimeTo12HourTimeWithDay(todayConversationDateTime, false);
        }else{
          chatTime = DateConverterHelper.convertStringTimeToDateTime(todayConversationDateTime);
        }

      }else if(currentDate.weekday == todayConversationDateTime.weekday
          && DateConverterHelper.countDays(todayConversationDateTime) < 6){
        chatTime = DateConverterHelper.convert24HourTimeTo12HourTimeWithDay(todayConversationDateTime, true);
      }else{
        chatTime = DateConverterHelper.isoStringToLocalDateAndTime(todayChatTimeInUtc);
      }
    }
    return chatTime;
  }

  String getChatTimeWithPrevious (Message currentChat, Message? previousChat) {
    DateTime todayConversationDateTime = DateConverterHelper.isoUtcStringToLocalTimeOnly(currentChat.createdAt ?? "");

    DateTime previousConversationDateTime;

    if(previousChat?.createdAt == null) {
      return 'Not-Same';
    } else {
      previousConversationDateTime = DateConverterHelper.isoUtcStringToLocalTimeOnly(previousChat!.createdAt!);

      if(previousConversationDateTime.difference(todayConversationDateTime) < const Duration(minutes: 30) &&
          todayConversationDateTime.weekday == previousConversationDateTime.weekday && _isSameUserWithPreviousMessage(currentChat, previousChat)) {
        return '';
      } else {
        return 'Not-Same';
      }
    }
  }

  bool _isSameUserWithPreviousMessage(Message? previousConversation, Message? currentConversation){
    if(previousConversation?.senderId == currentConversation?.senderId && previousConversation?.message != null && currentConversation?.message !=null){
      return true;
    }
    return false;
  }

  void toggleEmojiPicker() {
    _isEmojiPickerVisible = !_isEmojiPickerVisible;
    update();
  }

  void setType(String type, {bool willUpdate = true}) {
    _type = type;
    if(willUpdate) {
      update();
    }
  }

  void setTabSelect() {
    _clickTab = !_clickTab;
  }

  void pickFile(bool isRemove, {int? index}) async {
    if(isRemove) {
      if(index != null) {
        if(ResponsiveHelper.isWeb()) {
          _objWebFile!.removeAt(index);
          _fileSizeList.removeAt(index);
        } else {
          _objFile!.removeAt(index);
          _fileSizeList.removeAt(index);
        }
      } else {
        _objFile = [];
        _objWebFile = [];
        _fileSizeList = [];
      }
    } else {
      if(ResponsiveHelper.isWeb()) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
        );
        if (result != null && result.files.isNotEmpty) {
          for (var file in result.files) {
            double fileSize = (file.size / (1024 * 1024));
            if(fileSize <= 2) {
              _objWebFile!.add(file);
              _fileSizeList.add(fileSize);
            } else {
              showCustomSnackBar('file_size_too_large'.tr);
            }
          }
          _isSendButtonActive = true;
        }
      } else {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
        );
        if (result != null && result.files.isNotEmpty) {
          for (var file in result.files) {
            File selectedFile = File(file.path!);
            double fileSize = (await selectedFile.length()) / (1024 * 1024);
            if(fileSize <= 2) {
              _objFile!.add(XFile(file.path!));
              _fileSizeList.add(fileSize);
            } else {
              showCustomSnackBar('file_size_too_large'.tr);
            }
          }
          _isSendButtonActive = true;
        }
      }
    }
    update();
  }

  void pickVideoFile(bool isRemove) async {
    if(isRemove) {
      _pickedVideoFile = null;
      _pickedWebVideoFile = null;
      _videoSize = 0;
    } else {
      if(ResponsiveHelper.isWeb()) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.video,
        );
        if (result != null && result.files.isNotEmpty) {
          PlatformFile file = result.files.first;
          double fileSize = (file.size / (1024 * 1024));
          if(fileSize <= 2) {
            _pickedWebVideoFile = file;
            _videoSize = fileSize;
            _isSendButtonActive = true;
          } else {
            showCustomSnackBar('video_size_too_large'.tr);
          }
        }
      } else {
        final ImagePicker picker = ImagePicker();
        XFile? video = await picker.pickVideo(source: ImageSource.gallery);
        if (video != null) {
          File videoFile = File(video.path);
          double fileSize = (await videoFile.length()) / (1024 * 1024);
          if(fileSize <= 2) {
            _pickedVideoFile = video;
            _videoSize = fileSize;
            _isSendButtonActive = true;
          } else {
            showCustomSnackBar('video_size_too_large'.tr);
          }
        }
      }
    }
    update();
  }
}