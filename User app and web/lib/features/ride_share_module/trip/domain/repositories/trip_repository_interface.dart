import '../../../../../interfaces/repository_interface.dart';

abstract class TripRepositoryInterface extends RepositoryInterface {
  Future<dynamic> getTripList(String tripType, int offset, String from, String to, String filter,String status);
  Future<dynamic> getRideCancellationReasonList();
  Future<dynamic> submitReview(String id, int ratting, String comment );
  // Future<dynamic> getParcelCancellationReasonList();
}
