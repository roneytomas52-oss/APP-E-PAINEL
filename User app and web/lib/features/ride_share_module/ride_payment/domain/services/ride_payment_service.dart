import '../repositories/ride_payment_repository_interface.dart';
import 'ride_payment_service_interface.dart';

class RidePaymentService implements RidePaymentServiceInterface {
  final RidePaymentRepositoryInterface ridePaymentRepositoryInterface;
  RidePaymentService({required this.ridePaymentRepositoryInterface});


  @override
  Future paymentSubmit(String tripId, String paymentMethod, String tips) async{
    return await ridePaymentRepositoryInterface.paymentSubmit(tripId, paymentMethod, tips);
  }

  @override
  Future submitReview(String id, int ratting, String comment) async{
    return await ridePaymentRepositoryInterface.submitReview(id, ratting, comment);
  }

  @override
  Future getPaymentGetWayList() async{
    return await ridePaymentRepositoryInterface.getPaymentGetWayList();
  }

  @override
  String getLastPaymentMethod() {
    return ridePaymentRepositoryInterface.getLastPaymentMethod();
  }

  @override
  Future<bool?> saveLastPaymentMethod(String paymentMethod) {
    return ridePaymentRepositoryInterface.saveLastPaymentMethod(paymentMethod);
  }

  @override
  String getLastPaymentType() {
    return ridePaymentRepositoryInterface.getLastPaymentType();
  }

  @override
  Future<bool?> saveLastPaymentType(String paymentType) {
    return ridePaymentRepositoryInterface.saveLastPaymentType(paymentType);
  }

}
  