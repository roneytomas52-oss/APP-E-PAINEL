import 'package:flutter/material.dart';
class RideRequestScreen extends StatefulWidget {
  final Function onTap;
  final bool? fromMapScreen;
  const RideRequestScreen({super.key, required this.onTap,  this.fromMapScreen = false});
  @override
  RideRequestScreenState createState() => RideRequestScreenState();
}
class RideRequestScreenState extends State<RideRequestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SizedBox(),);
  }
}