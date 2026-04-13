import 'package:get/get.dart';
import 'package:sixam_mart/features/ride_share_module/trip/domain/services/trip_service_interface.dart';

class TripController extends GetxController implements GetxService {
  final TripServiceInterface tripServiceInterface;
  TripController({required this.tripServiceInterface});

  void getRideCancellationReasonList() async{
  }
}