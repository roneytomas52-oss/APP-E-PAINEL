import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart_delivery/api/api_client.dart';
import 'package:sixam_mart_delivery/common/models/response_model.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/ignore_model.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/order_cancellation_body.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/order_details_model.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/order_model.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/parcel_cancellation_reasons_model.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/update_status_body_model.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/repositories/order_repository_interface.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/order_cancellation_body.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';

import '../models/order_count_model.dart';

class OrderRepository implements OrderRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  OrderRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<List<CancellationData>?> getCancelReasons() async {
    List<CancellationData>? orderCancelReasons;
    Response response = await apiClient.getData('${AppConstants.orderCancellationUri}?offset=1&limit=30&type=deliveryman');
    if (response.statusCode == 200) {
      OrderCancellationBody orderCancellationBody = OrderCancellationBody.fromJson(response.body);
      orderCancelReasons = [];
      for (var element in orderCancellationBody.reasons!) {
        orderCancelReasons.add(element);
      }
    }
    return orderCancelReasons;
  }

  @override
  Future<Response> get(int? id) async {
    Response response = await apiClient.getData('${AppConstants.currentOrderUri}${_getUserToken()}&order_id=$id');
    return response;
  }

  @override
  Future<PaginatedOrderModel?> getCompletedOrderList(int offset, {String orderStatus = 'all'}) async {
    PaginatedOrderModel? paginatedOrderModel;
    Response response = await apiClient.getData(
        '${AppConstants.allOrdersUri}?token=${_getUserToken()}&offset=$offset&limit=10&order_status=$orderStatus'
    );
    if (response.statusCode == 200) {
      paginatedOrderModel = PaginatedOrderModel.fromJson(response.body);
    }
    return paginatedOrderModel;
  }

  // @override
  // Future<PaginatedOrderModel?> getCompletedOrderList(int offset) async {
  //   PaginatedOrderModel? paginatedOrderModel;
  //   Response response = await apiClient.getData('${AppConstants.allOrdersUri}?token=${_getUserToken()}&offset=$offset&limit=10&');
  //   if (response.statusCode == 200) {
  //     paginatedOrderModel = PaginatedOrderModel.fromJson(response.body);
  //   }
  //   return paginatedOrderModel;
  // }

  @override
  Future<List<OrderModel>?> getLatestOrders() async {
    List<OrderModel>? latestOrderList;
    Response response = await apiClient.getData(AppConstants.latestOrdersUri + _getUserToken());
    if(response.statusCode == 200) {
      latestOrderList = [];
      response.body.forEach((order) => latestOrderList!.add(OrderModel.fromJson(order)));
    }
    return latestOrderList;
  }

  @override
  Future<ResponseModel> updateOrderStatus(UpdateStatusBodyModel updateStatusBody, List<MultipartBody> proofAttachment) async {
    updateStatusBody.token = _getUserToken();
    ResponseModel responseModel;

    Map<String, String> data;

    if (updateStatusBody.isParcel ?? false) {
      data = {'_method': 'put', 'token' : updateStatusBody.token!, 'order_id': updateStatusBody.orderId.toString(), 'status': updateStatusBody.status.toString(),
        'otp': updateStatusBody.otp.toString(), 'reason': updateStatusBody.reasons.toString(), 'note': updateStatusBody.comment ?? ''};
    } else {
      data = {'_method': 'put', 'token' : updateStatusBody.token!, 'order_id': updateStatusBody.orderId.toString(), 'status': updateStatusBody.status.toString(),
        'otp': updateStatusBody.otp.toString(), 'reason': updateStatusBody.reason ?? ''};
    }

    Response response = await apiClient.postMultipartData(AppConstants.updateOrderStatusUri, data, proofAttachment, handleError: false);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body['message']);
    }else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  @override
  Future<List<OrderDetailsModel>?> getOrderDetails(int? orderID) async {
    List<OrderDetailsModel>? orderDetailsModel;
    Response response = await apiClient.getData('${AppConstants.orderDetailsUri}${_getUserToken()}&order_id=$orderID');
    if (response.statusCode == 200) {
      orderDetailsModel = [];
      response.body.forEach((orderDetails) => orderDetailsModel!.add(OrderDetailsModel.fromJson(orderDetails)));
    }
    return orderDetailsModel;
  }

  @override
  Future<ResponseModel> acceptOrder(int? orderID) async {
    ResponseModel responseModel;
    final Position locationResult = await Geolocator.getCurrentPosition();
    Response response = await apiClient.postData(
        AppConstants.acceptOrderUri,
        {
          "_method": "put",
          'token': _getUserToken(),
          'order_id': orderID,
          'lat': locationResult.latitude,
          'lng': locationResult.longitude,
        },
        handleError: false);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body['message']);
    }else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  @override
  List<IgnoreModel> getIgnoreList() {
    List<IgnoreModel> ignoreList = [];
    List<String> stringList = sharedPreferences.getStringList(AppConstants.ignoreList) ?? [];
    for (var ignore in stringList) {
      ignoreList.add(IgnoreModel.fromJson(jsonDecode(ignore)));
    }
    return ignoreList;
  }

  @override
  void setIgnoreList(List<IgnoreModel> ignoreList) {
    List<String> stringList = [];
    for (var ignore in ignoreList) {
      stringList.add(jsonEncode(ignore.toJson()));
    }
    sharedPreferences.setStringList(AppConstants.ignoreList, stringList);
  }

  String _getUserToken() {
    return sharedPreferences.getString(AppConstants.token) ?? "";
  }

  @override
  Future<ParcelCancellationReasonsModel?> getParcelCancellationReasons({required bool isBeforePickup}) async {
    ParcelCancellationReasonsModel? cancellationReasonsModel;
    Response response = await apiClient.getData('${AppConstants.getParcelCancellationReasons}?limit=25&offset=1&user_type=customer&cancellation_type=${isBeforePickup ? 'before_pickup' : 'after_pickup'}');
    if(response.statusCode == 200){
      cancellationReasonsModel = ParcelCancellationReasonsModel.fromJson(response.body);
    }
    return cancellationReasonsModel;
  }

  @override
  Future<bool> addParcelReturnDate({required int orderId, required String returnDate}) async {
    Map<String, dynamic> data = {
      'token': _getUserToken(),
      'order_id': orderId,
      'return_date': returnDate,
    };
    Response response = await apiClient.postData(AppConstants.addParcelReturnDate, data);
    return response.statusCode == 200;
  }

  @override
  Future<bool> submitParcelReturn({required int orderId, required String orderStatus, required int returnOtp}) async {
    Map<String, dynamic> data = {
      'order_id': orderId,
      'order_status': orderStatus,
      'return_otp': returnOtp,
      'token': _getUserToken(),
    };
    Response response = await apiClient.postData(AppConstants.parcelReturn, data);
    return response.statusCode == 200;
  }

  @override
  Future<PaginatedOrderModel?> getCurrentOrders(int offset,  {String orderStatus = 'all'}) async {
    PaginatedOrderModel? paginatedOrderModel;
    Response response = await apiClient.getData('${AppConstants.currentOrdersUri + _getUserToken()}&offset=$offset&limit=10&order_status=$orderStatus');
    if(response.statusCode == 200) {
      paginatedOrderModel = PaginatedOrderModel.fromJson(response.body);
    }
    return paginatedOrderModel;
  }

  @override
  Future<List<OrderCountModel>?> getOrderCount(String type) async {
    List<OrderCountModel>? orderCountList;
    Response response = await apiClient.getData('${AppConstants.orderCount}?type=$type&token=${_getUserToken()}');
    if (response.statusCode == 200) {
      orderCountList = (response.body as List).map((item) => OrderCountModel.fromJson(item)).toList();
    }
    return orderCountList;
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> getList() {
    throw UnimplementedError();
  }

}