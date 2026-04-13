  import 'dart:async';
import 'package:get/get.dart';
import '../domain/services/rideHome_service_interface.dart';
  
class RideHomeController extends GetxController implements GetxService {
  final RideHomeServiceInterface rideHomeServiceInterface;

  RideHomeController({required this.rideHomeServiceInterface});


  Future<Response> getOfferList(int offset) async {
    return Response();
  }

  Future<void> getBannerList() async {
  }

  Future<void> getCategoryList() async {

  }

  Future<void> getCouponList(int offset, {bool isUpdate = true}) async {

  }

}
  