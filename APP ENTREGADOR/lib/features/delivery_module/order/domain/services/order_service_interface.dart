import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart_delivery/api/api_client.dart';
import 'package:sixam_mart_delivery/common/models/response_model.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/ignore_model.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/order_cancellation_body.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/order_details_model.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/order_model.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/parcel_cancellation_reasons_model.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/update_status_body_model.dart';

import '../models/order_count_model.dart';

abstract class OrderServiceInterface{
  Future<List<CancellationData>?> getCancelReasons();
  Future<Response> getOrderWithId(int? orderId);
  Future<PaginatedOrderModel?> getCompletedOrderList(int offset, {String orderStatus = 'all'});
  Future<PaginatedOrderModel?> getCurrentOrders(int offset, {String orderStatus = 'all'});
  Future<List<OrderModel>?> getLatestOrders();
  Future<ResponseModel> updateOrderStatus(UpdateStatusBodyModel updateStatusBody, List<MultipartBody> proofAttachment);
  Future<List<OrderDetailsModel>?> getOrderDetails(int? orderID);
  Future<ResponseModel> acceptOrder(int? orderID);
  List<IgnoreModel> getIgnoreList();
  void setIgnoreList(List<IgnoreModel> ignoreList);
  List<OrderModel> processLatestOrders(List<OrderModel> latestOrderList, List<int?> ignoredIdList);
  List<int?> prepareIgnoreIdList(List<IgnoreModel> ignoredRequests);
  List<IgnoreModel> tempList(DateTime currentTime, List<IgnoreModel> ignoredRequests);
  List<MultipartBody> prepareOrderProofImages(List<XFile> pickedPrescriptions);
  Future<ParcelCancellationReasonsModel?> getParcelCancellationReasons({required bool isBeforePickup});
  Future<bool> addParcelReturnDate({required int orderId, required String returnDate});
  Future<bool> submitParcelReturn({required int orderId, required String orderStatus, required int returnOtp});
  Future<List<OrderCountModel>?> getOrderCount(String type);
}