import '../repositories/trip_repository_interface.dart';
import 'trip_service_interface.dart';

class TripService implements TripServiceInterface {
  final TripRepositoryInterface tripRepositoryInterface;
  TripService({required this.tripRepositoryInterface});

  @override
  Future getTripList(String tripType, int offset, String from, String to, String filter,String status) async{
    return await tripRepositoryInterface.getTripList(tripType, offset, from, to, filter,status);
  }

  @override
  Future getRideCancellationReasonList() async{
    return await tripRepositoryInterface.getRideCancellationReasonList();
  }

  @override
  Future submitReview(String id, int ratting, String comment) async{
    return await tripRepositoryInterface.submitReview(id, ratting, comment);
  }
  // @override
  // Future getParcelCancellationReasonList() async{
  //   return await tripRepositoryInterface.getParcelCancellationReasonList();
  // }
}
  