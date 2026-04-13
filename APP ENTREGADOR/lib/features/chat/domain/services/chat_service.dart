import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart_delivery/api/api_client.dart';
import 'package:sixam_mart_delivery/features/chat/domain/models/conversation_model.dart';
import 'package:sixam_mart_delivery/features/chat/domain/models/message_model.dart';
import 'package:sixam_mart_delivery/features/chat/domain/repositories/chat_repository_interface.dart';
import 'package:sixam_mart_delivery/features/chat/domain/services/chat_service_interface.dart';
import 'package:sixam_mart_delivery/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';

class ChatService implements ChatServiceInterface {
  final ChatRepositoryInterface chatRepositoryInterface;
  ChatService({required this.chatRepositoryInterface});

  @override
  Future<ConversationsModel?> getConversationList(int offset, String type) async {
    return await chatRepositoryInterface.getConversationList(offset, type);
  }

  @override
  Future<ConversationsModel?> searchConversationList(String name, String type) async {
    return await chatRepositoryInterface.searchConversationList(name, type);
  }

  @override
  Future<MessageModel?> getMessages(int offset, int? userId, String userType, int? conversationID) async {
    return await chatRepositoryInterface.getMessages(offset, userId, userType, conversationID);
  }

  @override
  Future<MessageModel?> sendMessage(String message, List<MultipartBody> file, int? conversationId, int? userId, String userType) async {
    return await chatRepositoryInterface.sendMessage(message, file, conversationId, userId, userType);
  }

  @override
  Future<MessageModel?> processGetMessage(int offset, NotificationBodyModel notificationBody, int? conversationID) async {
    MessageModel? messageModel;
    if(notificationBody.customerId != null || notificationBody.type == AppConstants.user) {
      messageModel = await getMessages(offset, notificationBody.customerId, AppConstants.user, conversationID);
    }else if(notificationBody.vendorId != null || notificationBody.type == AppConstants.vendor) {
      messageModel = await getMessages(offset, notificationBody.vendorId, AppConstants.vendor, conversationID);
    }
    else if (notificationBody.adminId != null) {
      messageModel = await getMessages(offset, null, AppConstants.admin, null);
    }
    return messageModel;
  }

  @override
  List<MultipartBody> processMultipartBody(List<XFile> chatImage) {
    List<MultipartBody> multipartImages = [];
    for (var image in chatImage) {
      multipartImages.add(MultipartBody('image[]', image));
    }
    return multipartImages;
  }

  @override
  Future<MessageModel?> processSendMessage(NotificationBodyModel? notificationBody, List<MultipartBody> chatImage, String message, int? conversationId) async {
    MessageModel? messageModel;
    if(notificationBody != null && (notificationBody.customerId != null || notificationBody.type == AppConstants.user)) {
      messageModel = await sendMessage(message, chatImage, conversationId, notificationBody.customerId, AppConstants.customer);
    }else if(notificationBody != null && (notificationBody.vendorId != null || notificationBody.type == AppConstants.vendor)){
      messageModel = await sendMessage(message, chatImage, conversationId, notificationBody.vendorId, AppConstants.vendor);
    }
    else if(notificationBody != null && (notificationBody.adminId != null || notificationBody.type == AppConstants.admin)){
      messageModel = await sendMessage(message, chatImage, null, notificationBody.vendorId, AppConstants.admin);
    }
    return messageModel;
  }

  @override
  Future<MessageModel?> sendFaqMessage({String? questionId}) async {
    return await chatRepositoryInterface.sendFaqMessage(questionId: questionId);
  }

  @override
  List<MultipartBody> processMultipartFiles(List<XFile> files) {
    List<MultipartBody> multipartFiles = [];
    for (var file in files) {
      multipartFiles.add(MultipartBody('image[]', file));
    }
    return multipartFiles;
  }

  @override
  List<MultipartBody> processMultipartVideo(XFile? video) {
    List<MultipartBody> multipartVideo = [];
    if(video != null) {
      multipartVideo.add(MultipartBody('image[]', video));
    }
    return multipartVideo;
  }

}