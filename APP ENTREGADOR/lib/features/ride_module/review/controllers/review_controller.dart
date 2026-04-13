import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/ride_module/review/domain/services/review_service_interface.dart';

class ReviewController extends GetxController implements GetxService{
  final ReviewServiceInterface reviewServiceInterface;
  ReviewController({required this.reviewServiceInterface});

}