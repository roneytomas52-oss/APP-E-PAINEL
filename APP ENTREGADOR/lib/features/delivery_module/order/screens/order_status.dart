import 'package:get/get_utils/src/extensions/internacionalization.dart';

String getOrderStatus(String key) {
  switch (key) {
    case 'all':
      return 'all'.tr;
    case 'pending':
      return 'pending'.tr;
    case 'accepted':
      return 'accepted'.tr;
    case 'confirmed':
      return 'confirmed'.tr;
    case 'processing':
      return 'processing'.tr;
    case 'handover':
      return 'handover'.tr;
    case 'picked_up':
      return 'picked_up'.tr;
    case 'failed':
      return 'failed'.tr;
    case 'delivered':
      return 'delivered'.tr;
    case 'canceled':
      return 'canceled'.tr;
    case 'refunded':
      return 'refunded'.tr;
    case 'refund_requested':
      return 'refund_requested'.tr;
    case 'returned':
      return 'returned'.tr;
    default:
      return key;
  }
}