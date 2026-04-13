import 'package:flutter/material.dart';

enum MapScreenType{ride, splash, parcel, location, dashboard}

class MapScreen extends StatefulWidget {
  final MapScreenType fromScreen;
  final bool isShowCurrentPosition;
  final bool? fromSearch;
  const MapScreen({super.key, required this.fromScreen, this.isShowCurrentPosition = true, this.fromSearch = false});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver{

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}

