import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/ride_module/trip/domain/models/trip_model.dart';
import 'package:sixam_mart_delivery/features/ride_module/trip/domain/models/trip_overview_model.dart';
import '../domain/services/trip_service_interface.dart';

class TripController extends GetxController implements GetxService {
  final TripServiceInterface tripServiceInterface;

  TripController({required this.tripServiceInterface});

  TripModel? tripModel;
  List<FlSpot> earningChartList = [];
  double maxValue = 0;
  TripOverView? tripOverView;

  List<String> selectedOverviewType = ['today', 'this_week', 'last_week'];
  final String _selectedOverview = 'today';
  String get selectedOverview => _selectedOverview;

  Future<Response> getTripList(int offset) async {
    return Response();
  }
  void setOverviewType(String name){}
  void rideCancellationReasonList() async{}
  Future<void> getDailyLog() async {}

}
