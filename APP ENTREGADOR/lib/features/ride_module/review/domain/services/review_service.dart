
import 'package:sixam_mart_delivery/features/ride_module/review/domain/repositories/review_repository_interface.dart';
import 'package:sixam_mart_delivery/features/ride_module/review/domain/services/review_service_interface.dart';

class ReviewService implements ReviewServiceInterface{
  final ReviewRepositoryInterface reviewRepositoryInterface;
  ReviewService({required this.reviewRepositoryInterface});
}