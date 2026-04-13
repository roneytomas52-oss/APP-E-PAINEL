import 'package:get/get.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';
import 'package:sixam_mart/features/location/domain/services/location_service_interface.dart';
import '../domain/services/search_location_service_interface.dart';

enum LocationType{from, to, extraOne, extraTwo, location, accessLocation, senderLocation, receiverLocation}

class SearchLocationController extends GetxController implements GetxService {
  final SearchLocationServiceInterface searchLocationServiceInterface;
  final LocationServiceInterface locationServiceInterface;

  SearchLocationController({required this.locationServiceInterface, required this.searchLocationServiceInterface});

  Future<ZoneResponseModel> getRideZone(String lat, String long) async {
    return ZoneResponseModel(false, '', [], [], [], 403, '');
  }
}
  