import 'package:sixam_mart/interfaces/repository_interface.dart';

abstract class PaymentRepositoryInterface extends RepositoryInterface {
  Future<bool> saveOfflineInfo(String data, String? guestId);
  Future<bool> updateOfflineInfo(String data, String? guestId);
}