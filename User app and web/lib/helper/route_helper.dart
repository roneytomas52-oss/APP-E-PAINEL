import 'dart:convert';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/zone_warning_dialog.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/auth/screens/new_user_setup_screen.dart';
import 'package:sixam_mart/features/auth/screens/rider_registration_screen.dart';
import 'package:sixam_mart/features/brands/screens/brands_product_screen.dart';
import 'package:sixam_mart/features/brands/screens/brands_screen.dart';
import 'package:sixam_mart/features/business/screens/subscription_payment_screen.dart';
import 'package:sixam_mart/features/business/screens/subscription_success_or_failed_screen.dart';
import 'package:sixam_mart/features/chat/domain/models/order_chat_model.dart';
import 'package:sixam_mart/features/checkout/screens/digital_payment_failed_screen.dart';
import 'package:sixam_mart/features/home/screens/home_screen.dart';
import 'package:sixam_mart/features/item/screens/item_view_all_screen.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/loyalty/screens/loyalty_screen.dart';
import 'package:sixam_mart/features/profile/domain/models/update_user_model.dart';
import 'package:sixam_mart/features/profile/screens/setting_page.dart';
import 'package:sixam_mart/features/refer_and_earn/screens/refer_and_earn_screen.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/item/domain/models/basic_campaign_model.dart';
import 'package:sixam_mart/features/chat/domain/models/conversation_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/parcel/domain/models/parcel_category_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/address/screens/add_address_screen.dart';
import 'package:sixam_mart/features/address/screens/address_screen.dart';
import 'package:sixam_mart/features/auth/screens/delivery_man_registration_screen.dart';
import 'package:sixam_mart/features/auth/screens/sign_in_screen.dart';
import 'package:sixam_mart/features/auth/screens/sign_up_screen.dart';
import 'package:sixam_mart/features/auth/screens/store_registration_screen.dart';
import 'package:sixam_mart/features/category/screens/category_screen.dart';
import 'package:sixam_mart/features/location/screens/map_screen.dart';
import 'package:sixam_mart/features/store/screens/campaign_screen.dart';
import 'package:sixam_mart/features/store/widgets/all_store_web_view_widget.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/module_helper.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/helper/shallow_route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/html_type.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/common/widgets/image_viewer_screen.dart';
import 'package:sixam_mart/common/widgets/not_found.dart';
import 'package:sixam_mart/features/cart/screens/cart_screen.dart';
import 'package:sixam_mart/features/category/screens/category_item_screen.dart';
import 'package:sixam_mart/features/chat/screens/chat_screen.dart';
import 'package:sixam_mart/features/chat/screens/conversation_screen.dart';
import 'package:sixam_mart/features/checkout/screens/checkout_screen.dart';
import 'package:sixam_mart/features/payment/screens/offline_payment_screen.dart';
import 'package:sixam_mart/features/checkout/screens/order_successful_screen.dart';
import 'package:sixam_mart/features/payment/screens/payment_screen.dart';
import 'package:sixam_mart/features/payment/screens/payment_webview_screen.dart';
import 'package:sixam_mart/features/coupon/screens/coupon_screen.dart';
import 'package:sixam_mart/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixam_mart/features/favourite/screens/favourite_screen.dart';
import 'package:sixam_mart/features/flash_sale/screens/flash_sale_details_screen.dart';
import 'package:sixam_mart/features/item/screens/item_campaign_screen.dart';
import 'package:sixam_mart/features/item/screens/item_details_screen.dart';
import 'package:sixam_mart/features/item/screens/popular_item_screen.dart';
import 'package:sixam_mart/features/verification/screens/forget_pass_screen.dart';
import 'package:sixam_mart/features/verification/screens/new_pass_screen.dart';
import 'package:sixam_mart/features/verification/screens/verification_screen.dart';
import 'package:sixam_mart/features/html/screens/html_viewer_screen.dart';
import 'package:sixam_mart/features/interest/screens/interest_screen.dart';
import 'package:sixam_mart/features/language/screens/language_screen.dart';
import 'package:sixam_mart/features/location/screens/access_location_screen.dart';
import 'package:sixam_mart/features/location/screens/pick_map_screen.dart';
import 'package:sixam_mart/features/notification/screens/notification_screen.dart';
import 'package:sixam_mart/features/onboard/screens/onboarding_screen.dart';
import 'package:sixam_mart/features/order/screens/guest_track_order_screen.dart';
import 'package:sixam_mart/features/order/screens/order_details_screen.dart';
import 'package:sixam_mart/features/order/screens/order_screen.dart';
import 'package:sixam_mart/features/order/screens/order_tracking_screen.dart';
import 'package:sixam_mart/features/order/screens/refund_request_screen.dart';
import 'package:sixam_mart/features/parcel/screens/parcel_category_screen.dart';
import 'package:sixam_mart/features/parcel/screens/parcel_location_screen.dart';
import 'package:sixam_mart/features/parcel/screens/parcel_request_screen.dart';
import 'package:sixam_mart/features/profile/screens/profile_screen.dart';
import 'package:sixam_mart/features/profile/screens/update_profile_screen.dart';
import 'package:sixam_mart/features/store/screens/all_store_screen.dart';
import 'package:sixam_mart/features/store/screens/store_item_search_screen.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';
import 'package:sixam_mart/features/review/screens/review_screen.dart';
import 'package:sixam_mart/features/search/screens/search_screen.dart';
import 'package:sixam_mart/features/splash/screens/splash_screen.dart';
import 'package:sixam_mart/features/support/screens/support_screen.dart';
import 'package:sixam_mart/features/update/screens/update_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/wallet/screens/wallet_screen.dart';
import 'package:sixam_mart/features/ride_share_module/safety_alert/screens/safety_policy_screen.dart';

class RouteHelper {
  static const String initial = '/';
  static const String splash = '/splash';
  static const String language = '/language';
  static const String onBoarding = '/on-boarding';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String verification = '/verification';
  static const String accessLocation = '/access-location';
  static const String pickMap = '/pick-map';
  static const String interest = '/interest';
  static const String main = '/main';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String search = '/search';
  static const String store = '/store';
  static const String orderDetails = '/order-details';
  static const String profile = '/profile';
  static const String updateProfile = '/update-profile';
  static const String coupon = '/coupon';
  static const String notification = '/notification';
  static const String map = '/store-location';
  static const String address = '/address';
  static const String orderSuccess = '/order-successful';
  static const String payment = '/payment';
  static const String checkout = '/checkout';
  static const String orderTracking = '/track-order';
  static const String basicCampaign = '/basic-campaign';
  static const String html = '/html-page';
  static const String privacyPolicy = '/privacy-policy';
  static const String cancellationPolicy = '/cancellation-policy';
  static const String refundPolicy = '/refund-policy';
  static const String termsAndCondition = '/terms-and-condition';
  static const String shippingPolicy = '/shipping-policy';
  static const String categories = '/categories';
  static const String categoryItem = '/category-item';
  static const String popularItems = '/most-popular-items';
  static const String specialItems = '/special-offer';
  static const String bestReviewed = '/best-reviewed-items';
  static const String commonConditions = '/common-conditions';
  static const String itemCampaign = '/item-campaign';
  static const String support = '/help-and-support';
  static const String rateReview = '/rate-and-review';
  static const String update = '/update';
  static const String cart = '/cart';
  static const String addAddress = '/add-address';
  static const String editAddress = '/edit-address';
  static const String storeReview = '/store-review';
  static const String allStores = '/stores';
  static const String bestStoresNearby = '/best-stores-nearby';
  static const String popularStores = '/popular-stores';
  static const String featuredStores = '/featured-stores';
  static const String topOffers = '/top-offers-near-me';
  static const String recommendedStores = '/recommended-stores';
  static const String newStores = '/new-stores';
  static const String itemImages = '/item-images';
  static const String parcelCategory = '/parcel-category';
  static const String parcelLocation = '/parcel-location';
  static const String parcelRequest = '/parcel-request';
  static const String searchStoreItem = '/search-store-item';
  static const String order = '/order';
  static const String itemDetails = '/item-details';
  static const String wallet = '/wallet';
  static const String loyalty = '/loyalty-point';
  static const String referAndEarn = '/refer-and-earn';
  static const String messages = '/messages';
  static const String conversation = '/conversation';
  static const String restaurantRegistration = '/store-registration';
  static const String deliveryManRegistration = '/delivery-man-registration';
  static const String riderRegistration = '/rider-registration';
  static const String refund = '/refund';

  static const String offlinePaymentScreen = '/offline-payment-screen';
  static const String flashSaleDetailsScreen = '/flash-sale-details-screen';
  static const String guestTrackOrderScreen = '/guest-track-order-screen';
  static const String favourite = '/favourite';
  static const String brands = '/brands';
  static const String brandsItemScreen = '/brand-item';

  static const String subscriptionSuccess = '/subscription-success';
  static const String subscriptionPayment = '/subscription-payment';
  static const String newUserSetupScreen = '/new-user-setup-screen';
  static const String itemViewAllScreen = '/item-view-all-screen';
  static const String settingScreen = '/setting-screen';
  static const String digitalPaymentFailedScreen = '/digital-payment-failed-screen';

  static const String safety = '/safety';
  static const String allStoresScreen = '/all-Stores';



  static String getInitialRoute({bool fromSplash = false, String? moduleId, bool fromDeeplink = false}) {
    return '$initial?module=${moduleId ?? ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id ?? ModuleHelper.getCacheModule()?.slug}&from-splash=$fromSplash${fromDeeplink ? '&from_deeplink=true' : ''}';
  }
  static String getSplashRoute(NotificationBodyModel? body, String? deeplink) {
    String data = 'null';
    if(body != null) {
      List<int> encoded = utf8.encode(jsonEncode(body.toJson()));
      data = base64Encode(encoded);
    }
    print('=======splash screen calling-------------: $splash?data=$data&deeplink=$deeplink');
    return '$splash?data=$data&deeplink=$deeplink';
  }
  static String getLanguageRoute(String page) => '$language?page=$page';
  static String getOnBoardingRoute() => onBoarding;
  static String getSignInRoute(String page) => '$signIn?page=$page';
  static String getSignUpRoute({String? deeplinkCode}) => '$signUp?code=$deeplinkCode';
  static String getVerificationRoute(String? number, String? email, String? token, String page, String? pass, String loginType, {String? session, UpdateUserModel? updateUserModel, bool? backFromThis}) {
    String? authSession;
    String? userModel;
    if(session != null) {
      authSession = base64Url.encode(utf8.encode(session));
    }
    if(updateUserModel != null) {
      List<int> encoded = utf8.encode(jsonEncode(updateUserModel.toJson()));
      userModel = base64Encode(encoded);
    }
    return '$verification?page=$page&number=$number&email=$email&token=$token&pass=$pass&login_type=$loginType&session=$authSession&user_model=$userModel&back_from_this=${backFromThis.toString()}';
  }

  static String getAccessLocationRoute(String page) => '$accessLocation?page=$page';
  static String getPickMapRoute(String? page, bool canRoute) => '$pickMap?page=$page&route=${canRoute.toString()}';
  static String getInterestRoute() => interest;
  static String getMainRoute(String page) => '$main?page=$page';
  static String getForgotPassRoute() => forgotPassword;
  static String getResetPasswordRoute({String? phone, String? email, required String token, required String page}) => '$resetPassword?phone=$phone&token=$token&page=$page&email=$email';
  static String getSearchRoute({String? queryText}) => '$search?query=${queryText ?? ''}&module=${ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id}';

  static String getStoreRoute({required int? id, required String page, required String slug, String? moduleId, bool fromDeeplink = false}) {
    return '$store/$slug?id=$id&page=$page&module=${moduleId ?? ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id}${fromDeeplink ? '&from_deeplink=true' : ''}';
  }

  static String getOrderDetailsRoute(int? orderID, {bool? fromNotification, bool? fromOffline, String? contactNumber}) {
    return '$orderDetails?id=$orderID&from=${fromNotification.toString()}&from_offline=$fromOffline&contact=$contactNumber';
  }
  static String getProfileRoute() => profile;
  static String getUpdateProfileRoute() => updateProfile;
  static String getCouponRoute() => coupon;
  static String getNotificationRoute({bool? fromNotification}) => '$notification?from=${fromNotification.toString()}';
  static String getMapRoute(AddressModel addressModel, String page, bool isFood, {String? storeName, int? moduleId, required String slug}) {
    List<int> encoded = utf8.encode(jsonEncode(addressModel.toJson()));
    String data = base64Encode(encoded);
    return '$map/$slug?address=$data&page=$page&module=$isFood&store-name=$storeName&module=${moduleId ?? ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id}';
  }
  static String getAddressRoute() => address;
  static String getOrderSuccessRoute(String orderID, String? contactNumber, {bool? createAccount, String guestId = ''}) {
    return '$orderSuccess?id=$orderID&contact_number=$contactNumber&create_account=$createAccount&guest_id=$guestId';
  }

  static String getPaymentRoute(String id, int? user, String? type, double amount, bool? codDelivery, String? paymentMethod,
      {required String guestId, String? contactNumber, String? addFundUrl, String? subscriptionUrl, int? storeId, bool? createAccount, int? createUserId}) =>
      '$payment?id=$id&user=$user&type=$type&amount=$amount&cod-delivery=$codDelivery&add-fund-url=$addFundUrl&payment-method=$paymentMethod&guest-id=$guestId&number=$contactNumber&subscription-url=$subscriptionUrl&store_id=$storeId&create_account=$createAccount&create_user_id=$createUserId';

  static String getCheckoutRoute(String page, {int? storeId}) => '$checkout?page=$page&store-id=$storeId&module=${ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id??ModuleHelper.getCacheModule()?.slug}';
  static String getOrderTrackingRoute(int? id, String? contactNumber) => '$orderTracking?id=$id&number=$contactNumber';
  static String getBasicCampaignRoute(BasicCampaignModel basicCampaignModel) {
    String data = base64Encode(utf8.encode(jsonEncode(basicCampaignModel.toJson())));
    return '$basicCampaign?module=${ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id}&data=$data';
  }
  static String getHtmlRoute(String page) => '$html?page=$page';
  static String getPrivacyPolicyRoute() => privacyPolicy;
  static String getCancellationPolicyRoute() => cancellationPolicy;
  static String getRefundPolicyRoute() => refundPolicy;
  static String getTermsAndConditionRoute() => termsAndCondition;
  static String getShippingPolicyRoute() => shippingPolicy;
  static String getCategoryRoute({int? moduleId}) => '$categories?module=${moduleId ?? ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id}';
  static String getCategoryItemRoute(int? id, String name, {int? moduleId, required String slug}) {
    List<int> encoded = utf8.encode(name);
    String data = base64Encode(encoded);
    String categorySlug = '';
    if(slug.isEmpty) {
      categorySlug = name.toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
          .replaceAll(RegExp(r'\s+'), '-')
          .replaceAll(RegExp(r'-+'), '-')
          .trim();
    } else {
      categorySlug = slug;
    }
    return '$categoryItem/$categorySlug?id=$id&name=$data&module=${moduleId ?? ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id}';
  }
  static String getPopularItemRoute(bool isPopular, bool isSpecial) => '$popularItems?page=${isPopular ? 'popular' : 'reviewed'}&special=${isSpecial.toString()}&module=${ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id}';
  static String getSpecialOfferItemRoute() => '$specialItems?module=${ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id}';
  static String getBestReviewedItemRoute() => '$bestReviewed?module=${ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id}';
  static String getCommonConditionsRoute() => '$commonConditions?module=${ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id}';
  static String getItemCampaignRoute({bool isJustForYou = false}) => '$itemCampaign?${isJustForYou ? 'just-for-you=${isJustForYou.toString()}&' : ''}module=${ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id}';
  static String getSupportRoute() => support;
  static String getReviewRoute() => rateReview;
  static String getUpdateRoute(bool isUpdate) => '$update?update=${isUpdate.toString()}';
  static String getCartRoute() => '$cart?module=${ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id}';
  static String getAddAddressRoute(bool fromCheckout, bool fromRide, int? zoneId, {bool isNavbar = false}) => '$addAddress?page=${fromCheckout ? 'checkout' : 'address'}&ride=$fromRide&zone_id=$zoneId&navbar=$isNavbar';
  static String getEditAddressRoute(AddressModel? address, {bool fromGuest = false}) {
    String data = 'null';
    if (address != null) {
      data = base64Url.encode(utf8.encode(jsonEncode(address.toJson())));
    }
    return '$editAddress?data=$data&from-guest=$fromGuest';
  }
  static String getStoreReviewRoute(int? storeID, String? storeName, Store store, {int? moduleId, required String slug}) {
    String data = base64Url.encode(utf8.encode(jsonEncode(store.toJson())));
    return '$storeReview/$slug?storeID=$storeID&storeName=$storeName&store=$data&module=${moduleId ?? ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id}';
  }
  static String getAllStoreRoute(String page, {bool isNearbyStore = false, int? moduleId}) => '${_decideStoreRouteName(page)}?page=$page${isNearbyStore ? '&nearby=${isNearbyStore.toString()}' : ''}&module=${moduleId ?? ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id}';
  static String getItemImagesRoute(Item item) {
    String data = base64Url.encode(utf8.encode(jsonEncode(item.toJson())));
    return '$itemImages?item=$data';
  }
  static String getParcelCategoryRoute() => parcelCategory;
  static String getParcelLocationRoute(ParcelCategoryModel category) {
    String data = base64Url.encode(utf8.encode(jsonEncode(category.toJson())));
    return '$parcelLocation?module=${ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id}&data=$data';
  }
  static String getParcelRequestRoute(ParcelCategoryModel category, AddressModel pickupAddress, AddressModel destinationAddress) {
    String category0 = base64Url.encode(utf8.encode(jsonEncode(category.toJson())));
    String pickedUpAddress = base64Url.encode(utf8.encode(jsonEncode(pickupAddress.toJson())));
    String destinationAddress0 = base64Url.encode(utf8.encode(jsonEncode(destinationAddress.toJson())));
    return '$parcelRequest?category=$category0&picked=$pickedUpAddress&destination=$destinationAddress0';
  }
  static String getSearchStoreItemRoute(int? storeID) => '$searchStoreItem?id=$storeID';
  static String getOrderRoute() => order;
  static String getItemDetailsRoute(int? itemID, bool isRestaurant, String name, {String? moduleId, required String slug, bool fromDeeplink = false, bool isCampaign = false}) {
    String itemSlug = '';
    if(slug.isEmpty) {
      itemSlug = name.toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
          .replaceAll(RegExp(r'\s+'), '-')
          .replaceAll(RegExp(r'-+'), '-')
          .trim();
    } else {
      itemSlug = slug;
    }
    return '$itemDetails/$itemSlug?id=$itemID&page=${isRestaurant ? 'restaurant' : 'item'}&module=${moduleId ?? ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id}${fromDeeplink ? '&from_deeplink=true' : ''}&is_campaign=$isCampaign';
  }
  static String getWalletRoute({String? fundStatus, String? token, bool fromNotification = false}) => '$wallet?payment_status=$fundStatus&token=$token&from_notification=$fromNotification';
  static String getLoyaltyRoute({bool fromNotification = false}) => '$loyalty?from_notification=$fromNotification';
  static String getReferAndEarnRoute({String? code}) => '$referAndEarn?code=$code';
  static String getChatRoute({required NotificationBodyModel? notificationBody, User? user, int? conversationID, int? index, bool? fromNotification, OrderChatModel? orderChatModel}) {
    String notificationBody0 = 'null';
    if (notificationBody != null) {
      notificationBody0 = base64Encode(utf8.encode(jsonEncode(notificationBody.toJson())));
    }
    String orderChat = 'null';
    if (orderChatModel != null) {
      orderChat = base64Encode(utf8.encode(jsonEncode(orderChatModel.toJson())));
    }
    String user0 = 'null';
    if (user != null) {
      user0 = base64Encode(utf8.encode(jsonEncode(user.toJson())));
    }
    return '$messages?notification=$notificationBody0&user=$user0&conversation_id=$conversationID&index=$index&from=${fromNotification.toString()}&order-chat=$orderChat';
  }
  static String getConversationRoute() => conversation;
  static String getRestaurantRegistrationRoute() => restaurantRegistration;
  static String getDeliverymanRegistrationRoute() => deliveryManRegistration;
  static String getRiderRegistrationRoute() => riderRegistration;
  static String getRefundRequestRoute(String orderID) => '$refund?id=$orderID';

  static String getOfflinePaymentScreen({
    required int? zoneId, required double total,
    required double? maxCodOrderAmount, required bool fromCart, required bool? isCodActive,
    required bool forParcel, required String orderId, required String contactNumber,
  }) {
    return '$offlinePaymentScreen?zone_id=$zoneId&total=$total&max_cod_amount=$maxCodOrderAmount&from_cart=$fromCart&cod_active=$isCodActive&for_parcel=$forParcel&order_id=$orderId&contact_number=$contactNumber';
  }
  static String getFlashSaleDetailsScreen(int id) => '$flashSaleDetailsScreen?id=$id&module=${ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id}';
  static String getGuestTrackOrderScreen(String orderId, String number) => '$guestTrackOrderScreen?order_id=$orderId&number=$number';
  static String getFavouriteScreen() => favourite;
  static String getBrandsScreen() => '$brands?module=${ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id}';
  static String getBrandsItemScreen(int brandId, String brandName, {required String slug, int? moduleId}) {
    return '$brandsItemScreen/$slug?brandId=$brandId&brandName=$brandName&module=${moduleId ?? ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id}';
  }

  static String getSubscriptionSuccessRoute({String? status, required bool fromSubscription, int? storeId}) => '$subscriptionSuccess?flag=$status&from_subscription=$fromSubscription&store_id=$storeId';
  static String getSubscriptionPaymentRoute({required int? storeId, required int? packageId}) => '$subscriptionPayment?store-id=$storeId&package-id=$packageId';
  static String getNewUserSetupScreen({required String name, required String loginType, required String? phone, required String? email, required bool? backFromThis, int? moduleId}) {
    return '$newUserSetupScreen?name=$name&login_type=$loginType&phone=$phone&email=$email&back_from_this=${backFromThis.toString()}&module=${moduleId ?? ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id}';
  }
  static String getItemViewAllScreen(bool isPopular, bool isSpecial) => '$itemViewAllScreen?page=${isPopular ? 'popular' : 'reviewed'}&special=${isSpecial.toString()}';
  static String getSettingScreen() => settingScreen;
  static String getDigitalPaymentFailedScreen(String orderId, {bool? createAccount}) {
    return '$digitalPaymentFailedScreen?orderId=$orderId&create_account=$createAccount';
  }
  static String getSafetyScreen() => safety;
  static String getAllStoreScreenRoute() => allStoresScreen;
  static List<GetPage> routes = [
    GetPage(name: initial, page: () {
      print('=======route: ${Get.parameters['module']} // ${Get.parameters['module'] != null && Get.parameters['module']!.isNotEmpty && Get.parameters['module'] != 'null'}');
      return getRoute(
        byPuss: (Get.parameters['module'] != null && Get.parameters['module']!.isNotEmpty && Get.parameters['module'] != 'null'),
        _waitForModule(
          Get.parameters['module'], fromDeeplink: Get.parameters['from_deeplink'] == 'true',
          DashboardScreen(pageIndex: 0, fromSplash: Get.parameters['from-splash'] == 'true'),
        )
      );
    }),
    GetPage(name: splash, page: () {
      NotificationBodyModel? data;
      if (Get.parameters['data'] != 'null') {
        List<int> decode = base64Decode(Get.parameters['data']!.replaceAll(' ', '+'));
        data = NotificationBodyModel.fromJson(jsonDecode(utf8.decode(decode)));
      }
      String? deeplink = Get.parameters['deeplink'] != 'null' ? Get.parameters['deeplink'] : null;
      print('-------going to splash screen======2');
      return SplashScreen(body: data, deeplinkUrl: deeplink);
    }),
    GetPage(name: language, page: () => ChooseLanguageScreen(fromMenu: Get.parameters['page'] == 'menu')),
    GetPage(name: onBoarding, page: () => const OnBoardingScreen()),
    GetPage(name: signIn, page: () => SignInScreen(
      exitFromApp: Get.parameters['page'] == signUp || Get.parameters['page'] == splash || Get.parameters['page'] == onBoarding,
      backFromThis: Get.parameters['page'] != splash && Get.parameters['page'] != onBoarding,
      fromNotification: Get.parameters['page'] == notification, fromResetPassword: Get.parameters['page'] == resetPassword,
    )),
    GetPage(name: signUp, page: () => SignUpScreen(referCode: Get.parameters['code'] != 'null' ? Get.parameters['code'] : null)),
    GetPage(name: verification, page: () {
      String? pass;
      if (Get.parameters['pass'] != 'null') {
        List<int> decode = base64Decode(Get.parameters['pass']!.replaceAll(' ', '+'));
        pass = utf8.decode(decode);
      }
      String? session;
      if (Get.parameters['session'] != null && Get.parameters['session'] != 'null') {
        session = utf8.decode(base64Url.decode(Get.parameters['session'] ?? ''));
      }
      UpdateUserModel? userModel;
      if (Get.parameters['user_model'] != null && Get.parameters['user_model'] != 'null') {
        List<int> decode = base64Decode(Get.parameters['user_model'] != null ? Get.parameters['user_model']!.replaceAll(' ', '+') : '');
        userModel = UpdateUserModel.fromJson(jsonDecode(utf8.decode(decode)));
      }
      return VerificationScreen(
        number: Get.parameters['number'] != '' && Get.parameters['number'] != 'null' ? Get.parameters['number'] : null,
        fromSignUp: Get.parameters['page'] == signUp,
        token: Get.parameters['token'],
        password: pass,
        email: Get.parameters['email'] != '' && Get.parameters['email'] != 'null' ? Get.parameters['email'] : null,
        loginType: Get.parameters['login_type']!,
        firebaseSession: session,
        fromForgetPassword: Get.parameters['page'] == forgotPassword,
        userModel: userModel,
        backFromThis: Get.parameters['back_from_this'] == 'true',
      );
    }),

    GetPage(name: accessLocation, page: () => AccessLocationScreen(
      fromSignUp: Get.parameters['page'] == signUp, fromHome: Get.parameters['page'] == 'home', route: null,
    )),
    GetPage(name: pickMap, page: () {
      PickMapScreen? pickMapScreen = Get.arguments;
      bool fromAddress = Get.parameters['page'] == 'add-address';
      return ((Get.parameters['page'] == 'parcel' && pickMapScreen == null) || (fromAddress && pickMapScreen == null))
          ? const NotFound() : pickMapScreen ?? PickMapScreen(
        fromSignUp: Get.parameters['page'] == signUp, fromAddAddress: fromAddress, route: Get.parameters['page'],
        canRoute: Get.parameters['route'] == 'true',
      );
    }),
    GetPage(name: interest, page: () => const InterestScreen()),
    GetPage(name: main, page: () => getRoute(DashboardScreen(pageIndex: Get.parameters['page'] == 'home' ? 0 : Get.parameters['page'] == 'favourite' ? 1 : Get.parameters['page'] == 'cart' ? 2 : Get.parameters['page'] == 'order' ? 3 : Get.parameters['page'] == 'menu' ? 4 : 0))),

    GetPage(name: forgotPassword, page: () => const ForgetPassScreen()),

    GetPage(name: resetPassword, page: () => NewPassScreen(
      resetToken: Get.parameters['token'], number: Get.parameters['phone'],
      fromPasswordChange: Get.parameters['page'] == 'password-change', email: Get.parameters['email'],
    )),
    GetPage(name: search, page: () => getRoute(
      byPuss: (Get.parameters['module'] != null && Get.parameters['module']!.isNotEmpty && Get.parameters['module'] != 'null'),
      _waitForModule(
        Get.parameters['module'],
        SearchScreen(queryText: Get.parameters['query']),
      ),
    )),
    GetPage(name: '$store/:slug', page: () {
      return getRoute(
        _waitForModule(
          Get.parameters['module'], fromDeeplink: Get.parameters['from_deeplink'] == 'true',
          Get.arguments ?? StoreScreen(
            store: Store(id: Get.parameters['id'] != 'null' && Get.parameters['id'] != null
                ? int.parse(Get.parameters['id']!)
                : null),
            fromModule: Get.parameters['page'] != null && Get.parameters['page'] == 'module',
            slug: Get.parameters['slug'] ?? '',
          ),
        ),
        byPuss: Get.parameters['slug']?.isNotEmpty ?? false || (Get.parameters['module'] != null && Get.parameters['module']!.isNotEmpty && Get.parameters['module'] != 'null'),
      );
    }),
    GetPage(name: orderDetails, page: () {
      return getRoute(Get.arguments ?? OrderDetailsScreen(
        orderId: int.parse(Get.parameters['id'] ?? '0'),
        orderModel: null,
        fromNotification: Get.parameters['from'] == 'true',
        fromOfflinePayment: Get.parameters['from_offline'] == 'true',
        contactNumber: Get.parameters['contact'],
      ),);
    }),
    GetPage(name: profile, page: () => const ProfileScreen()),
    GetPage(name: updateProfile, page: () => getRoute(const UpdateProfileScreen())),
    GetPage(name: coupon, page: () => const CouponScreen()),
    GetPage(name: notification, page: () => getRoute(NotificationScreen(fromNotification: Get.parameters['from'] == 'true'))),
    GetPage(name: '$map/:slug', page: () {
      List<int> decode = base64Decode(Get.parameters['address']!.replaceAll(' ', '+'));
      AddressModel data = AddressModel.fromJson(jsonDecode(utf8.decode(decode)));
      return getRoute(
        byPuss: (Get.parameters['module'] != null && Get.parameters['module']!.isNotEmpty && Get.parameters['module'] != 'null'),
        _waitForModule(
          Get.parameters['module'],
          MapScreen(fromStore: Get.parameters['page'] == 'store', address: data, isFood: Get.parameters['module'] == 'true', storeName: Get.parameters['store-name'] ?? ''),
        ),
      );
    }),
    GetPage(name: address, page: () => const AddressScreen()),
    GetPage(name: orderSuccess, page: () => getRoute(OrderSuccessfulScreen(
      orderID: Get.parameters['id'],
      contactPersonNumber: Get.parameters['contact_number'] != null && Get.parameters['contact_number'] != 'null'
          ? Get.parameters['contact_number']
          : AuthHelper.isGuestLoggedIn() ? Get.find<AuthController>().getGuestNumber() : null,
      createAccount: Get.parameters['create_account'] == 'true', guestId: Get.parameters['guest_id'] ?? '',
    ),
    )),
    GetPage(name: payment, page: () {
      OrderModel order = OrderModel(
        id: int.parse(Get.parameters['id']!),
        orderType: Get.parameters['type'],
        userId: int.parse(Get.parameters['user']!),
        orderAmount: double.parse(Get.parameters['amount']!),
      );
      bool isCodActive = Get.parameters['cod-delivery'] == 'true';
      String addFundUrl = '';
      String subscriptionUrl = '';
      String paymentMethod = Get.parameters['payment-method']!;
      if (Get.parameters['add-fund-url'] != null && Get.parameters['add-fund-url'] != 'null') {
        addFundUrl = Get.parameters['add-fund-url']!;
      }
      if (Get.parameters['subscription-url'] != null && Get.parameters['subscription-url'] != 'null') {
        subscriptionUrl = Get.parameters['subscription-url']!;
      }
      String guestId = Get.parameters['guest-id']!;
      String number = Get.parameters['number']!;
      int? storeId = (Get.parameters['store_id'] != null && Get.parameters['store_id'] != 'null') ? int.parse(
          Get.parameters['store_id']!) : null;
      bool createAccount = Get.parameters['create_account'] == 'true';
      int? createUserId = Get.parameters['create_user_id'] != null && Get.parameters['create_user_id'] != 'null' ? int
          .parse(Get.parameters['create_user_id']!) : null;
      return getRoute(AppConstants.payInWevView ? PaymentWebViewScreen(
        orderModel: order,
        isCashOnDelivery: isCodActive,
        addFundUrl: addFundUrl,
        paymentMethod: paymentMethod,
        guestId: guestId,
        contactNumber: number,
        subscriptionUrl: subscriptionUrl,
        storeId: storeId,
        createAccount: createAccount,
      ) : PaymentScreen(
        orderModel: order,
        isCashOnDelivery: isCodActive,
        addFundUrl: addFundUrl,
        paymentMethod: paymentMethod,
        guestId: guestId,
        contactNumber: number,
        subscriptionUrl: subscriptionUrl,
        storeId: storeId,
        createAccount: createAccount,
        createUserId: createUserId,
      ));
    }),
    GetPage(name: checkout, page: () {
      CheckoutScreen? checkoutScreen = Get.arguments;
      // bool fromCart = Get.parameters['page'] == 'cart';
      return getRoute(
        byPuss: (Get.parameters['module'] != null && Get.parameters['module']!.isNotEmpty && Get.parameters['module'] != 'null'),
        _waitForModule(
          Get.parameters['module'],
          checkoutScreen ?? (CheckoutScreen(
            cartList: null,
            fromCart: Get.parameters['page'] == 'cart',
            storeId: Get.parameters['store-id'] != 'null' ? int.parse(Get.parameters['store-id']!) : null,
          )),
        ),
      );
    }),
    GetPage(name: orderTracking, page: () => getRoute(OrderTrackingScreen(orderID: Get.parameters['id'], contactNumber: Get.parameters['number'],))),
    GetPage(name: basicCampaign, page: () {
      BasicCampaignModel data = BasicCampaignModel.fromJson(jsonDecode(utf8.decode(base64Decode(Get.parameters['data']!.replaceAll(' ', '+')))));
      return getRoute(
        byPuss: (Get.parameters['module'] != null && Get.parameters['module']!.isNotEmpty && Get.parameters['module'] != 'null'),
        _waitForModule(
          Get.parameters['module'],
          CampaignScreen(campaign: data),
        ),
      );
    }),
    GetPage(name: privacyPolicy, page: () => const HtmlViewerScreen(htmlType: HtmlType.privacyPolicy)),
    GetPage(name: cancellationPolicy, page: () => const HtmlViewerScreen(htmlType: HtmlType.cancellation)),
    GetPage(name: refundPolicy, page: () => const HtmlViewerScreen(htmlType: HtmlType.refund)),
    GetPage(name: termsAndCondition, page: () => const HtmlViewerScreen(htmlType: HtmlType.termsAndCondition)),
    GetPage(name: shippingPolicy, page: () => const HtmlViewerScreen(htmlType: HtmlType.shippingPolicy)),
    GetPage(name: html, page: () => HtmlViewerScreen(htmlType: HtmlType.aboutUs)),

    GetPage(name: categories, page: () {
      return getRoute(
        _waitForModule(
          Get.parameters['module'],
          const CategoryScreen(),
        ),
        byPuss: (Get.parameters['module'] != null && Get.parameters['module']!.isNotEmpty && Get.parameters['module'] != 'null'),);
    }),
    GetPage(name: '$categoryItem/:slug', page: () {
      List<int> decode = base64Decode(Get.parameters['name']!.replaceAll(' ', '+'));
      String data = utf8.decode(decode);
      return getRoute(
        byPuss: (Get.parameters['module'] != null && Get.parameters['module']!.isNotEmpty && Get.parameters['module'] != 'null'),
        _waitForModule(
          Get.parameters['module'],
          CategoryItemScreen(categoryID: Get.parameters['id'], categoryName: data),
        ),
      );
    }),
    GetPage(name: popularItems, page: () => getRoute(
      byPuss: (Get.parameters['module'] != null && Get.parameters['module']!.isNotEmpty && Get.parameters['module'] != 'null'),
      _waitForModule(
        Get.parameters['module'],
        PopularItemScreen(isPopular: Get.parameters['page'] == 'popular', isSpecial: Get.parameters['special'] == 'true'),
      ),
    )),
    GetPage(name: specialItems, page: () => getRoute(
      byPuss: (Get.parameters['module'] != null && Get.parameters['module']!.isNotEmpty && Get.parameters['module'] != 'null'),
      _waitForModule(
        Get.parameters['module'],
        PopularItemScreen(isPopular: false, isSpecial: true),
      ),
    )),
    GetPage(name: bestReviewed, page: () => getRoute(
      byPuss: (Get.parameters['module'] != null && Get.parameters['module']!.isNotEmpty && Get.parameters['module'] != 'null'),
      _waitForModule(
        Get.parameters['module'],
        const PopularItemScreen(isPopular: false, isSpecial: false),
      ),
    )),
    GetPage(name: commonConditions, page: () => getRoute(
      byPuss: (Get.parameters['module'] != null && Get.parameters['module']!.isNotEmpty && Get.parameters['module'] != 'null'),
      _waitForModule(
        Get.parameters['module'],
        const PopularItemScreen(isPopular: false, isSpecial: false, isCommonCondition: true),
      ),
    )),
    GetPage(name: itemCampaign, page: () => getRoute(
      byPuss: (Get.parameters['module'] != null && Get.parameters['module']!.isNotEmpty && Get.parameters['module'] != 'null'),
      _waitForModule(
        Get.parameters['module'],
        ItemCampaignScreen(isJustForYou: Get.parameters['just-for-you'] == 'true'),
      ),
    )),
    GetPage(name: support, page: () => const SupportScreen()),
    GetPage(name: update, page: () => UpdateScreen(isUpdate: Get.parameters['update'] == 'true')),
    GetPage(name: cart, page: () => getRoute(
      byPuss: (Get.parameters['module'] != null && Get.parameters['module']!.isNotEmpty && Get.parameters['module'] != 'null'),
      _waitForModule(
        Get.parameters['module'],
        const CartScreen(fromNav: false),
      ),
    )),
    GetPage(name: addAddress, page: () => getRoute(AddAddressScreen(
      fromCheckout: Get.parameters['page'] == 'checkout',
      fromRide: Get.parameters['ride'] == 'true',
      zoneId: int.parse(Get.parameters['zone_id']!),
      fromNavBar: Get.parameters['navbar'] == 'true',
    ))),
    GetPage(name: editAddress, page: () {
      AddressModel? data;
      if (Get.parameters['data'] != 'null') {
        data = AddressModel.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['data']!.replaceAll(' ', '+')))));
      }
      return getRoute(AddAddressScreen(
        fromCheckout: false, fromRide: false,
        address: data, forGuest: Get.parameters['from-guest'] == 'true',
      ));
    }),
    GetPage(name: rateReview, page: () => getRoute(Get.arguments ?? const NotFound())),
    GetPage(name: '$storeReview/:slug', page: () {
      return getRoute(
        byPuss: (Get.parameters['module'] != null && Get.parameters['module']!.isNotEmpty && Get.parameters['module'] != 'null'),
        _waitForModule(
          Get.parameters['module'],
          ReviewScreen(storeID: Get.parameters['storeID'], storeName: Get.parameters['storeName'], store: Store.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['store']!.replaceAll(' ', '+')))))),
        )
      );
    }),
    GetPage(name: allStores, page: () => getRoute(
      _waitForModule(Get.parameters['module'], AllStoreScreen(
        isPopular: Get.parameters['page'] == 'popular',
        isFeatured: Get.parameters['page'] == 'featured',
        isTopOfferStore: Get.parameters['page'] == 'topOffer',
        isNearbyStore: Get.parameters['nearby'] == 'true',
        isRecommendedStore: Get.parameters['page'] == 'recommended',
      )),
      byPuss: (Get.parameters['module'] != null && Get.parameters['module']!.isNotEmpty && Get.parameters['module'] != 'null'),
    )),
    GetPage(name: bestStoresNearby, page: () => getRoute(
      _waitForModule(Get.parameters['module'], AllStoreScreen(
        isPopular: Get.parameters['page'] == 'popular' || Get.parameters['page'] == 'best_store',
        isFeatured: Get.parameters['page'] == 'featured',
        isTopOfferStore: Get.parameters['page'] == 'topOffer',
        isNearbyStore: Get.parameters['nearby'] == 'true',
        isRecommendedStore: Get.parameters['page'] == 'recommended',
      )),
      byPuss: (Get.parameters['module'] != null && Get.parameters['module']!.isNotEmpty && Get.parameters['module'] != 'null'),
    )),
    GetPage(name: popularStores, page: () => getRoute(
      _waitForModule(Get.parameters['module'], AllStoreScreen(
        isPopular: Get.parameters['page'] == 'popular',
        isFeatured: Get.parameters['page'] == 'featured',
        isTopOfferStore: Get.parameters['page'] == 'topOffer',
        isNearbyStore: Get.parameters['nearby'] == 'true',
        isRecommendedStore: Get.parameters['page'] == 'recommended',
      )),
      byPuss: (Get.parameters['module'] != null && Get.parameters['module']!.isNotEmpty && Get.parameters['module'] != 'null'),
    )),
    GetPage(name: featuredStores, page: () => getRoute(
      _waitForModule(Get.parameters['module'], AllStoreScreen(
        isPopular: Get.parameters['page'] == 'popular',
        isFeatured: Get.parameters['page'] == 'featured',
        isTopOfferStore: Get.parameters['page'] == 'topOffer',
        isNearbyStore: Get.parameters['nearby'] == 'true',
        isRecommendedStore: Get.parameters['page'] == 'recommended',
      )),
      byPuss: (Get.parameters['module'] != null && Get.parameters['module']!.isNotEmpty && Get.parameters['module'] != 'null'),
    )),
    GetPage(name: topOffers, page: () => getRoute(
      _waitForModule(Get.parameters['module'], AllStoreScreen(
        isPopular: Get.parameters['page'] == 'popular',
        isFeatured: Get.parameters['page'] == 'featured',
        isTopOfferStore: Get.parameters['page'] == 'topOffer',
        isNearbyStore: Get.parameters['nearby'] == 'true',
        isRecommendedStore: Get.parameters['page'] == 'recommended',
      )),
      byPuss: (Get.parameters['module'] != null && Get.parameters['module']!.isNotEmpty && Get.parameters['module'] != 'null'),
    )),
    GetPage(name: recommendedStores, page: () => getRoute(
      _waitForModule(Get.parameters['module'], AllStoreScreen(
        isPopular: Get.parameters['page'] == 'popular',
        isFeatured: Get.parameters['page'] == 'featured',
        isTopOfferStore: Get.parameters['page'] == 'topOffer',
        isNearbyStore: Get.parameters['nearby'] == 'true',
        isRecommendedStore: Get.parameters['page'] == 'recommended',
      )),
      byPuss: (Get.parameters['module'] != null && Get.parameters['module']!.isNotEmpty && Get.parameters['module'] != 'null'),
    )),

    GetPage(name: newStores, page: () => getRoute(
      _waitForModule(Get.parameters['module'], AllStoreScreen(
        isPopular: Get.parameters['page'] == 'popular',
        isFeatured: Get.parameters['page'] == 'featured',
        isTopOfferStore: Get.parameters['page'] == 'topOffer',
        isNearbyStore: Get.parameters['nearby'] == 'true',
        isRecommendedStore: Get.parameters['page'] == 'recommended',
      )),
      byPuss: (Get.parameters['module'] != null && Get.parameters['module']!.isNotEmpty && Get.parameters['module'] != 'null'),
    )),
    GetPage(name: itemImages, page: () => getRoute(ImageViewerScreen(
      item: Item.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['item']!.replaceAll(' ', '+'))))),
    ))),
    GetPage(name: parcelCategory, page: () => getRoute(const ParcelCategoryScreen())),
    GetPage(name: parcelLocation, page: () {
      return getRoute(
        byPuss: (Get.parameters['module'] != null && Get.parameters['module']!.isNotEmpty && Get.parameters['module'] != 'null'),
        _waitForModule(
          Get.parameters['module'],
          ParcelLocationScreen(
            category: ParcelCategoryModel.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['data']!.replaceAll(' ', '+'))))),
          ),
        ),
    );
    }),
    GetPage(name: parcelRequest, page: () => getRoute(ParcelRequestScreen(
      parcelCategory: ParcelCategoryModel.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['category']!.replaceAll(' ', '+'))))),
      pickedUpAddress: AddressModel.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['picked']!.replaceAll(' ', '+'))))),
      destinationAddress: AddressModel.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['destination']!.replaceAll(' ', '+'))))),
    ))),
    GetPage(name: searchStoreItem, page: () => getRoute(StoreItemSearchScreen(storeID: Get.parameters['id']))),
    GetPage(name: order, page: () => getRoute(byPuss: true, const OrderScreen())),
    GetPage(name: '$itemDetails/:slug', page: () {
      return getRoute(
        byPuss: (Get.parameters['module'] != null && Get.parameters['module']!.isNotEmpty && Get.parameters['module'] != 'null'),
        _waitForModule(
          Get.parameters['module'], fromDeeplink: Get.parameters['from_deeplink'] == 'true',
          ItemDetailsScreen(itemId: int.parse(Get.parameters['id']!), inStorePage: Get.parameters['page'] == 'restaurant', isCampaign: Get.parameters['is_campaign'] == 'true'),
        ),
      );
    }),
    GetPage(name: wallet, page: () {
      return WalletScreen(
        fundStatus: Get.parameters['flag'] ?? Get.parameters['payment_status'],
        token: Get.parameters['token'],
        fromNotification: Get.parameters['from_notification'] == 'true',
      );
    }),
    GetPage(name: loyalty, page: () => LoyaltyScreen(fromNotification: Get.parameters['from_notification'] == 'true')),
    GetPage(name: referAndEarn, page: () => getRoute(byPuss: true, ReferAndEarnScreen(deeplinkUrlCode: Get.parameters['code'],))),
    GetPage(name: messages, page: () {
      NotificationBodyModel? notificationBody;
      if (Get.parameters['notification'] != 'null') {
        notificationBody = NotificationBodyModel.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['notification']!.replaceAll(' ', '+')))));
      }
      OrderChatModel? orderChat;
      if (Get.parameters['order-chat'] != 'null') {
        orderChat = OrderChatModel.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['order-chat']!.replaceAll(' ', '+')))));
      }
      User? user;
      if (Get.parameters['user'] != 'null') {
        user = User.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['user']!.replaceAll(' ', '+')))));
      }
      return getRoute(ChatScreen(
        notificationBody: notificationBody,
        user: user,
        index: Get.parameters['index'] != 'null' ? int.parse(Get.parameters['index']!) : null,
        fromNotification: Get.parameters['from'] == 'true',
        conversationID: (Get.parameters['conversation_id'] != null && Get.parameters['conversation_id'] != 'null') ? int.parse(Get.parameters['conversation_id']!) : null,
        orderChatModel: orderChat,
      ));
    }),
    GetPage(name: conversation, page: () => const ConversationScreen()),
    GetPage(name: restaurantRegistration, page: () => const StoreRegistrationScreen()),
    GetPage(name: deliveryManRegistration, page: () => const DeliveryManRegistrationScreen()),
    GetPage(name: riderRegistration, page: () => const RiderRegistrationScreen()),
    GetPage(name: refund, page: () => RefundRequestScreen(orderId: Get.parameters['id'])),
    GetPage(name: offlinePaymentScreen, page: () {
      return OfflinePaymentScreen(
        zoneId: int.parse(Get.parameters['zone_id']!),
        total: double.parse(Get.parameters['total']!),
        maxCodOrderAmount: (Get.parameters['max_cod_amount'] != null && Get.parameters['max_cod_amount'] != 'null')
            ? double.parse(Get.parameters['max_cod_amount']!)
            : null,
        fromCart: Get.parameters['from_cart'] == 'true',
        isCashOnDeliveryActive: Get.parameters['cod_active'] == 'true',
        forParcel: Get.parameters['for_parcel'] == 'true',
        orderId: Get.parameters['order_id']!,
        contactNumber: Get.parameters['contact_number'],
      );
    },
    ),
    GetPage(name: flashSaleDetailsScreen, page: () {
      return _waitForModule(
        Get.parameters['module'], FlashSaleDetailsScreen(id: int.parse(Get.parameters['id']!)),
      );
    },
    ),
    GetPage(name: guestTrackOrderScreen, page: () => GuestTrackOrderScreen(
      orderId: Get.parameters['order_id']!, number: Get.parameters['number']!,
    )),
    GetPage(name: favourite, page: () => const FavouriteScreen()),
    GetPage(name: brands, page: () {
      return _waitForModule(
        Get.parameters['module'], const BrandsScreen(),
      );
    }),
    GetPage(name: '$brandsItemScreen/:slug', page: () {
      return _waitForModule(
        Get.parameters['module'],
        BrandsItemScreen(
          brandId: int.parse(Get.parameters['brandId']!), brandName: Get.parameters['brandName']!,
        ),
      );
    }),

    GetPage(name: subscriptionSuccess, page: () => SubscriptionSuccessOrFailedScreen(success: Get.parameters['flag'] == 'success',
        fromSubscription: Get.parameters['from_subscription'] == 'true',
        storeId: (Get.parameters['store_id'] != null && Get.parameters['store_id'] != 'null') ? int.parse(Get.parameters['store_id']!) : null),
    ),
    GetPage(name: subscriptionPayment, page: () => SubscriptionPaymentScreen(storeId: int.parse(Get.parameters['store-id']!), packageId: int.parse(Get.parameters['package-id']!))),
    GetPage(name: newUserSetupScreen, page: () {
      return _waitForModule(
        Get.parameters['module'],
        NewUserSetupScreen(
          name: Get.parameters['name']!,
          loginType: Get.parameters['login_type']!,
          backFromThis: Get.parameters['back_from_this'] == 'true',
          phone: Get.parameters['phone'] != '' && Get.parameters['phone'] != 'null' ? Get.parameters['phone']!.replaceAll(' ', '+') : null,
          email: Get.parameters['email'] != '' && Get.parameters['email'] != 'null' ? Get.parameters['email']!.replaceAll(' ', '+') : null,
        ),
      );
    }),
    GetPage(name: itemViewAllScreen, page: () => getRoute(ItemViewAllScreen(isPopular: Get.parameters['page'] == 'popular', isSpecial: Get.parameters['special'] == 'true'))),
    GetPage(name: settingScreen, page: () => SettingPage()),
    GetPage(name: digitalPaymentFailedScreen, page: () {
      return DigitalPaymentFailedScreen(orderId: Get.parameters['orderId']!, createAccount: Get.parameters['create_account'] == 'true');
    }),
    GetPage(name: safety, page: () => getRoute(const SafetyPolicyScreen())),
    GetPage(name: allStoresScreen, page: () => getRoute(const AllStoreWebViewWidget())),


  ];

  static Widget getRoute(Widget navigateTo, {AccessLocationScreen? locationScreen, bool byPuss = false}) {
    double? minimumVersion = 0;
    if (GetPlatform.isAndroid) {
      minimumVersion = Get.find<SplashController>().configModel!.appMinimumVersionAndroid;
    } else if (GetPlatform.isIOS) {
      minimumVersion = Get.find<SplashController>().configModel!.appMinimumVersionIos;
    }
    return (AppConstants.appVersion < minimumVersion! && !GetPlatform.isWeb) ? const UpdateScreen(isUpdate: true)
        : Get.find<SplashController>().configModel!.maintenanceMode! ? const UpdateScreen(isUpdate: false)
        : (AddressHelper.getUserAddressFromSharedPref() == null && !byPuss)
        ? AccessLocationScreen(fromSignUp: false, fromHome: false, route: Get.currentRoute) : navigateTo;
  }

  static String _decideStoreRouteName(String page) {
    switch (page) {
      case 'popular':
        return popularStores;
      case 'featured':
        return featuredStores;
      case 'topOffer':
        return topOffers;
      case 'nearby':
        return bestStoresNearby;
      case 'recommended':
        return recommendedStores;
      case 'latest':
        return newStores;
      case 'best_store':
        return bestStoresNearby;
      default:
        return store;
    }
  }

  static Widget _waitForModule(String? moduleId, Widget child, {bool fromDeeplink = false}) {
    if(moduleId != null && moduleId.isNotEmpty && moduleId != 'null') {
      print('=======wait for module: $moduleId');
      return FutureBuilder(
        future: checkModuleId(moduleId, fromDeeplink: fromDeeplink),
        builder: (context, snapshot) {
          print('-------module future builder: ${snapshot.connectionState} // has data: ${snapshot.hasData} // error: ${snapshot.hasError}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CustomLoaderWidget());
          }
          return child;
        },
      );
    } else {
      return child;
    }
  }
  static Future<void> checkModuleId(String? parameters, {bool fromDeeplink = false}) async {
    if(parameters != null && parameters.isNotEmpty && parameters != 'null') {
      String moduleSlug = parameters;
      ApiClient apiClient = Get.find<ApiClient>();
      SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
      AddressModel? addressModel = AddressHelper.getUserAddressFromSharedPref();
      print('-----111-----config model is null: ${Get.find<SplashController>().configModel == null} // address: $addressModel // $fromDeeplink');

      if(addressModel != null) {
        print('-------address is not null, proceeding----');
        if(!fromDeeplink && !GetPlatform.isWeb) {
          print('-------from deeplink, not executing function');
          return;
        }
        await _moduleCheck(moduleSlug, apiClient, sharedPreferences, addressModel);
      } else {
        bool v = await Get.find<SplashController>().getModules(headers: {'Content-Type': 'application/json; charset=UTF-8', AppConstants.localizationKey: Get.find<LocalizationController>().locale.languageCode}, dataSource: DataSourceEnum.client);
        print('-----222-----module fetch status: $v');
        if(v) {
          if(Get.find<SplashController>().moduleList != null) {
            bool canContinue = true;

            ModuleModel? foundModule;
            for (ModuleModel module in Get.find<SplashController>().moduleList!) {
              print('-------module slug: ${module.slug} == $moduleSlug');
              if(module.slug == moduleSlug || module.id.toString() == moduleSlug) {
                foundModule = module;
                break;
              }
            }
            if(!AuthHelper.isLoggedIn() && !AuthHelper.isGuestLoggedIn()) {
              print('-------doing guest login > 1');
              ResponseModel responseModel = await Get.find<AuthController>().guestLogin();
              canContinue = responseModel.isSuccess;
            }
            if(!canContinue) {
              Get.offAllNamed(getInitialRoute());
              return;
            }
            print('-------found module: ${foundModule?.slug ?? foundModule?.id} // can route : $canContinue');
            if(foundModule != null) {
              Get.find<SplashController>().setModule(foundModule);
              apiClient.updateHeader(
                sharedPreferences.getString(AppConstants.token), null, null,
                sharedPreferences.getString(AppConstants.languageCode), moduleSlug, '0', '0', null
              );
            } else {
              apiClient.updateHeader(
                sharedPreferences.getString(AppConstants.token), null, null,
                sharedPreferences.getString(AppConstants.languageCode), null, '0', '0', null
              );
              Get.dialog(ZoneWarningDialog(
                title: 'module_is_not_available'.tr,
                onPressed: () async {
                  Get.back();
                  await Get.find<SplashController>().setModule(null);
                  ShallowRouterHelper.updateParameter('module', 'null');
                  Get.offAllNamed(getInitialRoute(moduleId: 'null'));
                },
              ), barrierDismissible: false);
              return;
            }
          }
        }
      }
    }
  }

}
Future<void> _moduleCheck(String moduleSlug, ApiClient apiClient, SharedPreferences sharedPreferences, AddressModel addressModel) async {

  if(Get.find<SplashController>().moduleList != null && GetPlatform.isWeb) {
    return;
  }
  print('----------config model is null: ${Get.find<SplashController>().configModel == null}');
  if(Get.find<SplashController>().configModel == null) {
    print('======config data call from route Helper');
    await Get.find<SplashController>().getConfigData(source: DataSourceEnum.client, canRoute: false);
  }

  print('=======module fetching----');
  bool v = await Get.find<SplashController>().getModules(dataSource: DataSourceEnum.client);
  print('=======module fetch status: $v');
  if(v) {
    if(Get.find<SplashController>().moduleList != null) {
      ModuleModel? foundModule;
      for (ModuleModel module in Get.find<SplashController>().moduleList!) {
        if(module.slug == moduleSlug || module.id.toString() == moduleSlug) {
          foundModule = module;
          break;
        }
      }
      print('-------found module: ${foundModule?.slug ?? foundModule?.id} // route module slug: $moduleSlug');
      if(foundModule != null) {
        Get.find<SplashController>().setModule(foundModule);
        apiClient.updateHeader(
            sharedPreferences.getString(AppConstants.token), addressModel.zoneIds, addressModel.areaIds,
            sharedPreferences.getString(AppConstants.languageCode), moduleSlug, addressModel.latitude, addressModel.longitude, null
        );
        Get.find<SplashController>().clearDataNull(foundModule);

        HomeScreen.loadData(true);

      } else {
        Get.find<SplashController>().setModule(null);
        apiClient.updateHeader(
            sharedPreferences.getString(AppConstants.token), addressModel.zoneIds, addressModel.areaIds,
            sharedPreferences.getString(AppConstants.languageCode), null, addressModel.latitude, addressModel.longitude, null
        );
        showCustomSnackBar('no_module_found'.tr);
        Get.offAllNamed(RouteHelper.getInitialRoute());
      }
    }
  }

}
