import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sixam_mart_delivery/common/models/response_model.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/order_count_model.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/parcel_cancellation_reasons_model.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_delivery/api/api_client.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/order_details_model.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/order_model.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/update_status_body_model.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/ignore_model.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/order_cancellation_body.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/services/order_service_interface.dart';

class OrderController extends GetxController implements GetxService {
  final OrderServiceInterface orderServiceInterface;
  OrderController({required this.orderServiceInterface});

  List<OrderModel>? _currentOrderList;
  List<OrderModel>? get currentOrderList => _currentOrderList;
  
  List<OrderModel>? _completedOrderList;
  List<OrderModel>? get completedOrderList => _completedOrderList;
  
  List<OrderModel>? _latestOrderList;
  List<OrderModel>? get latestOrderList => _latestOrderList;
  
  List<OrderDetailsModel>? _orderDetailsModel;
  List<OrderDetailsModel>? get orderDetailsModel => _orderDetailsModel;
  
  List<IgnoreModel> _ignoredRequests = [];
  List<IgnoreModel> get ignoredRequests => _ignoredRequests;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String _otp = '';
  String get otp => _otp;
  
  bool _paginate = false;
  bool get paginate => _paginate;
  
  int? _pageSize;
  int? get pageSize => _pageSize;
  
  List<int> _offsetList = [];
  List<int> get offsetList => _offsetList;
  
  int _offset = 1;
  int get offset => _offset;
  
  OrderModel? _orderModel;
  OrderModel? get orderModel => _orderModel;
  
  String? _cancelReason = '';
  String? get cancelReason => _cancelReason;
  
  List<CancellationData>? _orderCancelReasons;
  List<CancellationData>? get orderCancelReasons => _orderCancelReasons;
  
  bool _showDeliveryImageField = false;
  bool get showDeliveryImageField => _showDeliveryImageField;
  
  List<XFile> _pickedPrescriptions = [];
  List<XFile> get pickedPrescriptions => _pickedPrescriptions;

  List<Reason>? _parcelCancellationReasons;
  List<Reason>? get parcelCancellationReasons => _parcelCancellationReasons;

  final List<String> _selectedParcelCancelReason = [];
  List<String>? get selectedParcelCancelReason => _selectedParcelCancelReason;

  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;

  int _selectedHour = 11;
  int get selectedHour => _selectedHour;

  int _selectedMinute = 59;
  int get selectedMinute => _selectedMinute;

  String _selectedPeriod = 'PM';
  String get selectedPeriod => _selectedPeriod;

  final List<DateTime> _availableDates = [];
  List<DateTime> get availableDates => _availableDates;

  List<OrderCountModel>? _currentOrderCountList;
  List<OrderCountModel>? get currentOrderCountList => _currentOrderCountList;

  List<OrderCountModel>? _historyOrderCountList;
  List<OrderCountModel>? get historyOrderCountList => _historyOrderCountList;

  String _selectedHistoryStatus = 'all';
  String get selectedHistoryStatus => _selectedHistoryStatus;

  String _selectedRunningStatus = 'all';
  String get selectedRunningStatus => _selectedRunningStatus;

  String _orderType = 'current';
  String get orderType => _orderType;

  void changeDeliveryImageStatus({bool isUpdate = true}){
    _showDeliveryImageField = !_showDeliveryImageField;
    if(isUpdate) {
      update();
    }
  }

  void pickPrescriptionImage({required bool isRemove, required bool isCamera}) async {
    if(isRemove) {
      _pickedPrescriptions = [];
    }else {
      XFile? xFile = await ImagePicker().pickImage(source: isCamera ? ImageSource.camera : ImageSource.gallery, imageQuality: 50);
      if(xFile != null) {
        _pickedPrescriptions.add(xFile);
        if(Get.isDialogOpen!){
          Get.back();
        }
      }
      update();
    }
  }

  void initLoading(){
    _isLoading = false;
    update();
  }

  void setOrderCancelReason(String? reason){
    _cancelReason = reason;
    update();
  }

  Future<void> getOrderCancelReasons() async {
    List<CancellationData>? orderCancelReasons = await orderServiceInterface.getCancelReasons();
    if (orderCancelReasons != null) {
      _orderCancelReasons = [];
      _orderCancelReasons!.addAll(orderCancelReasons);
    }
    update();
  }

  Future<void> getOrderWithId(int? orderId) async {
    _orderModel = null;
    Response response = await orderServiceInterface.getOrderWithId(orderId);
    if(response.statusCode == 200) {
      _orderModel = OrderModel.fromJson(response.body);

      debugPrint(_orderModel.toString());
    }else {
      Navigator.pop(Get.context!);
      await Get.find<OrderController>().getRunningOrders(offset);
    }
    update();
  }

  Future<void> getCompletedOrders(int offset, {bool willUpdate = true, String? status}) async {
    String orderStatus = status ?? _selectedHistoryStatus;

    if(offset == 1) {
      _offsetList = [];
      _offset = 1;
      _completedOrderList = null;
      if(willUpdate) {
        update();
      }
    }
    if (!_offsetList.contains(offset)) {
      _offsetList.add(offset);
      PaginatedOrderModel? paginatedOrderModel = await orderServiceInterface.getCompletedOrderList(offset, orderStatus: orderStatus);
      if (paginatedOrderModel != null) {
        if (offset == 1) {
          _completedOrderList = [];
        }
        _completedOrderList!.addAll(paginatedOrderModel.orders!);
        _pageSize = paginatedOrderModel.totalSize;
        _paginate = false;
        update();
      }
    } else {
      if(_paginate) {
        _paginate = false;
        update();
      }
    }
  }

  void showBottomLoader() {
    _paginate = true;
    update();
  }

  void setOffset(int offset) {
    _offset = offset;
  }

  Future<void> getRunningOrders(int offset, {bool willUpdate = true, String? status}) async {
    String orderStatus = status ?? _selectedRunningStatus;
    if(status != null ){
      _selectedRunningStatus = status;
    }

    if(offset == 1) {
      _offsetList = [];
      _offset = 1;
      _completedOrderList = null;
      if(willUpdate) {
        update();
      }
    }
    if (!_offsetList.contains(offset)) {
      _offsetList.add(offset);
      PaginatedOrderModel? paginatedOrderModel = await orderServiceInterface.getCurrentOrders(offset, orderStatus: orderStatus);
      if (paginatedOrderModel != null) {
        if (offset == 1) {
          _currentOrderList = [];
        }
        _currentOrderList!.addAll(paginatedOrderModel.orders!);
        _pageSize = paginatedOrderModel.totalSize;
        _paginate = false;
        update();
      } else {
        if (_paginate) {
          _paginate = false;
          update();
        }
      }
    }
  }

  Future<void> getLatestOrders() async {
    List<OrderModel>? latestOrderList = await orderServiceInterface.getLatestOrders();
    if(latestOrderList != null) {
      _latestOrderList = [];
      List<int?> ignoredIdList = orderServiceInterface.prepareIgnoreIdList(_ignoredRequests);
      _latestOrderList!.addAll(orderServiceInterface.processLatestOrders(latestOrderList, ignoredIdList));
    }
    update();
  }

  Future<bool> updateOrderStatus(OrderModel currentOrder, String status, {bool back = false,  String? reason, bool? parcel = false,
    bool gotoDashboard = false, List<String>? reasons, String? comment, bool stopOtherDataCall = false}) async {
    _isLoading = true;
    update();
    List<MultipartBody> multiParts = orderServiceInterface.prepareOrderProofImages(_pickedPrescriptions);
    UpdateStatusBodyModel updateStatusBody = UpdateStatusBodyModel(
      orderId: currentOrder.id, status: status, reason: reason,
      otp: status == AppConstants.delivered || (parcel! && status == AppConstants.pickedUp) ? _otp : null,
      isParcel: parcel, comment: comment, reasons: reasons,
    );
    ResponseModel responseModel = await orderServiceInterface.updateOrderStatus(updateStatusBody, multiParts);
    Get.back(result: responseModel.isSuccess);
    if(responseModel.isSuccess) {
      if(back) {
        Get.back();
      }
      if(gotoDashboard) {
        Get.offAllNamed(RouteHelper.getInitialRoute(fromOrderDetails: true));
      }
      if(!stopOtherDataCall){
        Get.find<ProfileController>().getProfile();
        
        // Auto-reset to 'all' for handover and post-handover status changes
        List<String> autoResetStatuses = ['picked_up'];
        if (autoResetStatuses.contains(currentOrder.orderStatus) && _selectedRunningStatus != 'all') {
          _selectedRunningStatus = 'all';
        }
        
        getRunningOrders(offset);
        getOrderCount('current');
        currentOrder.orderStatus = status;
      }
      showCustomSnackBar(responseModel.message, isError: false, getXSnackBar: false);
    }else {
      showCustomSnackBar(responseModel.message, isError: true, getXSnackBar: false);
    }
    _isLoading = false;
    update();
    return responseModel.isSuccess;
  }

  Future<void> getOrderDetails(int? orderID, bool parcel) async {
    if(parcel) {
      _orderDetailsModel = [];
    }else {
      _orderDetailsModel = null;
      List<OrderDetailsModel>? orderDetailsModel = await orderServiceInterface.getOrderDetails(orderID);
      if(orderDetailsModel != null) {
        _orderDetailsModel = [];
        _orderDetailsModel!.addAll(orderDetailsModel);
      }
      update();
    }
  }

  Future<bool> acceptOrder(int? orderID, int index, OrderModel orderModel) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await orderServiceInterface.acceptOrder(orderID);
    Get.back();
    if(responseModel.isSuccess) {
      _latestOrderList!.removeAt(index);
      _currentOrderList!.add(orderModel);
    }else {
      showCustomSnackBar(responseModel.message, isError: true);
    }
    _isLoading = false;
    update();
    return responseModel.isSuccess;
  }

  void getIgnoreList() {
    _ignoredRequests = [];
    _ignoredRequests.addAll(orderServiceInterface.getIgnoreList());
  }

  void ignoreOrder(int index) {
    _ignoredRequests.add(IgnoreModel(id: _latestOrderList![index].id, time: DateTime.now()));
    _latestOrderList!.removeAt(index);
    orderServiceInterface.setIgnoreList(_ignoredRequests);
    update();
  }

  void removeFromIgnoreList() {
    List<IgnoreModel> tempList = orderServiceInterface.tempList(Get.find<SplashController>().currentTime, _ignoredRequests);
    _ignoredRequests = [];
    _ignoredRequests.addAll(tempList);
    orderServiceInterface.setIgnoreList(_ignoredRequests);
  }

  void setOtp(String otp) {
    _otp = otp;
    if(otp != '') {
      update();
    }
  }

  Future<void> getParcelCancellationReasons({required bool isBeforePickup}) async {
    _parcelCancellationReasons = null;
    ParcelCancellationReasonsModel? parcelCancellationReasons = await orderServiceInterface.getParcelCancellationReasons(isBeforePickup: isBeforePickup);
    if(parcelCancellationReasons != null) {
      _parcelCancellationReasons = [];
      _parcelCancellationReasons!.addAll(parcelCancellationReasons.data!);
    }
    update();
  }

  void toggleParcelCancelReason(String reason, bool isSelected) {
    if (isSelected) {
      if (!_selectedParcelCancelReason.contains(reason)) {
        _selectedParcelCancelReason.add(reason);
      }
    } else {
      _selectedParcelCancelReason.remove(reason);
    }
    update();
  }

  bool isReasonSelected(String reason) {
    return _selectedParcelCancelReason.contains(reason);
  }

  void clearSelectedParcelCancelReason() {
    _selectedParcelCancelReason.clear();
  }

  String get selectedTimeFormatted {
    return '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')} $_selectedPeriod';
  }

  DateTime? get selectedDateTime {
    if (_selectedDate == null) return null;

    int hour24 = _selectedHour;
    if (_selectedPeriod == 'PM' && _selectedHour != 12) {
      hour24 += 12;
    } else if (_selectedPeriod == 'AM' && _selectedHour == 12) {
      hour24 = 0;
    }

    return DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, hour24, _selectedMinute);
  }

  void initializeDates(String canceledDateTimeString, int returnDays) {
    try {
      // Parse canceled datetime
      DateTime canceledDateTime = DateTime.parse(canceledDateTimeString);

      // Generate available dates (from canceled date to canceled date + returnDays)
      _availableDates.clear();
      DateTime currentDate = DateTime.now();

      for (int i = 0; i <= returnDays; i++) {
        DateTime availableDate = DateTime(
          canceledDateTime.year,
          canceledDateTime.month,
          canceledDateTime.day + i,
        );

        // Only add dates that are today or in the future
        if (availableDate.isAfter(currentDate.subtract(const Duration(days: 1))) ||
            _isSameDay(availableDate, currentDate)) {
          _availableDates.add(availableDate);
        }
      }

      // Set default selected date to the first available date
      if (_availableDates.isNotEmpty) {
        _selectedDate = _availableDates.first;
      }

      update();
    } catch (e) {
      debugPrint('Error parsing canceled datetime: $e');
    }
  }

  void selectDate(DateTime date) {
    if (_availableDates.contains(date)) {
      _selectedDate = date;
      update();
    }
  }

  void selectHour(int hour) {
    if (hour >= 1 && hour <= 12) {
      _selectedHour = hour;
      update();
    }
  }

  void selectMinute(int minute) {
    if (minute >= 0 && minute <= 59) {
      _selectedMinute = minute;
      update();
    }
  }

  void selectPeriod(String period) {
    if (period == 'AM' || period == 'PM') {
      _selectedPeriod = period;
      update();
    }
  }

  bool isDateSelected(DateTime date) {
    return _selectedDate != null && _isSameDay(_selectedDate!, date);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  String formatDate(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  String formatDateWithDay(DateTime date) {
    return DateFormat('EEE, MMM dd').format(date);
  }

  bool canSubmit() {
    return _selectedDate != null;
  }

  void reset() {
    _selectedDate = null;
    _selectedHour = 11;
    _selectedMinute = 59;
    _selectedPeriod = 'PM';
    _availableDates.clear();
    update();
  }

  Future<void> addParcelReturnDate({required int orderId, required String returnDate}) async {
    _isLoading = true;
    update();

    await orderServiceInterface.addParcelReturnDate(orderId: orderId, returnDate: returnDate);
    getOrderWithId(orderId);

    _isLoading = false;
    update();
  }

  Future<void> submitParcelReturn({required int orderId}) async {
    _isLoading = true;
    update();

    bool isSuccess = await orderServiceInterface.submitParcelReturn(orderId: orderId, orderStatus: 'returned', returnOtp: int.parse(_otp));
    if(isSuccess){
      getOrderWithId(orderId);

      if(Get.isDialogOpen!){
        Get.back();
      }
      showCustomSnackBar('parcel_returned_successfully'.tr, isError: false);
    }

    _isLoading = false;
    update();
  }

  List<OrderCountModel> get filteredOrderCountList {
    if (_currentOrderCountList == null) return [];
    return _currentOrderCountList!.where((status) => (status.count ?? 0) > 0).toList();
  }

  List<OrderCountModel> get filteredHistoryOrderCountList {
    if (_historyOrderCountList == null) return [];
    return _historyOrderCountList!.where((status) => (status.count ?? 0) > 0).toList();
  }

  Future<void> getOrderCount(String type) async {
    _isLoading = true;
    _orderType = type;
    List<OrderCountModel>? response = await orderServiceInterface.getOrderCount(type);
    if (response != null && response.isNotEmpty) {
      if (_orderType == 'current') {
        _currentOrderCountList = response;
      } else if (_orderType == 'history') {
        _historyOrderCountList = response;
      }
    } else {
      if (_orderType == 'current') {
        _currentOrderCountList = [];
      } else if (_orderType == 'history') {
        _historyOrderCountList = [];
      }
    }
    _isLoading = false;
  }


  void setHistoryOrderStatus(String status) {
    _selectedHistoryStatus = status;
    update();
    getCompletedOrders(1, status: status);
  }

  void setRunningOrderStatus(String status) {
    _selectedRunningStatus = status;
    update();
    getRunningOrders(1, status: status);
  }
}