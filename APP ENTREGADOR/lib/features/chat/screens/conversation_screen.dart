import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/chat/controllers/chat_controller.dart';
import 'package:sixam_mart_delivery/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart_delivery/features/chat/domain/models/conversation_model.dart';
import 'package:sixam_mart_delivery/helper/date_converter_helper.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/enums.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_ink_well_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/paginated_list_view_widget.dart';
import 'package:sixam_mart_delivery/features/chat/widgets/search_field_widget.dart';

import '../../auth/controllers/auth_controller.dart';
import '../../../common/widgets/sliver_delegate.dart';
import '../../profile/controllers/profile_controller.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> with TickerProviderStateMixin{
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  bool isRideActive = AppConstants.appMode == AppMode.ride;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initCall();
  }

  void _initCall() {
    if(Get.find<AuthController>().isLoggedIn()) {
      Get.find<ProfileController>().getProfile();
      Get.find<ChatController>().setType('customer', willUpdate: false);
      Get.find<ChatController>().getConversationList(1, type: Get.find<ChatController>().type);

    }
  }

  void _decideTabFromSearchResult(ConversationsModel? conversation) {
    String? type = 'customer';
    if(conversation != null && conversation.conversations != null && conversation.conversations!.isNotEmpty) {
      if (conversation.conversations!.first.senderType == AppConstants.deliveryMan) {
        type = conversation.conversations!.first.receiverType;
      } else {
        type = conversation.conversations!.first.senderType;
      }
    }

    if(type == AppConstants.vendor && !_tabController.indexIsChanging) {
      _tabController.animateTo(1);
      Get.find<ChatController>().setType('vendor');
      Get.find<ChatController>().setTabSelect();
    } else if(type == AppConstants.customer && !_tabController.indexIsChanging) {
      _tabController.animateTo(0);
      Get.find<ChatController>().setType('customer');
      Get.find<ChatController>().setTabSelect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatController) {
      ConversationsModel? conversation0;
      if(chatController.searchConversationModel != null) {
        conversation0 = chatController.searchConversationModel;
        //_decideTabFromSearchResult(conversation0);
      } else {
        conversation0 = chatController.conversationModel;
      }

      return Scaffold(
        //backgroundColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.5),
        appBar: CustomAppBarWidget(title: 'conversation'.tr),
        body: Column(children: [
          // Search bar
          Center(child: Container(
            width: Dimensions.webMaxWidth,
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: SearchFieldWidget(
              controller: _searchController,
              hint: 'search'.tr,
              suffixIcon: chatController.searchConversationModel != null ? Icons.close : CupertinoIcons.search,
              onSubmit: (String text) {
                if(_searchController.text.trim().isNotEmpty) {
                  chatController.searchConversation(_searchController.text.trim(), type: chatController.type);
                } else {
                  showCustomSnackBar('write_somethings'.tr);
                }
              },
              iconPressed: () {
                if(chatController.searchConversationModel != null) {
                  _searchController.text = '';
                  chatController.removeSearchMode();
                  chatController.getConversationList(1, type: chatController.type);
                } else {
                  if(_searchController.text.trim().isNotEmpty) {
                    chatController.searchConversation(_searchController.text.trim(), type: chatController.type);
                  } else {
                    showCustomSnackBar('write_somethings'.tr);
                  }
                }
              },
            ),
          )),

          // Conversation List
          Expanded(child: RefreshIndicator(
            onRefresh: () async {
              await chatController.getConversationList(1, type: chatController.type);
            },
            child: CustomScrollView(controller: _scrollController, slivers: [
              // Sticky Tab bar
              if(!isRideActive) SliverPersistentHeader(
                pinned: true,
                delegate: SliverDelegate(height: 60, child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(color: Theme.of(context).cardColor),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: false,
                    dividerColor: Colors.transparent,
                    labelPadding: EdgeInsets.zero,
                    indicatorColor: Theme.of(context).primaryColor,
                    labelColor: Theme.of(context).textTheme.bodyLarge!.color,
                    unselectedLabelColor: Theme.of(context).disabledColor,
                    indicatorSize: TabBarIndicatorSize.tab,
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                    unselectedLabelStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                    tabs: [
                      Tab(text: 'customer'.tr),
                      Tab(text: 'store'.tr),
                    ],
                    onTap: (int index){
                      if(index == 0){
                        chatController.setType('customer');
                        chatController.setTabSelect();
                      } else {
                        chatController.setType('vendor');
                        chatController.setTabSelect();
                      }
                      if(chatController.searchConversationModel == null) {
                        chatController.getConversationList(1, type: chatController.type);
                      } else {
                        chatController.searchConversation(_searchController.text.trim(), type: chatController.type);
                      }
                    },
                  ),
                )),
              ),

              // Conversation List
              SliverToBoxAdapter(child: (conversation0 != null && conversation0.conversations != null) ?
                conversation0.conversations!.isNotEmpty ?
                conversationList(chatController, conversation0)
                : Padding(padding: const EdgeInsets.only(top: 100), child: Center(child:
                    Column(children: [
                      Icon(Icons.chat_bubble_outline, size: 70, color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Text('no_conversation_found'.tr, style: robotoMedium.copyWith(color: Theme.of(context).disabledColor))
                    ]),
                ))
              : const Padding(padding: EdgeInsets.only(top: 100), child: Center(child: CircularProgressIndicator())),
              )
            ])
          ))
        ])
      );
    });
  }


  Widget conversationList(ChatController chatController, ConversationsModel? conversation0) {
    return Container(
      width: Dimensions.webMaxWidth,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: PaginatedListViewWidget(
        scrollController: _scrollController,
        onPaginate: (int? offset) => chatController.getConversationList(offset!),
        totalSize: conversation0?.totalSize,
        offset: conversation0?.offset,
        enabledPagination: chatController.searchConversationModel == null,
        productView: ListView.builder(
          itemCount: conversation0?.conversations!.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {

            Conversation conversation = conversation0!.conversations![index];

            User? user;
            String? type;
            if(conversation.senderType == AppConstants.deliveryMan) {
              user = conversation.receiver;
              type = conversation.receiverType;
            } else {
              user = conversation.sender;
              type = conversation.senderType;
            }

            bool unSeen = conversation.lastMessage?.isSeen == 0 && conversation.unreadMessageCount! > 0 && conversation.lastMessage!.senderId != user?.id;

            return Container(
              margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: unSeen ? Theme.of(context).disabledColor.withValues(alpha: 0.04) : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                boxShadow: [BoxShadow(color: unSeen ? Theme.of(context).hintColor.withValues(alpha: 0.01) : Theme.of(context).disabledColor.withValues(alpha: 0.1), blurRadius: 5, spreadRadius: 0)],
              ),
              child: CustomInkWellWidget(
                onTap: () {
                  if(user != null) {
                    Get.toNamed(RouteHelper.getChatRoute(
                      notificationBody: NotificationBodyModel(
                        type: conversation.senderType,
                        notificationType: NotificationType.message,
                        customerId: type == AppConstants.customer ? user.userId : null,
                        vendorId: type == AppConstants.vendor ? user.vendorId : null,
                      ),
                      conversationId: conversation.id,
                    ))!.then((value) => Get.find<ChatController>().getConversationList(1, type: chatController.type));
                  } else {
                    showCustomSnackBar('${'sorry_cannot_view_this_conversation'.tr} ${type!.tr} ${'may_have_been_removed_from'.tr} ${AppConstants.appName}');
                  }
                },
                highlightColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
                radius: Dimensions.radiusMedium,
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Row(children: [

                    ClipOval(child: CustomImageWidget(
                      height: 50, width: 50,
                      image: '${user != null ? user.imageFullUrl : ''}',
                    )),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        user != null ? Text(
                          '${user.fName} ${user.lName}',
                          style: robotoMedium,
                        ) : Text('${type!.tr} ${'deleted'.tr}', style: robotoMedium),

                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            DateConverterHelper.beforeTimeFormat(conversation.lastMessageTime!),
                            style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeExtraSmall),
                          ),
                        ),
                      ]),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Row(children: [
                        user != null ? Expanded(
                          child: Text(
                            conversation.lastMessage!.message ?? 'attachment_sent'.tr,
                            style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: (conversation.unreadMessageCount! > 0) ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).disabledColor
                            ),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ) : const SizedBox(),
                        const SizedBox(width: Dimensions.paddingSizeDefault),

                        (conversation.unreadMessageCount! > 0 && conversation.lastMessage!.senderId == user?.id) ? Container(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                          decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                          child: Text(
                            conversation.unreadMessageCount.toString(),
                            style: robotoMedium.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeExtraSmall),
                          ),
                        ) : const SizedBox(),
                      ]),
                    ])),
                  ]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

enum UserType {
  user,
  customer,
  admin,
  vendor,
}

// class ConversationScreen extends StatefulWidget {
//   const ConversationScreen({super.key});
//
//   @override
//   State<ConversationScreen> createState() => _ConversationScreenState();
// }
//
// class _ConversationScreenState extends State<ConversationScreen> {
//   final ScrollController _scrollController = ScrollController();
//   final TextEditingController _searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//
//     Get.find<ChatController>().getConversationList(1);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.5),
//       appBar: CustomAppBarWidget(title: 'conversation'.tr),
//       body: GetBuilder<ChatController>(builder: (chatController) {
//
//         ConversationsModel? conversation0;
//         if(chatController.searchConversationModel != null) {
//           conversation0 = chatController.searchConversationModel;
//         }else {
//           conversation0 = chatController.conversationModel;
//         }
//
//         return Padding(
//           padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
//           child: Column(children: [
//
//             (conversation0 != null && conversation0.conversations != null) ? SearchFieldWidget(
//               controller: _searchController,
//               hint: 'search'.tr,
//               suffixIcon: chatController.searchConversationModel != null ? Icons.close : CupertinoIcons.search,
//               onSubmit: (String text) {
//                 if(_searchController.text.trim().isNotEmpty) {
//                   chatController.searchConversation(_searchController.text.trim());
//                 }else {
//                   showCustomSnackBar('write_somethings'.tr);
//                 }
//               },
//               iconPressed: () {
//                 if(chatController.searchConversationModel != null) {
//                   _searchController.text = '';
//                   chatController.removeSearchMode();
//                 }else {
//                   if(_searchController.text.trim().isNotEmpty) {
//                     chatController.searchConversation(_searchController.text.trim());
//                   }else {
//                     showCustomSnackBar('write_somethings'.tr);
//                   }
//                 }
//               },
//             ) : const SizedBox(),
//
//             SizedBox(height: (conversation0 != null && conversation0.conversations != null
//                 && chatController.conversationModel!.conversations!.isNotEmpty) ? Dimensions.paddingSizeSmall : 0),
//
//             Expanded(
//               child: (conversation0 != null && conversation0.conversations != null)
//               ? conversation0.conversations!.isNotEmpty ? RefreshIndicator(
//                 onRefresh: () async {
//                   chatController.getConversationList(1);
//                 },
//                 child: SingleChildScrollView(
//                   controller: _scrollController,
//                   child: Center(child: SizedBox(width: 1170, child:  PaginatedListViewWidget(
//                     scrollController: _scrollController,
//                     onPaginate: (int? offset) => chatController.getConversationList(offset!),
//                     totalSize: conversation0.totalSize,
//                     offset: conversation0.offset,
//                     enabledPagination: chatController.searchConversationModel == null,
//                     productView: ListView.builder(
//                       itemCount: conversation0.conversations!.length,
//                       padding: EdgeInsets.zero,
//                       physics: const NeverScrollableScrollPhysics(),
//                       shrinkWrap: true,
//                       itemBuilder: (context, index) {
//
//                         Conversation conversation = conversation0!.conversations![index];
//
//                         User? user;
//                         String? type;
//                         if(conversation.senderType == AppConstants.deliveryMan) {
//                           user = conversation.receiver;
//                           type = conversation.receiverType;
//                         }else {
//                           user = conversation.sender;
//                           type = conversation.senderType;
//                         }
//
//                         return Container(
//                           margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
//                           padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
//                           color: conversation.lastMessage?.isSeen == true && conversation.unreadMessageCount! == 0 ? Theme.of(context).disabledColor.withValues(alpha: 0.04) : Theme.of(context).cardColor,
//                           child: CustomInkWellWidget(
//                             onTap: (){
//                               if(user != null){
//                                 Get.toNamed(RouteHelper.getChatRoute(
//                                   notificationBody: NotificationBodyModel(
//                                     type: conversation.senderType, notificationType: NotificationType.message,
//                                     customerId: type == AppConstants.customer ? user.userId : null,
//                                     vendorId: type == AppConstants.vendor ? user.vendorId : null,
//                                   ),
//                                   conversationId: conversation.id,
//                                 ))!.then((value) => Get.find<ChatController>().getConversationList(1));
//                               }else{
//                                 showCustomSnackBar('${'sorry_cannot_view_this_conversation'.tr} ${type!.tr} ${'may_have_been_removed_from'.tr} ${AppConstants.appName}');
//                               }
//                             },
//                             highlightColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
//                             radius: Dimensions.radiusMedium,
//                             child: Stack(children: [
//                               Row(children: [
//                                 ClipOval(
//                                   child: CustomImageWidget(
//                                     height: 55, width: 55, fit: BoxFit.cover,
//                                     image: '${user != null ? user.imageFullUrl : ''}',
//                                     // imageType: baseUrl,
//                                   ),
//                                 ),
//                                 const SizedBox(width: Dimensions.paddingSizeSmall),
//
//                                 Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
//
//                                   user != null ? Text('${user.fName} ${user.lName}', style: robotoMedium)
//                                       : Text('${type!.tr} ${'deleted'.tr}', style: robotoMedium),
//                                   const SizedBox(height: Dimensions.paddingSizeExtraSmall),
//
//                                   Text(
//                                     conversation.lastMessage!.message!,
//                                     style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: (conversation.unreadMessageCount! > 0) ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).disabledColor),
//                                     maxLines: 1, overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ])),
//                               ]),
//
//                               Positioned(
//                                 right: Get.find<LocalizationController>().isLtr ? 0 : null,
//                                 left: Get.find<LocalizationController>().isLtr ? null : 0,
//                                 top: 0,
//                                 child: Text(
//                                   DateConverterHelper.beforeTimeFormat(conversation.lastMessageTime!),
//                                   // DateConverterHelper.localDateToStringAMPM(DateConverterHelper.dateTimeStringToDate(conversation.lastMessageTime!)),
//                                   style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeExtraSmall),
//                                   textAlign: TextAlign.end,
//                                 ),
//                               ),
//
//                               conversation.unreadMessageCount! > 0 ? Positioned(
//                                 right: Get.find<LocalizationController>().isLtr ? 0 : null,
//                                 left: Get.find<LocalizationController>().isLtr ? null : 0,
//                                 bottom: 0,
//                                 child: Container(
//                                   padding: EdgeInsets.all((conversation.lastMessage!.senderId == user?.id) ? Dimensions.paddingSizeExtraSmall : 0.0),
//                                   decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
//                                   child: Text(
//                                     conversation.lastMessage != null ? (conversation.lastMessage!.senderId == user?.id)
//                                         ? conversation.unreadMessageCount.toString() : '' : conversation.unreadMessageCount.toString(),
//                                     style: robotoMedium.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeExtraSmall),
//                                   ),
//                                 ),
//                               ) : const SizedBox(),
//
//                             ]),
//                           ),
//                         );
//                       },
//                     ),
//                   ))),
//                 ),
//               ) : Center(child: Text('no_conversation_found'.tr, style: robotoMedium)) : const Center(child: CircularProgressIndicator()),
//             ) ,
//           ]),
//         );
//       }),
//     );
//   }
// }
