import 'package:sixam_mart_delivery/features/ride_module/leaderboard/domain/repositories/leader_board_repository_interface.dart';
import 'package:sixam_mart_delivery/features/ride_module/leaderboard/domain/services/leader_board_service_interface.dart';

class LeaderBoardService implements LeaderBoardServiceInterface {
  final LeaderBoardRepositoryInterface leaderBoardRepositoryInterface;
  LeaderBoardService({required this.leaderBoardRepositoryInterface});
}