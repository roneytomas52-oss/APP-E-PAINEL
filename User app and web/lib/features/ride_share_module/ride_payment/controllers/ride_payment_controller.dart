import 'package:get/get.dart';
import '../domain/services/ride_payment_service_interface.dart';

class RidePaymentController extends GetxController implements GetxService {
  final RidePaymentServiceInterface ridePaymentServiceInterface;

  RidePaymentController({required this.ridePaymentServiceInterface});

}