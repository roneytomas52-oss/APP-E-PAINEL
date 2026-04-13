import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart_delivery/api/api_client.dart';
import 'package:sixam_mart_delivery/features/ride_module/leaderboard/domain/repositories/leader_board_repository_interface.dart';

class LeaderBoardRepository implements LeaderBoardRepositoryInterface{
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  LeaderBoardRepository({required this.apiClient, required this.sharedPreferences});
}