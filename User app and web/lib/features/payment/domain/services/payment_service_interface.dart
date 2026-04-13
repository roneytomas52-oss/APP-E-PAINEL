import 'package:sixam_mart/features/payment/domain/models/offline_method_model.dart';

abstract class PaymentServiceInterface {
  Future<List<OfflineMethodModel>?> getOfflineMethodList();
  Future<bool> saveOfflineInfo(String data, String? guestId);
  Future<bool> updateOfflineInfo(String data, String? guestId);
}