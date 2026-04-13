
import 'package:flutter/material.dart';

class RideOrderCompleteScreen extends StatefulWidget {
  final String tripId;
  final bool fromNotification;
  final bool? fromRideList;
  const RideOrderCompleteScreen({super.key, required this.tripId, this.fromNotification = false, this.fromRideList = false});

  @override
  State<RideOrderCompleteScreen> createState() => _RideOrderCompleteScreenState();
}

class _RideOrderCompleteScreenState extends State<RideOrderCompleteScreen> {

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
