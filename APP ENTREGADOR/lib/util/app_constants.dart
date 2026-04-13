import 'package:sixam_mart_delivery/features/language/domain/models/language_model.dart';
import 'package:sixam_mart_delivery/util/enums.dart';
import 'package:sixam_mart_delivery/util/images.dart';

class AppConstants {
  static const String appName = '6amMart Delivery';
  static const double appVersion = 3.8; ///Flutter sdk 3.41.6
  static const String fontFamily = 'Roboto';
  static const AppMode appMode = AppMode.delivery;
  static const String baseUrl = 'https://6ammart-admin.6amtech.com';

  static const String polylineMapKey = 'YOUR_MAP_KEY_HERE';
  static const String configUri = '/api/v1/config';
  static const String forgetPasswordUri = '/api/v1/auth/delivery-man/forgot-password';
  static const String verifyTokenUri = '/api/v1/auth/delivery-man/verify-token';
  static const String resetPasswordUri = '/api/v1/auth/delivery-man/reset-password';
  static const String loginUri = '/api/v1/auth/delivery-man/login';
  static const String tokenUri = '/api/v1/delivery-man/update-fcm-token';
  static const String currentOrdersUri = '/api/v1/delivery-man/current-orders?token=';
  static const String allOrdersUri = '/api/v1/delivery-man/all-orders';
  static const String latestOrdersUri = '/api/v1/delivery-man/latest-orders?token=';
  static const String recordLocationUri = '/api/v1/delivery-man/record-location-data';
  static const String profileUri = '/api/v1/delivery-man/profile?token=';
  static const String updateOrderStatusUri = '/api/v1/delivery-man/update-order-status';
  static const String updatePaymentStatusUri = '/api/v1/delivery-man/update-payment-status';
  static const String orderDetailsUri = '/api/v1/delivery-man/order-details?token=';
  static const String acceptOrderUri = '/api/v1/delivery-man/accept-order';
  static const String activeStatusUri = '/api/v1/delivery-man/update-active-status';
  static const String updateProfileUri = '/api/v1/delivery-man/update-profile';
  static const String notificationUri = '/api/v1/delivery-man/notifications?token=';
  static const String aboutUsUri = '/api/v1/about-us';
  static const String privacyPolicyUri = '/api/v1/privacy-policy';
  static const String tramsAndConditionUri = '/api/v1/terms-and-conditions';
  static const String driverRemoveUri = '/api/v1/delivery-man/remove-account?token=';
  static const String dmRegisterUri = '/api/v1/auth/delivery-man/store';
  static const String zoneListUri = '/api/v1/zone/list';
  static const String zoneUri = '/api/v1/config/get-zone-id';
  static const String currentOrderUri = '/api/v1/delivery-man/order?token=';
  static const String vehiclesUri = '/api/v1/get-vehicles';
  static const String orderCancellationUri = '/api/v1/customer/order/cancellation-reasons';
  static const String deliveredOrderNotificationUri = '/api/v1/delivery-man/send-order-otp';
  static const String addWithdrawMethodUri = '/api/v1/delivery-man/withdraw-method/store';
  static const String editWithdrawMethodUri = '/api/v1/delivery-man/withdraw-method/edit';
  static const String disbursementMethodListUri = '/api/v1/delivery-man/withdraw-method/list';
  static const String makeDefaultDisbursementMethodUri = '/api/v1/delivery-man/withdraw-method/make-default';
  static const String deleteDisbursementMethodUri = '/api/v1/delivery-man/withdraw-method/delete';
  static const String getDisbursementReportUri = '/api/v1/delivery-man/get-disbursement-report';
  static const String withdrawRequestMethodUri = '/api/v1/delivery-man/get-withdraw-method-list';
  static const String makeCollectedCashPaymentUri = '/api/v1/delivery-man/make-collected-cash-payment';
  static const String walletPaymentListUri = '/api/v1/delivery-man/wallet-payment-list';
  static const String makeWalletAdjustmentUri = '/api/v1/delivery-man/make-wallet-adjustment';
  static const String walletProvidedEarningListUri = '/api/v1/delivery-man/wallet-provided-earning-list';
  static const String firebaseAuthVerify = '/api/v1/auth/delivery-man/firebase-verify-token';
  static const String earningReportUri = '/api/v1/delivery-man/earning-report';
  static const String earningReportInvoiceUri = '/deliveryman-earning-report-invoice';
  static const String getParcelCancellationReasons = '/api/v1/get-parcel-cancellation-reasons';
  static const String addParcelReturnDate = '/api/v1/delivery-man/add-return-date';
  static const String parcelReturn = '/api/v1/delivery-man/parcel-return';
  static const String getWithdrawList = '/api/v1/delivery-man/get-withdraw-list';
  static const String withdrawRequest = '/api/v1/delivery-man/request-withdraw';
  static const String referralEarningList = '/api/v1/delivery-man/referral-earning-list';
  static const String referralReportUri = '/api/v1/delivery-man/referral-report';
  static const String loyaltyReportUri = '/api/v1/delivery-man/loyalty-report';
  static const String loyaltyPointListUri = '/api/v1/delivery-man/loyalty-point-list';
  static const String dmPointConvertUri = '/api/v1/delivery-man/convert-loyalty-points';
  static const String riderPointConvertUri = '/api/v1/rideshare/rider/loyalty-points/convert';
  static const String orderCount = '/api/v1/delivery-man/orders-count';

  ///chat url
  static const String getConversationListUri = '/api/v1/delivery-man/message/list';
  static const String getMessageListUri = '/api/v1/delivery-man/message/details';
  static const String sendMessageUri = '/api/v1/delivery-man/message/send';
  static const String searchConversationListUri = '/api/v1/delivery-man/message/search-list';
  static const String sendFaqMessageToAdmin = '/api/v1/delivery-man/message/question/send';


  /// Ride Share module
  static const String vehicleBrandList = '/api/v1/rideshare/rider/vehicle/brand/list?offset=';
  static const String vehicleMainCategory = '/api/v1/rideshare/rider/vehicle/category/list?offset=';
  static const String addNewVehicle = '/api/v1/rideshare/rider/vehicle/store';
  static const String updateVehicle = '/api/v1/rideshare/rider/vehicle/update/';
  static const String bidding = '/api/v1/rideshare/rider/ride/bid';
  static const String tripDetails = '/api/v1/rideshare/rider/ride/details/';
  static const String uploadScreenShots = '/api/v1/rideshare/rider/ride/store-screenshot';
  static const String tripAcceptOrReject = '/api/v1/rideshare/rider/ride/trip-action';
  static const String matchOtp = '/api/v1/rideshare/rider/ride/match-otp';
  static const String outForPickupUri = '/api/v1/rideshare/rider/ride/update-to-out-for-pickup/';
  static const String remainDistance = '/api/v1/rideshare/rider/ride/get-routes';
  static const String tripStatusUpdate = '/api/v1/rideshare/rider/ride/update-status';
  static const String rideRequestList = '/api/v1/rideshare/rider/ride/pending-ride-list';
  static const String ongoingRideList = '/api/v1/rideshare/rider/ride/all-ride-list';
  static const String lastRideDetails = '/api/v1/rideshare/rider/ride/last-ride-details';
  static const String finalFare = '/api/v1/rideshare/rider/ride/final-fare';
  static const String arrivalPickupPoint = '/api/v1/rideshare/rider/ride/arrival-time';
  static const String arrivedDestination = '/api/v1/rideshare/rider/ride/coordinate-arrival';
  static const String waitingUri = '/api/v1/rideshare/rider/ride/ride-waiting';
  static const String tripList = '/api/v1/rideshare/rider/ride/list';
  static const String paymentUri = '/api/v1/rideshare/rider/ride/payment';
  static const String tripOverView = '/api/v1/rideshare/rider/ride/overview';
  static const String rideCancellationReasonList = '/api/v1/rideshare/rider/config/cancellation-reason-list';
  static const String getSafetyAlertReasonList = '/api/v1/rideshare/rider/config/safety-alert-reason-list';
  static const String getOtherEmergencyNumberList = '/api/v1/rideshare/rider/config/other-emergency-contact-list';
  static const String storeSafetyAlert = '/api/v1/rideshare/rider/safety-alert/store';
  static const String resendSafetyAlert = '/api/v1/rideshare/rider/safety-alert/resend/';
  static const String getPrecautionList = '/api/v1/rideshare/rider/config/safety-precaution-list';
  static const String customerAlertDetails = '/api/v1/rideshare/rider/safety-alert/show/';
  static const String undoSafetyAlert = '/api/v1/rideshare/rider/safety-alert/undo/';
  static const String markAsSolvedSafetyAlert = '/api/v1/rideshare/rider/safety-alert/mark-as-solved/';
  static const String trackDriverLog = '/api/v1/rideshare/rider/time-tracking';
  static const String getZoneId = '/api/v1/rideshare/rider/config/get-zone-id';
  static const String riderPaymentUri = '/api/v1/rideshare/rider/ride/payment';
  static const String submitReview = '/api/v1/rideshare/rider/review/store';
  static const String referralDetails = '/api/v1/rideshare/rider/referral-details';
  // static const String referralEarningList = '/api/v1/rideshare/rider/transaction/referral-earning-list?limit=10&offset=';
  // static const String loyaltyPointListUri = '/api/v1/rideshare/rider/loyalty-points/list?limit=10&offset=';
  static const String rideIncomeStatementListUri = '/api/v1/rideshare/rider/income-statement?limit=10&offset=';
  static const String deliveryIncomeStatementListUri = '/api/v1/delivery-man/income-statement?limit=10&offset=';
  static const String pointConvert = '/api/v1/rideshare/rider/loyalty-points/convert';
  static const String reviewList = '/api/v1/rideshare/rider/review/list?limit=10&offset=';
  static const String saveReview = '/api/v1/rideshare/rider/review/save/';
  static const String getProfileLevel = '/api/v1/rideshare/rider/level';
  static const String dailyActivities = '/api/v1/rideshare/rider/activity/daily-income';
  static const String leaderboardUri = '/api/v1/rideshare/rider/activity/leaderboard';

  static const String broadcastingAuthUrl = '/api/v1/rideshare/rider/broadcasting/deliveryman-auth';

  /// Shared Key
  static const String theme = 'sixam_mart_delivery_theme';
  static const String token = 'sixam_mart_delivery_token';
  static const String countryCode = 'sixam_mart_delivery_country_code';
  static const String languageCode = 'sixam_mart_delivery_language_code';
  static const String cacheCountryCode = 'cache_country_code';
  static const String cacheLanguageCode = 'cache_language_code';
  static const String userPassword = 'sixam_mart_delivery_user_password';
  static const String userAddress = 'sixam_mart_delivery_user_address';
  static const String userNumber = 'sixam_mart_delivery_user_number';
  static const String userCountryDialCode = 'sixam_mart_delivery_user_country_dial_code';
  static const String userCountryCode = 'sixam_mart_delivery_user_country_code';
  static const String notification = 'sixam_mart_delivery_notification';
  static const String notificationCount = 'sixam_mart_delivery_notification_count';
  static const String ignoreList = 'sixam_mart_delivery_ignore_list';
  static const String localizationKey = 'X-localization';
  static const String langIntro = 'language_intro';
  static const String notificationIdList = 'notification_id_list';

  static const String topicDeliveryman = 'all_zone_delivery_man';
  static const String topicRider = 'all_zone_rider';
  static const String zoneTopic = 'zone_topic';
  static const String vehicleWiseTopic = 'vehicle_wise_topic';

  /// Status
  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String accepted = 'accepted';
  static const String processing = 'processing';
  static const String handover = 'handover';
  static const String pickedUp = 'picked_up';
  static const String delivered = 'delivered';
  static const String canceled = 'canceled';
  static const String failed = 'failed';
  static const String refunded = 'refunded';
  static const String returned = 'returned';

  /// Others
  static const String isDelivery = 'is_delivery';
  static const String isRide = 'is_ride';

  ///user type..
  static const String user = 'user';
  static const String customer = 'customer';
  static const String deliveryMan = 'delivery_man';
  static const String vendor = 'vendor';
  static const String admin = 'admin';

  static List<LanguageModel> languages = [
    LanguageModel(imageUrl: Images.english, languageName: 'English', countryCode: 'US', languageCode: 'en'),
    LanguageModel(imageUrl: Images.arabic, languageName: 'Arabic', countryCode: 'SA', languageCode: 'ar'),
    LanguageModel(imageUrl: Images.spanish, languageName: 'Spanish', countryCode: 'ES', languageCode: 'es'),
    LanguageModel(imageUrl: Images.bangla, languageName: 'Bengali', countryCode: 'BN', languageCode: 'bn'),
  ];

  ///map zoom
  static const double mapZoom = 20;

  //Ride Status

  // static const String pending = 'pending';
  // static const String accepted = 'accepted';
  static const String outForPickup = 'out_for_pickup';
  static const String ongoing = 'ongoing';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
  static const String parcel = 'parcel';
  static const String unPaid = 'unpaid';
  static const String paid = 'paid';
  static const String findingRider = 'findingRider';
  static const String initial = 'initial';
  static const String riseFare = 'riseFare';
  static const String pickUpRide = 'pickUpRide';
  static const String afterAcceptRider = 'afterAcceptRider';
  static const String otpSend = 'otpSent';
  static const String ongoingRide = 'ongoingRide';
  static const String completeRide = 'completeRide';
  static const String sender = 'sender';
  static const String scheduleRequest = 'scheduled_request';
  static const String cacheZoneId = 'cache_zone_id';
}
