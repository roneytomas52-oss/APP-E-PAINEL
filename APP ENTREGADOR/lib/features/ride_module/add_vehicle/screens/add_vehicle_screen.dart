import 'package:flutter/material.dart';
import 'package:sixam_mart_delivery/features/profile/domain/models/profile_model.dart';


class AddVehicleScreen extends StatefulWidget {
  final Vehicle? vehicleInfo;
  const AddVehicleScreen({super.key, this.vehicleInfo});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(),
    );
  }
}
