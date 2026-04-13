import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  final String fromScreen;
  const MapScreen({super.key, this.fromScreen = 'home'});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(),
    );
  }
}

  