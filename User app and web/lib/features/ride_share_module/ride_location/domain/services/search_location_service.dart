import '../repositories/search_location_repository_interface.dart';
import 'search_location_service_interface.dart';

class SearchLocationService implements SearchLocationServiceInterface {
  final SearchLocationRepositoryInterface searchLocationRepositoryInterface;
  SearchLocationService({required this.searchLocationRepositoryInterface});

}
  